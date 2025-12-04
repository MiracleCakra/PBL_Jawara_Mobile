import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/iuran_model.dart';
import 'package:jawara_pintar_kel_5/utils.dart';

class EditIuranScreen extends StatefulWidget {
  final IuranModel iuran;

  const EditIuranScreen({super.key, required this.iuran});

  @override
  State<EditIuranScreen> createState() => _EditIuranScreenState();
}

class _EditIuranScreenState extends State<EditIuranScreen> {
  late TextEditingController _namaController;
  late TextEditingController _nominalController;
  late String _selectedJenis;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.iuran.namaIuran);
    _nominalController = TextEditingController(
      text: widget.iuran.nominal.toStringAsFixed(0),
    );
    _selectedJenis = widget.iuran.jenisIuran;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Edit Iuran',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    Text(
                      'Ubah data iuran yang diperlukan.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

                    // Nama Iuran
                    const Text(
                      'Nama Iuran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama iuran',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    // Jumlah
                    const Text(
                      'Jumlah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Masukkan jumlah',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    // Kategori Iuran
                    const Text(
                      'Kategori Iuran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedJenis,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black54,
                        ),
                        items: ['Iuran Bulanan', 'Iuran Khusus'].map((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedJenis = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate and save
                        if (_namaController.text.isEmpty ||
                            _nominalController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Mohon lengkapi semua field'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        IuranModel updatedIuran = IuranModel(
                          no: widget.iuran.no,
                          namaIuran: _namaController.text,
                          jenisIuran: _selectedJenis,
                          nominal:
                              double.tryParse(_nominalController.text) ?? 0.0,
                        );

                        updatedIuran.editIuran(
                          updatedIuran.no!,
                          updatedIuran.namaIuran,
                          updatedIuran.jenisIuran == 'Iuran Bulanan'
                              ? JenisIuran.bulanan
                              : JenisIuran.khusus,
                          updatedIuran.nominal,
                        );

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Iuran berhasil diperbarui'),
                            backgroundColor: getPrimaryColor(context),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
