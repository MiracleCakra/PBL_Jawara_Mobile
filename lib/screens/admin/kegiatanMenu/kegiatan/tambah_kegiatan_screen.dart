import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TambahKegiatanScreen extends StatefulWidget {
  const TambahKegiatanScreen({super.key});

  @override
  State<TambahKegiatanScreen> createState() => _TambahKegiatanScreenState();
}

class _TambahKegiatanScreenState extends State<TambahKegiatanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _pjController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  String? _selectedKategori;
  final List<String> _kategoriList = [
    'Komunitas & Sosial',
    'Kebersihan dan Keamanan',
    'Keagamaan',
    'Pendidikan',
    'Kesehatan & Olahraga',
    'Lainnya',
  ];

  // State Tanggal
  DateTime? _selectedDate;

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _pjController.dispose();
    _deskripsiController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  // Fungsi menampilkan Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Pelaksanaan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format tanggal
        _tanggalController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  void _simpanKegiatan() {
    if (_formKey.currentState!.validate()) {
      final newKegiatan = {
        'nama': _namaController.text,
        'kategori': _selectedKategori,
        'tanggal': _tanggalController.text,
        'lokasi': _lokasiController.text,
        'pj': _pjController.text,
        'deskripsi': _deskripsiController.text,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kegiatan "${newKegiatan['nama']}" berhasil disimpan!'),
        ),
      );
      Navigator.pop(context, newKegiatan);
    }
  }

  // Batal ttp halaman tanpa menyimpan data.
  void _batalForm() {
    Navigator.pop(context);
  }

  // Widget input text field
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isRequired = true,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
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
          readOnly: label == 'Tanggal' && suffixIcon != null,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            suffixIcon: suffixIcon,
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Kolom $label wajib diisi.';
            }
            return null;
          },
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
          'Buat Kegiatan Baru',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: Divider(height: 1, color: Colors.grey),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                'Nama Kegiatan',
                _namaController,
                'Masukkan Nama Kegiatan',
              ),
              const Text(
                'Pilih Kategori',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                hint: const Text('Pilih Kategori'),
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
                items: _kategoriList.map((String kategori) {
                  return DropdownMenuItem<String>(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedKategori = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Kolom Kategori wajib dipilih.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tanggal
              _buildTextField(
                'Tanggal',
                _tanggalController,
                '12.12.2022',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.grey),
                  onPressed: () => _selectDate(context),
                ),
                isRequired: true,
              ),

              _buildTextField(
                'Lokasi',
                _lokasiController,
                'Masukkan Lokasi',
                isRequired: false,
              ),
              _buildTextField(
                'Penanggung Jawab',
                _pjController,
                'Masukkan Penanggung Jawab',
              ),
              _buildTextField(
                'Deskripsi',
                _deskripsiController,
                'Tulis detail event seperti agenda, kegiatan dll.',
                maxLines: 5,
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _simpanKegiatan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: simpanColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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