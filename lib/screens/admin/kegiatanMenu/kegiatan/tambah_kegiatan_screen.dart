import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/kegiatan_model.dart';
import 'package:jawara_pintar_kel_5/services/kegiatan_service.dart';

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

  final KegiatanService _kegiatanService = KegiatanService();
  bool _isLoading = false;

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
  File? _selectedImageFile; // Untuk Mobile
  Uint8List? _selectedImageBytes; // Untuk Web
  String? _selectedImageName; // Nama file

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // PENTING BUAT WEB: Biar bytes-nya ke-load
    );

    if (result != null && result.files.isNotEmpty) {
      final PlatformFile file = result.files.first;

      // Validasi Ukuran (5MB)
      if (file.size > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ukuran gambar melebihi batas 5MB!')),
          );
        }
        return;
      }

      setState(() {
        _selectedImageName = file.name;

        if (kIsWeb) {
          _selectedImageBytes = file.bytes; // Web pakai bytes
        } else {
          if (file.path != null) {
            _selectedImageFile = File(file.path!); // Mobile pakai File Path
          }
        }
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _selectedImageBytes = null;
      _selectedImageName = null;
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        String? imageUrl;
        if (_selectedImageBytes != null || _selectedImageFile != null) {
          final String uniqueFileName =
              '${DateTime.now().millisecondsSinceEpoch}_${_selectedImageName ?? 'image.jpg'}';

          imageUrl = await _kegiatanService.uploadKegiatanImage(
            file: _selectedImageFile,
            bytes: _selectedImageBytes,
            fileName: uniqueFileName,
          );
        }

        final newKegiatan = KegiatanModel(
          judul: _namaController.text,
          kategori: _selectedKategori!,
          tanggal: _selectedDate!,
          lokasi: _lokasiController.text,
          pj: _pjController.text,
          deskripsi: _deskripsiController.text,
          dibuatOleh: 'Admin', // Default value
          hasDocs: imageUrl != null,
          gambarDokumentasi: imageUrl,
        );

        await _kegiatanService.createKegiatan(newKegiatan);
        if (mounted) {
          context.pop(true); // Return true on success
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan kegiatan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          onTap: label == 'Tanggal' ? () => _selectDate(context) : null,
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
            if (isRequired) {
              if (value == null || value.isEmpty) {
                return 'Kolom $label wajib diisi.';
              }
              if (label == 'Tanggal' && _selectedDate == null) {
                return 'Kolom Tanggal wajib diisi.';
              }
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                  _buildTextField(
                    'Tanggal',
                    _tanggalController,
                    'Pilih tanggal pelaksanaan',
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
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
                    isRequired: false,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upload Dokumentasi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Maksimal 1 gambar (.png / .jpg), ukuran maksimal 5MB.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedImageBytes != null || _selectedImageFile != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: kIsWeb
                              ? Image.memory(
                                  // Web: Tampilkan dari memori (bytes)
                                  _selectedImageBytes!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  // Mobile: Tampilkan dari file path
                                  _selectedImageFile!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ketuk untuk upload foto',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
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
                            onPressed: () => context.pop(),
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
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
