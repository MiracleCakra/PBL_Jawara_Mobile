import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/store_model.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/store_service.dart';
import 'package:jawara_pintar_kel_5/services/store_status_service.dart';
import 'package:jawara_pintar_kel_5/widget/marketplace/custom_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WargaStoreRegisterScreen extends StatefulWidget {
  const WargaStoreRegisterScreen({super.key});

  @override
  State<WargaStoreRegisterScreen> createState() =>
      _WargaStoreRegisterScreenState();
}

class _WargaStoreRegisterScreenState extends State<WargaStoreRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeService = StoreService();

  final TextEditingController namaTokoC = TextEditingController();
  final TextEditingController deskripsiC = TextEditingController();
  final TextEditingController lokasiC = TextEditingController();
  final TextEditingController noHpC = TextEditingController();

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          "Daftar Toko",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : 16,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBanner(),

            const SizedBox(height: 20),

            _buildFormCard(),

            const SizedBox(height: 30),

            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF8EA3F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.store_mall_directory, size: 40, color: Colors.white),
          SizedBox(height: 12),
          Text(
            "Buka Usaha di Marketplace Warga",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Daftarkan toko Anda dan mulai menjual produk ke warga sekitar.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 6,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInput(
                controller: namaTokoC,
                label: "Nama Toko",
                icon: Icons.storefront_outlined,
                validator: (v) => v!.isEmpty ? "Nama toko wajib diisi" : null,
              ),
              const SizedBox(height: 18),

              _buildInput(
                controller: deskripsiC,
                label: "Deskripsi Toko",
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Deskripsi wajib diisi" : null,
              ),
              const SizedBox(height: 18),

              _buildInput(
                controller: lokasiC,
                label: "Lokasi (RT/RW)",
                icon: Icons.location_on_outlined,
                validator: (v) => v!.isEmpty ? "Lokasi wajib diisi" : null,
              ),
              const SizedBox(height: 18),

              _buildInput(
                controller: noHpC,
                label: "No. HP / WhatsApp",
                icon: Icons.call_outlined,
                keyboard: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Nomor HP wajib diisi" : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Input
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboard,
    int maxLines = 1,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboard,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isSubmitting
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isSubmitting = true);

                  try {
                    // Get user_id from email
                    final authUser = Supabase.instance.client.auth.currentUser;
                    if (authUser?.email != null) {
                      final wargaResponse = await Supabase.instance.client
                          .from('warga')
                          .select('id')
                          .eq('email', authUser!.email!)
                          .maybeSingle();

                      if (wargaResponse == null) {
                        if (mounted) {
                          CustomSnackbar.show(
                            context: context,
                            message: 'Data warga tidak ditemukan',
                            type: DialogType.error,
                          );
                        }
                        setState(() => _isSubmitting = false);
                        return;
                      }

                      final userId = wargaResponse['id'] as String;

                      // Check if user already has a store
                      final existingStore = await _storeService
                          .getStoreByUserId(userId);
                      if (existingStore != null) {
                        if (mounted) {
                          CustomSnackbar.show(
                            context: context,
                            message: 'Anda sudah memiliki toko yang terdaftar',
                            type: DialogType.info,
                          );
                        }
                        setState(() => _isSubmitting = false);
                        return;
                      }

                      final newStore = StoreModel(
                        userId: userId,
                        nama: namaTokoC.text.trim(),
                        deskripsi: deskripsiC.text.trim(),
                        alamat: lokasiC.text.trim(),
                        kontak: noHpC.text.trim(),
                        verifikasi: 'Pending',
                        createdAt: DateTime.now(),
                      );

                      await _storeService.createStore(newStore);
                      await StoreStatusService.setStoreStatus(1);

                      if (mounted) {
                        CustomDialog.show(
                          context: context,
                          type: DialogType.success,
                          title: 'Toko Berhasil Didaftarkan!',
                          message:
                              'Toko Anda telah berhasil didaftarkan dan sedang menunggu verifikasi dari admin.',
                          buttonText: 'Lanjutkan',
                          onConfirm: () {
                            context.goNamed("StorePendingValidation");
                          },
                        );
                      }
                    }
                  } catch (e) {
                    print('Error creating store: $e');
                    if (mounted) {
                      CustomDialog.show(
                        context: context,
                        type: DialogType.error,
                        title: 'Pendaftaran Gagal',
                        message: 'Gagal mendaftarkan toko: $e',
                        buttonText: 'Coba Lagi',
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isSubmitting = false);
                    }
                  }
                }
              },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFF6A5AE0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Daftar Sekarang",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
