import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/providers/marketplace/store_provider.dart';
import 'package:jawara_pintar_kel_5/widget/marketplace/custom_dialog.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyStoreSettingsScreen extends StatefulWidget {
  const MyStoreSettingsScreen({super.key});

  @override
  State<MyStoreSettingsScreen> createState() => _MyStoreSettingsScreenState();
}

class _MyStoreSettingsScreenState extends State<MyStoreSettingsScreen> {
  static const Color primaryColor = Color(0xFF6A5AE0); // Ungu Tua
  static const Color errorColor = Colors.red;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStoreData();
    });
  }

  Future<void> _loadStoreData() async {
    try {
      final authUser = Supabase.instance.client.auth.currentUser;
      final userEmail = authUser?.email;

      if (userEmail == null || userEmail.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User tidak terautentikasi'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get NIK (warga.id) from email
      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', userEmail)
          .maybeSingle();

      if (wargaResponse == null || wargaResponse['id'] == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data warga tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final nik = wargaResponse['id'] as String;
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      await storeProvider.fetchStoreByUserId(nik);
    } catch (e) {
      print('Error loading store: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final currentStore = storeProvider.currentStore;
    // Toko aktif jika verifikasi = "Diterima" (case insensitive)
    final isStoreActive = currentStore?.verifikasi?.toLowerCase() == 'diterima';
    final isLoading = storeProvider.isLoading;

    // Debug log
    print('Current Store: ${currentStore?.nama}');
    print('Verifikasi Status: ${currentStore?.verifikasi}');
    print('Is Store Active: $isStoreActive');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan Toko',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentStore == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Toko tidak ditemukan',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadStoreData,
                    child: const Text('Muat Ulang'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStoreProfileHeader(),
                const SizedBox(height: 30),

                _buildSectionHeader("Profil"),
                _buildSettingItem(
                  context,
                  icon: Icons.storefront,
                  title: "Edit Nama & Deskripsi",
                  onTap: () async {
                    final result = await context.pushNamed('EditStoreProfile');
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: isStoreActive ? Icons.block : Icons.check_circle,
                  title: isStoreActive ? "Nonaktif Toko" : "Aktifkan Toko",
                  color: isStoreActive ? errorColor : Colors.green,
                  showArrow: false,
                  onTap: () async {
                    final confirm = await CustomConfirmDialog.show(
                      context: context,
                      type: isStoreActive
                          ? DialogType.warning
                          : DialogType.success,
                      title: isStoreActive
                          ? 'Nonaktifkan Toko'
                          : 'Aktifkan Toko',
                      message: isStoreActive
                          ? 'Toko Anda akan dinonaktifkan. Anda tidak dapat menjual produk.\n\nApakah Anda yakin?'
                          : 'Toko Anda akan diaktifkan kembali. Anda dapat mulai menjual produk setelah diaktifkan.\n\nApakah Anda yakin?',
                      cancelText: 'Batal',
                      confirmText: isStoreActive ? 'Nonaktifkan' : 'Aktifkan',
                    );

                    if (confirm == true) {
                      if (currentStore?.storeId == null) {
                        CustomSnackbar.show(
                          context: context,
                          message: 'Toko tidak ditemukan',
                          type: DialogType.error,
                        );
                        return;
                      }

                      // Update status: Aktif (Diterima) -> Nonaktif, Nonaktif -> Diterima
                      final newStatus = isStoreActive ? 'Nonaktif' : 'Diterima';

                      final success = await storeProvider
                          .updateVerificationStatus(
                            currentStore!.storeId!,
                            newStatus,
                          );

                      if (!mounted) return;

                      if (success) {
                        if (isStoreActive) {
                          // Jika toko dinonaktifkan, redirect ke halaman deactivated
                          CustomDialog.show(
                            context: context,
                            type: DialogType.success,
                            title: 'Toko Dinonaktifkan',
                            message: 'Toko Anda telah berhasil dinonaktifkan.',
                            buttonText: 'OK',
                            onConfirm: () {
                              context.goNamed('StoreDeactivated');
                            },
                          );
                        } else {
                          // Jika toko diaktifkan kembali
                          CustomSnackbar.show(
                            context: context,
                            message: 'Toko berhasil diaktifkan',
                            type: DialogType.success,
                          );
                        }
                      } else {
                        CustomSnackbar.show(
                          context: context,
                          message:
                              storeProvider.errorMessage ??
                              'Gagal mengubah status toko',
                          type: DialogType.error,
                        );
                      }
                    }
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.logout,
                  title: "Keluar",
                  color: errorColor,
                  showArrow: false,
                  onTap: () async {
                    final confirm = await CustomConfirmDialog.show(
                      context: context,
                      type: DialogType.warning,
                      title: 'Keluar dari Toko',
                      message: 'Apakah Anda yakin ingin keluar akun toko ini?',
                      cancelText: 'Batal',
                      confirmText: 'Ya, Keluar',
                    );

                    if (confirm == true && mounted) {
                      CustomSnackbar.show(
                        context: context,
                        message: 'Berhasil keluar',
                        type: DialogType.success,
                      );
                      context.go('/warga/marketplace');
                    }
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildStoreProfileHeader() {
    final storeProvider = Provider.of<StoreProvider>(context);
    final currentStore = storeProvider.currentStore;

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: primaryColor,
          child: const Icon(Icons.store, size: 30, color: Colors.white),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentStore?.nama ?? "Nama Toko",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Aktif sejak ${currentStore?.createdAt != null ? currentStore!.createdAt!.year : '2024'} | Rating 4.9",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87,
    bool showArrow = true,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: color == Colors.black87 ? primaryColor : color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, color: color),
        ),
        trailing: showArrow
            ? Icon(Icons.chevron_right, color: Colors.grey.shade400)
            : null,
        onTap: onTap,
      ),
    );
  }
}
