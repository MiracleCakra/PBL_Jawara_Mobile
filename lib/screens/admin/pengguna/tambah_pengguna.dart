import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TambahPenggunaScreen extends StatefulWidget {
  const TambahPenggunaScreen({super.key});

  @override
  State<TambahPenggunaScreen> createState() => _TambahPenggunaScreenState();
}

class _TambahPenggunaScreenState extends State<TambahPenggunaScreen> {
  final Color primary = const Color(0xFF4E46B4);

  // Controllers
  final _namaLengkapCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _nomorHPCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _konfirmasiPasswordCtl = TextEditingController();

  bool _passwordVisible = false;
  bool _konfirmasiPasswordVisible = false;

  String? _role;

  static const List<String> _allRoles = [
    'Admin',
    'Warga',
    'Ketua RT',
    'Ketua RW',
    'Sekretaris RW',
    'Sekretaris RT',
    'Bendahara RW',
    'Bendahara RT'
  ];
  // --------------------------------------------------

  @override
  void dispose() {
    _namaLengkapCtl.dispose();
    _emailCtl.dispose();
    _nomorHPCtl.dispose();
    _passwordCtl.dispose();
    _konfirmasiPasswordCtl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _namaLengkapCtl.clear();
      _emailCtl.clear();
      _nomorHPCtl.clear();
      _passwordCtl.clear();
      _konfirmasiPasswordCtl.clear();
      _role = null;
      _passwordVisible = false;
      _konfirmasiPasswordVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> roleItems = _allRoles.map((role) {
      return DropdownMenuItem(
        value: role,
        child: Text(role),
      );
    }).toList();
    // --------------------------------------------------

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Tambah Akun Pengguna',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Lengkap
              _buildTextField(
                label: 'Nama Lengkap',
                controller: _namaLengkapCtl,
                hint: 'Masukkan nama lengkap',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),

              // Email
              _buildTextField(
                label: 'Email',
                controller: _emailCtl,
                hint: 'Masukkan email aktif',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Nomor HP
              _buildTextField(
                label: 'Nomor HP',
                controller: _nomorHPCtl,
                hint: 'Masukkan nomor HP (ex: 08xxxxxxxxxx)',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Password
              _buildPasswordField(
                label: 'Password',
                controller: _passwordCtl,
                hint: 'Masukkan password',
                isVisible: _passwordVisible,
                onToggleVisibility: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Konfirmasi Password
              _buildPasswordField(
                label: 'Konfirmasi password',
                controller: _konfirmasiPasswordCtl,
                hint: 'Masukkan ulang password',
                isVisible: _konfirmasiPasswordVisible,
                onToggleVisibility: () {
                  setState(() {
                    _konfirmasiPasswordVisible = !_konfirmasiPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Role
              _buildDropdownField(
                label: 'Role',
                value: _role,
                hint: 'Pilih role',
                items: roleItems, 
                onChanged: (value) {
                  setState(() {
                    _role = value;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _reset,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Backend logic nanti
                        // Untuk sekarang hanya kembali ke halaman sebelumnya
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER  ---

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: GestureDetector(
              onTap: onToggleVisibility,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  isVisible ? 'Hide' : 'Show',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}