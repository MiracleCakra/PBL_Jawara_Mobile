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
  String? _deactivatedBy;
  String? _alasan;

  @override
  void initState() {
    super.initState();
    _loadStoreInfo();
  }

  Future<void> _loadStoreInfo() async {
    try {
      final authUser = Supabase.instance.client.auth.currentUser;
      final userEmail = authUser?.email;

      if (userEmail == null) {
        print('DEBUG: No auth user email');
        return;
      }

      print('DEBUG: Loading store for email: $userEmail');

      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', userEmail)
          .maybeSingle();

      if (wargaResponse == null) {
        print('DEBUG: No warga found');
        return;
      }

      final nik = wargaResponse['id'] as String;
      print('DEBUG: NIK: $nik');

      // Load directly from Supabase to ensure we get deactivated_by field
      final storeResponse = await Supabase.instance.client
          .from('store')
          .select('store_id, nama, verifikasi, alasan, deactivated_by')
          .eq('user_id', nik)
          .maybeSingle();

      if (storeResponse == null) {
        print('DEBUG: No store found');
        return;
      }

      print('DEBUG: Store data: $storeResponse');
      print('DEBUG: deactivated_by: ${storeResponse['deactivated_by']}');
      print('DEBUG: alasan: ${storeResponse['alasan']}');

      if (mounted) {
        setState(() {
          _deactivatedBy = storeResponse['deactivated_by'] as String?;
          _alasan = storeResponse['alasan'] as String?;
        });
        print(
          'DEBUG: State updated - deactivatedBy: $_deactivatedBy, alasan: $_alasan',
        );
      }
    } catch (e) {
      print('ERROR loading store info: $e');
      // Show default UI on error
    }
  }

  Future<void> _requestReactivation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authUser = Supabase.instance.client.auth.currentUser;
      final userEmail = authUser?.email;

      if (userEmail == null) {
        if (mounted) {
          CustomSnackbar.show(
            context: context,
            message: 'User tidak terautentikasi',
            type: DialogType.error,
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', userEmail)
          .maybeSingle();

      if (wargaResponse == null) {
        if (mounted) {
          CustomSnackbar.show(
            context: context,
            message: 'Data warga tidak ditemukan',
            type: DialogType.error,
          );
        }
        setState(() => _isLoading = false);
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
        setState(() => _isLoading = false);
        return;
      }

      // Update status to pending for admin review
      // Keep deactivated_by = 'admin' and original reason so admin knows the context
      final originalReason = _alasan ?? 'Tidak ada alasan sebelumnya';
      await Supabase.instance.client
          .from('store')
          .update({
            'verifikasi': 'Pending',
            'alasan':
                'PENGAJUAN AKTIVASI ULANG - Alasan nonaktif sebelumnya: $originalReason',
            // deactivated_by tetap 'admin' agar admin tahu ini permohonan aktivasi ulang
          })
          .eq('store_id', currentStore!.storeId!);

      if (!mounted) return;

      setState(() => _isLoading = false);

      CustomDialog.show(
        context: context,
        type: DialogType.success,
        title: 'Permohonan Terkirim!',
        message:
            'Permohonan aktivasi ulang toko Anda telah dikirim ke admin. Silakan tunggu verifikasi admin.',
        buttonText: 'OK',
        onConfirm: () {
          // Redirect ke screen pending validation untuk menunggu persetujuan admin
          context.goNamed('StorePendingValidation');
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.show(
          context: context,
          message: 'Error: ${e.toString()}',
          type: DialogType.error,
        );
      }
    }
  }

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

      // Activate store (change status to "Diterima" and remove deactivated_by)
      await Supabase.instance.client
          .from('store')
          .update({
            'verifikasi': 'Diterima',
            'deactivated_by': null,
            'alasan': null,
          })
          .eq('store_id', currentStore!.storeId!);

      final success = true;

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
                  color: _deactivatedBy == 'admin'
                      ? Colors.red.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _deactivatedBy == 'admin'
                      ? Icons.block
                      : Icons.store_mall_directory_outlined,
                  size: 60,
                  color: _deactivatedBy == 'admin' ? Colors.red : Colors.orange,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _deactivatedBy == 'admin'
                    ? 'Toko Dinonaktifkan oleh Admin'
                    : 'Toko Anda Dinonaktifkan',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_deactivatedBy == 'admin' && _alasan != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Alasan Nonaktif:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _alasan!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                _deactivatedBy == 'admin'
                    ? 'Toko Anda telah dinonaktifkan oleh admin karena melanggar peraturan. Anda tidak dapat menjual produk atau menerima pesanan.\n\nAnda dapat mengajukan permohonan aktivasi ulang untuk ditinjau oleh admin.'
                    : 'Toko Anda saat ini dalam status nonaktif. Anda tidak dapat menjual produk atau menerima pesanan.\n\nAktifkan kembali toko Anda untuk mulai berjualan.',
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
                  onPressed: _isLoading
                      ? null
                      : (_deactivatedBy == 'admin'
                            ? _requestReactivation
                            : _activateStore),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _deactivatedBy == 'admin'
                        ? Colors.orange.shade600
                        : primaryColor,
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
                      : Text(
                          _deactivatedBy == 'admin'
                              ? 'Ajukan Aktivasi Ulang'
                              : 'Aktifkan Toko Kembali',
                          style: const TextStyle(
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
