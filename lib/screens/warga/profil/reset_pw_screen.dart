import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moon_design/moon_design.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GantiKataSandiScreen extends StatefulWidget {
  const GantiKataSandiScreen({super.key});

  @override
  State<GantiKataSandiScreen> createState() => _GantiKataSandiScreenState();
}

class _GantiKataSandiScreenState extends State<GantiKataSandiScreen> {
  static const Color _primaryColor = Color(0xFF6366F1);
  static const Color _textInputFillColor = Colors.white;
  static const Color _textInputOutlineColor = Color(0xFFE5E7EB);
  static const Color _successColor = Color(0xFF6366F1);

  SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController _passwordLamaController = TextEditingController();
  final TextEditingController _passwordBaruController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  void _gantiPassword() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve the current user
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null) {
        // Authenticate user with old password to ensure the password is correct
        final email = user.email;
        final oldPassword = _passwordLamaController.text;
        final newPassword = _passwordBaruController.text;

        try {
          // Log in the user with the old password to verify it
          await supabase.auth.signInWithPassword(
            email: email!,
            password: oldPassword,
          );

          // Update the password to the new password
          final updateResponse = await supabase.auth.updateUser(
            UserAttributes(password: newPassword),
          );

          if (updateResponse.user == null) {
            // If there's an error during password update
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error update password'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            // Password updated successfully
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _successColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: _successColor,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Berhasil!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Kata sandi berhasil diperbarui.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _passwordLamaController.clear();
                              _passwordBaruController.clear();
                              _konfirmasiPasswordController.clear();
                              context.pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _successColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Selesai',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        } catch (e) {
          debugPrint('Error updating password: $e');
          // Handle any unexpected errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kata sandi lama salah!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // User is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengguna tidak terautentikasi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Terdapat input yang belum valid. Mohon periksa kembali.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          children: [
            MoonButton.icon(
              onTap: () => context.pop(),
              icon: const Icon(MoonIcons.controls_chevron_left_32_regular),
            ),
            const SizedBox(width: 8),
            Text(
              "Ganti Kata Sandi",
              style: MoonTokens.light.typography.heading.text40.copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w700,
              ),
              textScaler: const TextScaler.linear(0.7),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(right: 24, left: 24, top: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan kata sandi lama Anda, kemudian masukkan kata sandi baru untuk mengganti password akun Anda.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),

              _buildInputField(
                controller: _passwordLamaController,
                label: 'Kata Sandi Lama',
                hint: 'Masukkan kata sandi lama',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi lama wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _passwordBaruController,
                label: 'Kata Sandi Baru',
                hint: 'Masukkan kata sandi baru',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi baru wajib diisi.';
                  }
                  if (value.length < 6) {
                    return 'Kata sandi minimal 6 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _konfirmasiPasswordController,
                label: 'Konfirmasi Kata Sandi Baru',
                hint: 'Konfirmasi kata sandi baru',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi kata sandi wajib diisi.';
                  }
                  if (value != _passwordBaruController.text) {
                    return 'Konfirmasi kata sandi tidak cocok.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _gantiPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Simpan Kata Sandi Baru',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: _textInputFillColor,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _textInputOutlineColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
