import 'package:flutter/material.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/aspirasi_model.dart';
import 'package:SapaWarga_kel_2/services/aspirasi_service.dart';

class EditPesanWargaScreen extends StatefulWidget {
  final AspirasiModel pesan;

  const EditPesanWargaScreen({super.key, required this.pesan});

  @override
  State<EditPesanWargaScreen> createState() => _EditPesanWargaScreenState();
}

class _EditPesanWargaScreenState extends State<EditPesanWargaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final AspirasiService _aspirasiService = AspirasiService();
  bool _isLoading = false;

  // Status yang BISA DIUBAH
  String? _selectedStatus;
  final List<String> _statusList = ['Pending', 'Diterima', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    _judulController.text = widget.pesan.judul;
    _deskripsiController.text = widget.pesan.isi;

    if (_statusList.contains(widget.pesan.status)) {
      _selectedStatus = widget.pesan.status;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // Simpan Perubahan
  void _simpanPerubahan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final updatedAspirasi = widget.pesan.copyWith(
        status: _selectedStatus!,
      );

      try {
        await _aspirasiService.updateAspiration(updatedAspirasi);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui: $e'), backgroundColor: Colors.grey.shade800),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _batalForm() {
    Navigator.pop(context);
  }

  // Widget input text field
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    int maxLines,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: true,
          style: TextStyle(color: Colors.grey.shade700),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            fillColor: Colors.grey.shade100,
            filled: true,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color simpanColor = Colors.deepPurple;
    final Color batalColor = Colors.grey.shade500;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Edit Informasi / Aspirasi Warga',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // JUDUL
              _buildTextField('Judul', _judulController, 1),

              // DESKRIPSI
              _buildTextField('Deskripsi', _deskripsiController, 5),

              // STATUS
              const Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                items: _statusList.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Kolom Status wajib dipilih.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    // Tombol Batal
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _batalForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: batalColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Tombol Simpan
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _simpanPerubahan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: simpanColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Simpan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}