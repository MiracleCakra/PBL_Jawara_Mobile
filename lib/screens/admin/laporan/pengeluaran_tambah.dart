import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
<<<<<<< HEAD
import 'package:jawara_pintar_kel_5/models/keuangan/laporan_keuangan_model.dart';
import 'package:moon_design/moon_design.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
=======
import 'package:moon_design/moon_design.dart';
>>>>>>> e880963302028c513d6f88042d0ffc208416b69c

class PengeluaranTambahScreen extends StatefulWidget {
  const PengeluaranTambahScreen({super.key});

  @override
  State<PengeluaranTambahScreen> createState() =>
      _PengeluaranTambahScreenState();
}

class _PengeluaranTambahScreenState extends State<PengeluaranTambahScreen> {
<<<<<<< HEAD
  LaporanKeuanganModel laporankeuanganmodel = LaporanKeuanganModel(
    tanggal: DateTime.now(),
    nama: "",
    nominal: 0,
    kategoriPengeluaran: '',
    buktiFoto: '',
  );

=======
>>>>>>> e880963302028c513d6f88042d0ffc208416b69c
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nominalController = TextEditingController();
  final _tanggalController = TextEditingController();
<<<<<<< HEAD
  KategoriPengeluaran? _selectedKategoriPengeluaran;
=======
  final _kategoriController = TextEditingController();
>>>>>>> e880963302028c513d6f88042d0ffc208416b69c
  DateTime? _selectedDate;
  String? _buktiFotoPath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _buktiFotoPath = image.path;
        });
        if (mounted)
          Navigator.pop(context); // Close bottom sheet after selecting
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
      }
    }
  }

<<<<<<< HEAD
  // Fungsi untuk mengunggah foto ke Supabase
  Future<String?> _uploadFoto(XFile image) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = 'foto-pengeluaran/$fileName';

      await Supabase.instance.client.storage
          .from('foto-pengeluaran')
          .upload(
            filePath,
            File(image.path),
            fileOptions: FileOptions(contentType: image.mimeType),
          );
      final imageUrl = Supabase.instance.client.storage
          .from('foto-pengeluaran')
          .getPublicUrl(filePath);
      return imageUrl;
    } on StorageException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah foto, Silakan coba lagi.')),
        );
        debugPrint('error: $e');
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengunggah foto: $e')));
      }
      debugPrint('error: $e');
      return null;
    }
  }

=======
>>>>>>> e880963302028c513d6f88042d0ffc208416b69c
  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF6366F1)),
                title: const Text('Kamera'),
                onTap: () => _pickImageFromSource(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF6366F1),
                ),
                title: const Text('Galeri'),
                onTap: () => _pickImageFromSource(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nominalController.dispose();
    _tanggalController.dispose();
<<<<<<< HEAD
=======
    _kategoriController.dispose();
>>>>>>> e880963302028c513d6f88042d0ffc208416b69c
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: Text(
          "Tambah Pengeluaran",
          style: MoonTokens.light.typography.heading.text20.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Pengeluaran
                const Text(
                  'Nama Pengeluaran',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama pengeluaran',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama pengeluaran tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Tanggal Pengeluaran
                const Text(
                  'Tanggal Pengeluaran',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tanggalController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: '--/--/----',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
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
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                                _tanggalController.clear();
                              });
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                                _tanggalController.text =
                                    "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Kategori pengeluaran
                const Text(
                  'Kategori pengeluaran',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
<<<<<<< HEAD
                DropdownButtonFormField<KategoriPengeluaran>(
                  initialValue: _selectedKategoriPengeluaran,
                  onChanged: (KategoriPengeluaran? newValue) {
                    setState(() {
                      _selectedKategoriPengeluaran = newValue;
                    });
                  },
                  items: KategoriPengeluaran.values
                      .map<DropdownMenuItem<KategoriPengeluaran>>((
                        KategoriPengeluaran value,
                      ) {
                        return DropdownMenuItem<KategoriPengeluaran>(
                          value: value,
                          child: Text(value.value),
                        );
                      })
                      .toList(),
                  decoration: InputDecoration(
                    hintText: 'Pilih kategori pengeluaran',
=======
                TextFormField(
                  controller: _kategoriController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan kategori pengeluaran',
>>>>>>> e880963302028c513d6f88042d0ffc208416b69c
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
<<<<<<< HEAD
=======
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF6366F1),
                        width: 2,
                      ),
                    ),
>>>>>>> e880963302028c513d6f88042d0ffc208416b69c
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
<<<<<<< HEAD
                    if (value == null) {
=======
                    if (value == null || value.isEmpty) {
>>>>>>> e880963302028c513d6f88042d0ffc208416b69c
                      return 'Kategori pengeluaran tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Nominal
                const Text(
                  'Nominal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nominalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nominal',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nominal tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Bukti Pengeluaran
                const Text(
                  'Bukti Pengeluaran',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showImageSourcePicker,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _buktiFotoPath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Upload bukti pengeluaran (.png/.jpg)',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk memilih foto',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_buktiFotoPath!),
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _buktiFotoPath = null),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6366F1),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF6366F1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
<<<<<<< HEAD
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Upload foto sebelum menyimpan data
                            if (_buktiFotoPath != null) {
                              final XFile image = XFile(_buktiFotoPath!);
                              final imageUrl = await _uploadFoto(image);
                              if (imageUrl != null) {
                                laporankeuanganmodel.savePengeluaran(
                                  _namaController.text,
                                  double.tryParse(_nominalController.text) ?? 0,
                                  _selectedKategoriPengeluaran?.value ?? '',
                                  imageUrl,
                                  _selectedDate ?? DateTime.now(),
                                  Supabase
                                          .instance
                                          .client
                                          .auth
                                          .currentUser
                                          ?.email ??
                                      '',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Pengeluaran berhasil ditambahkan',
                                    ),
                                  ),
                                );

                                Navigator.of(context).pop();
                              }
                            }
=======
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Return data to previous screen
                            final data = {
                              'nama': _namaController.text,
                              'tanggal': _selectedDate ?? DateTime.now(),
                              'kategoriPengeluaran':
                                  _kategoriController.text.isEmpty
                                  ? null
                                  : _kategoriController.text,
                              'nominal':
                                  double.tryParse(_nominalController.text) ?? 0,
                              'jenisPengeluaran': 'Pengeluaran Lainnya',
                              'buktiFoto': _buktiFotoPath,
                            };

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pengeluaran berhasil ditambahkan',
                                ),
                              ),
                            );
                            Navigator.of(context).pop(data);
>>>>>>> e880963302028c513d6f88042d0ffc208416b69c
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
