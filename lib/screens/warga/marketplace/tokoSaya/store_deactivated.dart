import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/providers/marketplace/store_provider.dart';
import 'package:jawara_pintar_kel_5/widget/marketplace/custom_dialog.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreDeactivatedScreen extends StatefulWidget {
  const StoreDeactivatedScreen({super.key});

  @override
  State<StoreDeactivatedScreen> createState() => _StoreDeactivatedScreenState();
}

class _StoreDeactivatedScreenState extends State<StoreDeactivatedScreen> {
  static const Color primaryColor = Color(0xFF6A5AE0);
  bool _isLoading = false;

  Future<void> _activateStore() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user's store
      final authUser = Supabase.instance.client.auth.currentUser;
      final userEmail = authUser?.email;

      if (userEmail == null || userEmail.isEmpty) {
        if (mounted) {
          CustomSnackbar.show(
            context: context,
            message: 'User tidak terautentikasi',
            type: DialogType.error,
          );
        }
        setState(() {
          _isLoading = false;
        });
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
          CustomSnackbar.show(
            context: context,
            message: 'Data warga tidak ditemukan',
            type: DialogType.error,
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final nik = wargaResponse['id'] as String;
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      await storeProvider.fetchStoreByUserId(nik);

      final currentStore = storeProvider.currentStore;

      if (currentStore?.storeId == null) {
        if (mounted) {
          CustomSnackbar.show(
            context: context,
            message: 'Toko tidak ditemukan',
            type: DialogType.error,
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Activate store (change status to "Diterima")
      final success = await storeProvider.updateVerificationStatus(
        currentStore!.storeId!,
        'Diterima',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (success) {
        CustomDialog.show(
          context: context,
          type: DialogType.success,
          title: 'Toko Diaktifkan!',
          message: 'Toko Anda telah berhasil diaktifkan kembali.',
          buttonText: 'OK',
          onConfirm: () {
            context.goNamed('WargaMarketplaceHome');
          },
        );
      } else {
        CustomSnackbar.show(
          context: context,
          message: storeProvider.errorMessage ?? 'Gagal mengaktifkan toko',
          type: DialogType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomSnackbar.show(
          context: context,
          message: 'Error: ${e.toString()}',
          type: DialogType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Toko Dinonaktifkan'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.store_mall_directory_outlined,
                  size: 60,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Toko Anda Dinonaktifkan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Toko Anda saat ini dalam status nonaktif. Anda tidak dapat menjual produk atau menerima pesanan.\n\nAktifkan kembali toko Anda untuk mulai berjualan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _activateStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Aktifkan Toko Kembali',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go('/warga/marketplace');
                },
                child: Text(
                  'Kembali ke Menu',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
