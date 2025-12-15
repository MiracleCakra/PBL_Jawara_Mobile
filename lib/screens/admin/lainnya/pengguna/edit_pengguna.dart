import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/services/pengguna_service.dart';
import 'package:SapaWarga_kel_2/widget/moon_result_modal.dart';

class EditPenggunaScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditPenggunaScreen({super.key, required this.userData});

  @override
  State<EditPenggunaScreen> createState() => _EditPenggunaScreenState();
}

class _EditPenggunaScreenState extends State<EditPenggunaScreen> {
  final Color primary = const Color(0xFF4E46B4);
  final PenggunaService _penggunaService = PenggunaService();

  // Controllers - Initialize dengan data yang ada
  late final TextEditingController _namaLengkapCtl;
  late final TextEditingController _emailCtl;
  late final TextEditingController _nomorHPCtl;

  // Dropdown state
  String? _role;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers dengan data yang ada
    _namaLengkapCtl = TextEditingController(text: widget.userData['name']);
    _emailCtl = TextEditingController(text: widget.userData['email']);
    _nomorHPCtl = TextEditingController(text: widget.userData['phone']);
    _role = widget.userData['role'];
  }

  @override
  void dispose() {
    _namaLengkapCtl.dispose();
    _emailCtl.dispose();
    _nomorHPCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final id = widget.userData['id'];
      if (id == null) throw Exception('ID Pengguna tidak ditemukan');

      await _penggunaService.updateUser(id, {
        'nama': _namaLengkapCtl.text,
        'email': _emailCtl.text,
        'telepon': _nomorHPCtl.text,
        'role': _role,
      });

      await showResultModal(
        context,
        type: ResultType.success,
        title: 'Berhasil',
        description: 'Data pengguna berhasil diperbarui.',
        actionLabel: 'Selesai',
        autoProceed: true,
      );

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui pengguna: $e'),
            backgroundColor: Colors.grey.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Edit Akun Pengguna',
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
              // Nama Lengkap (read-only)
              _buildTextField(
                label: 'Nama Lengkap',
                controller: _namaLengkapCtl,
                keyboardType: TextInputType.name,
                enabled: false,
              ),
              const SizedBox(height: 16),

              // Email
              _buildTextField(
                label: 'Email',
                controller: _emailCtl,
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),
              const SizedBox(height: 16),

              // Nomor HP
              _buildTextField(
                label: 'Nomor HP',
                controller: _nomorHPCtl,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Role
              _buildDropdownField(
                label: 'Role',
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'Warga', child: Text('Warga')),
                  DropdownMenuItem(value: 'RT', child: Text('RT')),
                  DropdownMenuItem(value: 'RW', child: Text('RW')),
                  DropdownMenuItem(
                    value: 'Sekretaris',
                    child: Text('Sekretaris'),
                  ),
                  DropdownMenuItem(
                    value: 'Bendahara',
                    child: Text('Bendahara'),
                  ),
                ],

                onChanged: (value) => setState(() => _role = value),
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
                      onPressed: _isLoading ? null : () => context.pop(),
                      child: Text(
                        'Batal',
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
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
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
          enabled: enabled,
          style: TextStyle(
            color: enabled ? Colors.black : Colors.grey.shade600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade200,
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
            disabledBorder: OutlineInputBorder(
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
          menuMaxHeight: 300,

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
