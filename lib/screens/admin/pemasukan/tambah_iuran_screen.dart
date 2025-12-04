import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/iuran_model.dart';

class TambahIuranScreen extends StatefulWidget {
  const TambahIuranScreen({super.key});

  @override
  State<TambahIuranScreen> createState() => _TambahIuranScreenState();
}

class _TambahIuranScreenState extends State<TambahIuranScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  String _selectedKategori = 'Iuran Bulanan';

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpanIuran() {
    if (_namaController.text.isEmpty || _jumlahController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi semua field'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    IuranModel iuranModel = IuranModel(
      namaIuran: _namaController.text,
      jenisIuran: _selectedKategori,
      nominal: double.tryParse(_jumlahController.text) ?? 0.0,
    );
    iuranModel.saveIuran(
      _namaController.text,
      _selectedKategori == 'Iuran Bulanan'
          ? JenisIuran.bulanan
          : JenisIuran.khusus,
      double.tryParse(_jumlahController.text) ?? 0.0,
    );

    // Tampilkan snackbar sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Iuran berhasil ditambahkan'),
        backgroundColor: Color(0xFF6366F1),
      ),
    );

    // Kembali ke halaman sebelumnya
    Navigator.pop(context);
  }

  void _resetForm() {
    _namaController.clear();
    _jumlahController.clear();
    setState(() {
      _selectedKategori = 'Iuran Bulanan';
    });
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
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Buat Iuran Baru',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    Text(
                      'Masukkan data iuran baru dengan lengkap.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

                    // Nama Iuran
                    const Text(
                      'Nama Iuran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama iuran',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Jumlah
                    const Text(
                      'Jumlah',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Masukkan jumlah',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Kategori Iuran
                    const Text(
                      'Kategori Iuran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedKategori,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[600],
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'Iuran Bulanan',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: Color(0xFF6366F1),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Iuran Bulanan',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Iuran Khusus',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_outline,
                                  color: Color(0xFF8B5CF6),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Iuran Khusus',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        selectedItemBuilder: (BuildContext context) {
                          return ['Iuran Bulanan', 'Iuran Khusus'].map((
                            String value,
                          ) {
                            return Row(
                              children: [
                                Icon(
                                  value == 'Iuran Bulanan'
                                      ? Icons.calendar_month
                                      : Icons.star_outline,
                                  color: value == 'Iuran Bulanan'
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFF8B5CF6),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedKategori = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Card untuk kategori yang dipilih
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _selectedKategori == 'Iuran Bulanan'
                              ? [
                                  const Color(0xFF6366F1).withOpacity(0.1),
                                  const Color(0xFF6366F1).withOpacity(0.05),
                                ]
                              : [
                                  const Color(0xFF8B5CF6).withOpacity(0.1),
                                  const Color(0xFF8B5CF6).withOpacity(0.05),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedKategori == 'Iuran Bulanan'
                              ? const Color(0xFF6366F1).withOpacity(0.3)
                              : const Color(0xFF8B5CF6).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _selectedKategori == 'Iuran Bulanan'
                                  ? const Color(0xFF6366F1).withOpacity(0.15)
                                  : const Color(0xFF8B5CF6).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: _selectedKategori == 'Iuran Bulanan'
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFF8B5CF6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedKategori == 'Iuran Bulanan'
                                      ? 'Iuran Rutin Bulanan'
                                      : 'Iuran Khusus',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedKategori == 'Iuran Bulanan'
                                        ? const Color(0xFF6366F1)
                                        : const Color(0xFF8B5CF6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedKategori == 'Iuran Bulanan'
                                      ? 'Iuran yang ditagihkan setiap bulan secara rutin kepada warga.'
                                      : 'Iuran untuk kegiatan atau kebutuhan tertentu yang bersifat insidental.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(24),
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
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _simpanIuran,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _selectedKategori == 'Iuran Bulanan'
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedKategori == 'Iuran Bulanan'
                                ? Icons.calendar_month
                                : Icons.star,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
