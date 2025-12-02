import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/store_service.dart';
import 'package:jawara_pintar_kel_5/services/store_status_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyStoreSettingsScreen extends StatelessWidget {
  const MyStoreSettingsScreen({super.key});

  static const Color primaryColor = Color(0xFF6A5AE0); // Ungu Tua
  static const Color errorColor = Colors.red;

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStoreProfileHeader(),
          const SizedBox(height: 30),

          _buildSectionHeader("Profil"),
          _buildSettingItem(
            context,
            icon: Icons.storefront,
            title: "Edit Nama & Deskripsi",
            onTap: () => context.pushNamed('EditStoreProfile'),
          ),

          _buildSettingItem(
            context,
            icon: Icons.logout,
            title: "Keluar",
            color: errorColor,
            showArrow: false,
            onTap: () {
              _showSnackbar(context, "Berhasil Keluar...");
              context.go('/warga/marketplace');
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.block,
            title: "Ajukan Nonaktif Toko",
            color: errorColor,
            showArrow: false,
            onTap: () async {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 12),
                      Text('Ajukan Nonaktif Toko'),
                    ],
                  ),
                  content: const Text(
                    'Toko Anda akan dinonaktifkan dan menunggu validasi admin. Selama proses ini, Anda tidak dapat menjual produk.\n\nApakah Anda yakin?',
                    style: TextStyle(fontSize: 15),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.pop(dialogContext);

                        // Show loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          // Get user's store
                          final authUser =
                              Supabase.instance.client.auth.currentUser;
                          if (authUser?.email == null) {
                            throw Exception('User tidak terautentikasi');
                          }

                          final wargaResponse = await Supabase.instance.client
                              .from('warga')
                              .select('id')
                              .eq('email', authUser!.email!)
                              .maybeSingle();

                          if (wargaResponse == null) {
                            throw Exception('Data warga tidak ditemukan');
                          }

                          final userId = wargaResponse['id'] as String;
                          final storeService = StoreService();
                          final store = await storeService.getStoreByUserId(
                            userId,
                          );

                          if (store == null || store.storeId == null) {
                            throw Exception('Toko tidak ditemukan');
                          }

                          // Update store status to Nonaktif (pending admin validation)
                          await Supabase.instance.client
                              .from('store')
                              .update({
                                'verifikasi': 'Nonaktif',
                                'alasan':
                                    'Menunggu validasi admin untuk nonaktif',
                              })
                              .eq('store_id', store.storeId!);

                          // Set store status to pending deactivation
                          await StoreStatusService.setStoreStatus(1);

                          // Close loading
                          if (context.mounted) Navigator.pop(context);

                          // Navigate to pending deactivation screen
                          if (context.mounted) {
                            context.goNamed('StorePendingDeactivation');
                          }
                        } catch (e) {
                          // Close loading
                          if (context.mounted) Navigator.pop(context);

                          // Show error
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal mengajukan nonaktif: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Ya, Ajukan'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStoreProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: primaryColor,
          child: const Icon(Icons.store, size: 30, color: Colors.white),
        ),
        const SizedBox(width: 15),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SSS, Sayyur Segar Susanto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Aktif sejak 2024 | Rating 4.9",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
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
