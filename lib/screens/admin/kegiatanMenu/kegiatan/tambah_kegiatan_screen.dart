import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/kegiatan_model.dart';
import 'package:SapaWarga_kel_2/services/kegiatan_service.dart';
import 'package:SapaWarga_kel_2/utils.dart' show getPrimaryColor;

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
  List<File> _selectedFiles = []; // Untuk Mobile
  List<Uint8List> _selectedBytes = []; // Untuk Web
  List<String> _selectedNames = []; // Nama file

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _pjController.dispose();
    _deskripsiController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  // ... (existing _showSuccessDialog code remains same) ...
  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Centang Hijau
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Judul
                const Text(
                  'Berhasil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Pesan
                const Text(
                  'Data kegiatan berhasil disimpan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Tombol Selesai
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup Dialog
                      // Tutup halaman TambahKegiatanScreen, sambil mengirim hasil 'true'
                      context.pop(true); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getPrimaryColor(context), // Menggunakan warna primary
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    // Cek limit 10
    if (_selectedNames.length >= 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Maksimal 10 gambar yang diperbolehkan!'),
            backgroundColor: Colors.grey.shade800,
          ),
        );
      }
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // Allow multiple
      withData: true, 
    );

    if (result != null && result.files.isNotEmpty) {
      // Hitung sisa slot
      int remainingSlots = 10 - _selectedNames.length;
      List<PlatformFile> filesToProcess = result.files;

      if (filesToProcess.length > remainingSlots) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hanya $remainingSlots gambar lagi yang bisa ditambahkan.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        filesToProcess = filesToProcess.take(remainingSlots).toList();
      }

      for (var file in filesToProcess) {
        // Validasi Ukuran (5MB) per file
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File ${file.name} melebihi batas 5MB dan dilewati.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          continue;
        }

        setState(() {
          _selectedNames.add(file.name);
          if (kIsWeb) {
            _selectedBytes.add(file.bytes!);
          } else {
            if (file.path != null) {
              _selectedFiles.add(File(file.path!));
            }
          }
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedNames.removeAt(index);
      if (kIsWeb) {
        _selectedBytes.removeAt(index);
      } else {
        _selectedFiles.removeAt(index);
      }
    });
  }

  // ... (existing _selectDate code remains same) ...
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
        // 1. Create Kegiatan first
        final newKegiatan = KegiatanModel(
          judul: _namaController.text,
          kategori: _selectedKategori!,
          tanggal: _selectedDate!,
          lokasi: _lokasiController.text,
          pj: _pjController.text,
          deskripsi: _deskripsiController.text,
          dibuatOleh: 'Admin',
          hasDocs: _selectedNames.isNotEmpty,
          gambarDokumentasi: null, // Legacy field null, will rely on relation
        );

        final createdKegiatan = await _kegiatanService.createKegiatan(newKegiatan);

        // 2. Upload Images if any
        if (_selectedNames.isNotEmpty) {
          if (createdKegiatan.id == null) throw Exception("ID Kegiatan null setelah create");
          
          await _kegiatanService.uploadMultipleImages(
            idKegiatan: createdKegiatan.id!,
            files: kIsWeb ? null : _selectedFiles,
            bytesList: kIsWeb ? _selectedBytes : null,
            fileNames: _selectedNames.map((name) => 
              '${DateTime.now().millisecondsSinceEpoch}_$name'
            ).toList(),
          );
        }

        if (mounted) {
          await _showSuccessDialog();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan kegiatan: $e'),
            backgroundColor: Colors.grey.shade800,
          ),
        );
      }
    }
  }
  
  // ... (existing _buildTextField code remains same) ...
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isRequired = true,
    int maxLines = 1,
    Widget? suffixIcon,
    Key? key,
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
          key: key,
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
  
  // ... (build method updates below in separate replacement block or merged if concise)


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
                    key: const Key('nama_kegiatan_field'),
                  ),
                  const Text(
                    'Pilih Kategori',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: const Key('kategori_kegiatan_dropdown'),
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
                    key: const Key('tanggal_kegiatan_field'),
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
                    key: const Key('lokasi_kegiatan_field'),
                    isRequired: false,
                  ),
                  _buildTextField(
                    'Penanggung Jawab',
                    _pjController,
                    'Masukkan Penanggung Jawab',
                    key: const Key('pj_kegiatan_field'),
                  ),
                  _buildTextField(
                    'Deskripsi',
                    _deskripsiController,
                    'Tulis detail event seperti agenda, kegiatan dll.',
                    key: const Key('deskripsi_kegiatan_field'),
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
                    'Maksimal 10 gambar (.png / .jpg), ukuran maksimal 5MB per file.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedNames.isNotEmpty)
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedNames.length + (_selectedNames.length < 10 ? 1 : 0),
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == _selectedNames.length) {
                            // Add button at the end
                             return InkWell(
                              onTap: _pickImage,
                              child: Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 30,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            );
                          }

                          final imageBytes = kIsWeb ? _selectedBytes[index] : null;
                          final imageFile = !kIsWeb ? _selectedFiles[index] : null;

                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: kIsWeb
                                    ? Image.memory(
                                        imageBytes!,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        imageFile!,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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
                            key: const Key('simpan_kegiatan_button'),
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: getPrimaryColor(context),
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
