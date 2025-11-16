import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditKegiatanScreen extends StatefulWidget {
  final Map<String, String> kegiatan;

  const EditKegiatanScreen({super.key, required this.kegiatan});

  @override
  State<EditKegiatanScreen> createState() => _EditKegiatanScreenState();
}

class _EditKegiatanScreenState extends State<EditKegiatanScreen> {
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

  DateTime? _selectedDate;
  List<File> _dokumentasiFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final Map<String, String> data = widget.kegiatan;

    _namaController.text = data['judul'] ?? '';
    _lokasiController.text = data['lokasi'] ?? '';
    _pjController.text = data['pj'] ?? '';
    _deskripsiController.text = data['deskripsi'] ?? '';
    _tanggalController.text = data['tanggal'] ?? '';

    if (_kategoriList.contains(data['kategori'])) {
      _selectedKategori = data['kategori'];
    }

    try {
      _selectedDate = DateFormat('dd.MM.yyyy').parse(data['tanggal']!);
    } catch (e) {
      _selectedDate = null;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _pjController.dispose();
    _deskripsiController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_dokumentasiFiles.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 10 gambar telah tercapai!')),
      );
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final File newFile = File(pickedFile.path);
      if (await newFile.length() > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran gambar melebihi batas 5MB!')),
        );
        return;
      }

      setState(() {
        _dokumentasiFiles.add(newFile);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _dokumentasiFiles.removeAt(index);
    });
  }

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
    if (picked != null && picked != (_selectedDate ?? DateTime.now())) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  void _simpanPerubahan() {
    if (_formKey.currentState!.validate()) {
      final updatedKegiatan = Map<String, String>.from(widget.kegiatan);
      updatedKegiatan['judul'] = _namaController.text;
      updatedKegiatan['kategori'] = _selectedKategori!;
      updatedKegiatan['tanggal'] = _tanggalController.text;
      updatedKegiatan['lokasi'] = _lokasiController.text;
      updatedKegiatan['pj'] = _pjController.text;
      updatedKegiatan['deskripsi'] = _deskripsiController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kegiatan "${updatedKegiatan['judul']}" berhasil diubah! (${_dokumentasiFiles.length} gambar diunggah)',
          ),
          backgroundColor: Colors.grey[800],
        ),
      );
      context.go('/admin/kegiatan/daftar');

    }
  }

  void _batalForm() {
    Navigator.pop(context);
  }

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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          'Edit Kegiatan',
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
              _buildTextField('Nama Kegiatan', _namaController, 'Masukkan Nama Kegiatan'),

              const Text('Pilih Kategori',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                hint: const Text('Pilih Kategori'),
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

              _buildTextField('Tanggal', _tanggalController, '12.12.2025',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.grey),
                    onPressed: () => _selectDate(context),
                  )),

              _buildTextField('Lokasi', _lokasiController, 'Masukkan Lokasi Anda', isRequired: false),
              _buildTextField('Penanggung Jawab', _pjController, 'Masukkan Penanggung Jawab'),
              _buildTextField('Deskripsi', _deskripsiController, 'Tulis detail event...', maxLines: 5),

              const SizedBox(height: 16),
              const Text('Upload Dokumentasi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                'Maksimal 10 gambar (.png / .jpg), ukuran maksimal 5MB per gambar. (${_dokumentasiFiles.length}/10 terunggah)',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),

              if (_dokumentasiFiles.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dokumentasiFiles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                _dokumentasiFiles[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),

              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300)),
                  child: Center(
                    child: Text(
                      _dokumentasiFiles.length < 10
                          ? 'Upload Foto png/jpg'
                          : 'Maksimum Gambar Tercapai',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                        onPressed: _simpanPerubahan,
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

              