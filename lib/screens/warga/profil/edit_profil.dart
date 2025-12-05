import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moon_design/moon_design.dart';

const Color _primaryColorApp = Color(0xFF6A5AE0);
const Color _backgroundColor = Color(0xFFF7F7F7);
const Color _primaryTextColor = Color(0xFF1F2937);

class WargaEditDataDiriScreen extends StatefulWidget {
  final Map<String, dynamic> initialData; 

  const WargaEditDataDiriScreen({
    super.key,
    this.initialData = const {
      'nama': 'Susanto',
      'nik': '3200101234567890',
      'email': 'Sasanto@gmail.com',
      'telepon': '081234567890',
      'gender': 'Pria',
      'status': 'Aktif',
      'alamat': 'Blok C No. 5, RT 001 / RW 001, Kelurahan jiwiri',
    },
  });

  @override
  State<WargaEditDataDiriScreen> createState() => _WargaEditDataDiriScreenState();
}

class _WargaEditDataDiriScreenState extends State<WargaEditDataDiriScreen> {
  final _formKey = GlobalKey<FormState>();

  // Kontroler untuk field yang DAPAT diedit
  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _alamatController;
  
  // Data yang tidak dapat diubah (ReadOnly)
  late final String _nik;
  late final String _gender;
  late final String _status;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.initialData['nama']);
    _emailController = TextEditingController(text: widget.initialData['email']);
    _phoneController = TextEditingController(text: widget.initialData['telepon']);
    _alamatController = TextEditingController(text: widget.initialData['alamat']);
    
    _nik = widget.initialData['nik'];
    _gender = widget.initialData['gender'];
    _status = widget.initialData['status'];
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  // --- Fungsi Simpan Data (Simulasi) ---
  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      // 1. Tampilkan loading
      setState(() => _isLoading = true);

      // 2. Simulasi proses simpan ke backend
      await Future.delayed(const Duration(seconds: 2));

      // 3. Matikan loading
      setState(() => _isLoading = false);

      if (mounted) {
        // 4. Tampilkan notifikasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data diri berhasil diperbarui! 🎉'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // 5. Kembali ke halaman detail
        context.pop();
      }
    }
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: Row(
          children: [
            MoonButton.icon(
              onTap: () => context.pop(),
              icon: const Icon(MoonIcons.controls_chevron_left_32_regular),
            ),
            const SizedBox(width: 8),
            Text(
              "Ubah Data Diri",
              style: MoonTokens.light.typography.heading.text40.copyWith(
                color: _primaryTextColor,
                fontWeight: FontWeight.w700,
              ),
              textScaler: const TextScaler.linear(0.7),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(right: 16, left: 16, top: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Identitas (Nama: EDITABLE) ---
              _buildInputGroup(
                title: 'Identitas',
                children: [
                  _buildEditableField(
                    label: 'Nama Lengkap',
                    controller: _namaController,
                    validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  _buildReadOnlyField(label: 'NIK', value: _nik), // READ ONLY
                  _buildReadOnlyField(label: 'Jenis Kelamin', value: _gender), // READ ONLY
                ],
              ),
              const SizedBox(height: 24),

              // --- Kontak & Akun (EDITABLE) ---
              _buildInputGroup(
                title: 'Kontak & Akun',
                children: [
                  _buildEditableField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Email tidak boleh kosong';
                      if (!value.contains('@') || !value.contains('.')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  _buildEditableField(
                    label: 'No Telepone',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Detail Tempat Tinggal (Alamat: EDITABLE) ---
              _buildInputGroup(
                title: 'Detail Tempat Tinggal',
                children: [
                  _buildEditableField(
                    label: 'Alamat',
                    controller: _alamatController,
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                  ),
                  _buildReadOnlyField(label: 'Status Warga', value: _status), // READ ONLY
                ],
              ),
              const SizedBox(height: 32),

              // --- Tombol Simpan ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColorApp,
                    disabledBackgroundColor: _primaryColorApp.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
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

  // --- Widget Helper untuk Field yang DAPAT Diedit ---
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _primaryTextColor),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              color: _primaryTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: _inputDecoration(),
          ),
        ],
      ),
    );
  }

  // --- Widget Helper untuk Field yang TIDAK DAPAT Diedit (sama seperti di halaman detail) ---
  Widget _buildReadOnlyField({required String label, required String value, int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey), // Warna label berbeda
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value.isEmpty ? '-' : value,
            readOnly: true,
            maxLines: maxLines,
            style: TextStyle(
              color: Colors.grey.shade700, // Warna value lebih soft
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: _inputDecoration(isReadOnly: true),
          ),
        ],
      ),
    );
  }

  // --- Helper untuk dekorasi input ---
  InputDecoration _inputDecoration({bool isReadOnly = false}) {
    final Color borderColor = isReadOnly ? Colors.grey.shade200 : Colors.grey.shade300;
    final Color focusedColor = isReadOnly ? Colors.grey.shade300 : _primaryColorApp.withOpacity(0.5);
    final Color fillColor = isReadOnly ? Colors.grey.shade100 : Colors.white;

    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: focusedColor, width: isReadOnly ? 1 : 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      fillColor: fillColor,
      filled: true,
    );
  }
  
  // --- Grup Input (sama seperti di WargaDataDiriScreen) ---
  Column _buildInputGroup({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MoonTokens.light.typography.heading.text16.copyWith(
            color: _primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}