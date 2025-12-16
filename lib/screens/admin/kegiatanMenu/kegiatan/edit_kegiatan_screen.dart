import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/kegiatan_model.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/kegiatan_img_model.dart';
import 'package:SapaWarga_kel_2/services/kegiatan_service.dart';
import 'package:SapaWarga_kel_2/widget/moon_result_modal.dart';
import 'package:SapaWarga_kel_2/constants/constant_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditKegiatanScreen extends StatefulWidget {
  final KegiatanModel kegiatan;

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

  // State untuk Gambar
  List<KegiatanImageModel> _existingImages = [];
  List<int> _deletedImageIds = [];
  
  List<File> _newFiles = []; // Mobile
  List<Uint8List> _newBytes = []; // Web
  List<String> _newNames = []; // Nama file

  @override
  void initState() {
    super.initState();
    final data = widget.kegiatan;

    _namaController.text = data.judul;
    _lokasiController.text = data.lokasi;
    _pjController.text = data.pj;
    _deskripsiController.text = data.deskripsi;
    _tanggalController.text = DateFormat('dd.MM.yyyy').format(data.tanggal);
    _selectedDate = data.tanggal;
    
    // Inisialisasi gambar yang sudah ada
    if (data.images != null) {
      _existingImages = List.from(data.images!);
    } 

    // Fetch fresh images if list is empty, just to be safe (addressing previous issue)
    if (_existingImages.isEmpty && data.id != null) {
      _fetchFreshImages(data.id!);
    }

    if (_kategoriList.contains(data.kategori)) {
      _selectedKategori = data.kategori;
    }
  }

  Future<void> _fetchFreshImages(int id) async {
    try {
      final fullData = await _kegiatanService.getKegiatanById(id);
      if (mounted && fullData.images != null && fullData.images!.isNotEmpty) {
        setState(() {
          _existingImages = List.from(fullData.images!);
        });
      }
    } catch (e) {
      debugPrint("Error fetching fresh images: $e");
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
    int currentCount = _existingImages.length + _newNames.length;
    if (currentCount >= 10) {
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
      allowMultiple: true,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      int remaining = 10 - currentCount;
      List<PlatformFile> files = result.files;
      
      if (files.length > remaining) {
         files = files.take(remaining).toList();
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hanya sisa slot gambar yang ditambahkan.')),
            );
         }
      }

      for (var file in files) {
        if (file.size > 5 * 1024 * 1024) continue; // Skip > 5MB

        setState(() {
          _newNames.add(file.name);
          if (kIsWeb) {
            _newBytes.add(file.bytes!);
          } else {
            if (file.path != null) {
              _newFiles.add(File(file.path!));
            }
          }
        });
      }
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      final img = _existingImages[index];
      if (img.id != null) {
        _deletedImageIds.add(img.id!);
      }
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newNames.removeAt(index);
      if (kIsWeb) {
        _newBytes.removeAt(index);
      } else {
        _newFiles.removeAt(index);
      }
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
        // 1. Hapus gambar yang dihapus user dari DB
        if (_deletedImageIds.isNotEmpty) {
           await Supabase.instance.client
               .from('kegiatan_img')
               .delete()
               .filter('id', 'in', _deletedImageIds);
        }

        // 2. Upload gambar baru
        if (_newNames.isNotEmpty) {
          await _kegiatanService.uploadMultipleImages(
            idKegiatan: widget.kegiatan.id!,
            files: kIsWeb ? null : _newFiles,
            bytesList: kIsWeb ? _newBytes : null,
            fileNames: _newNames.map((n) => '${DateTime.now().millisecondsSinceEpoch}_$n').toList(),
          );
        }

        // 3. Update data kegiatan (teks)
        // Kita set 'hasDocs' true jika ada gambar tersisa (lama atau baru)
        bool hasImages = _existingImages.isNotEmpty || _newNames.isNotEmpty;

        final updatedKegiatan = widget.kegiatan.copyWith(
          judul: _namaController.text,
          kategori: _selectedKategori!,
          tanggal: _selectedDate!,
          lokasi: _lokasiController.text,
          pj: _pjController.text,
          deskripsi: _deskripsiController.text,
          hasDocs: hasImages,
          gambarDokumentasi: null, // Legacy field, biarkan null atau tidak diubah
        );

        final result = await _kegiatanService.updateKegiatan(
          widget.kegiatan.id!,
          updatedKegiatan,
        );

        if (mounted) {
          await showResultModal(
            context,
            type: ResultType.success,
            title: 'Berhasil',
            description: 'Perubahan kegiatan berhasil disimpan.',
            actionLabel: 'Selesai',
            autoProceed: true,
          );
          if (mounted) {
            context.pop(result);
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        await showResultModal(
          context,
          type: ResultType.error,
          title: 'Gagal',
          description: 'Gagal memperbarui kegiatan: $e',
          actionLabel: 'Tutup',
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

  @override
  Widget build(BuildContext context) {
    const Color simpanColor = ConstantColors.primary;
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
                    key: const Key('edit_nama_kegiatan_field'),
                  ),
                  const Text(
                    'Pilih Kategori',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: const Key('edit_kategori_kegiatan_dropdown'),
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
                    key: const Key('edit_tanggal_kegiatan_field'),
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.grey,
                    ),
                  ),
                  _buildTextField(
                    'Lokasi',
                    _lokasiController,
                    'Masukkan Lokasi',
                    key: const Key('edit_lokasi_kegiatan_field'),
                    isRequired: false,
                  ),
                  _buildTextField(
                    'Penanggung Jawab',
                    _pjController,
                    'Masukkan Penanggung Jawab',
                    key: const Key('edit_pj_kegiatan_field'),
                  ),
                  _buildTextField(
                    'Deskripsi',
                    _deskripsiController,
                    'Tulis detail event...',
                    key: const Key('edit_deskripsi_kegiatan_field'),
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
                    'Maksimal 10 gambar (.png / .jpg), ukuran maksimal 5MB.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  
                  // Area Gambar Horizontal
                  if (_existingImages.isNotEmpty || _newNames.isNotEmpty)
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        // Total item = existing + new + 1 (tombol add jika < 10)
                        itemCount: _existingImages.length + _newNames.length + 
                                   ((_existingImages.length + _newNames.length < 10) ? 1 : 0),
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          // 1. Tombol Add di paling akhir
                          if (index == _existingImages.length + _newNames.length) {
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

                          // 2. Existing Images
                          if (index < _existingImages.length) {
                            final img = _existingImages[index];
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    img.img,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 150, height: 150,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 4, top: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeExistingImage(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          // 3. New Images
                          final newIndex = index - _existingImages.length;
                          final imageBytes = kIsWeb ? _newBytes[newIndex] : null;
                          final imageFile = !kIsWeb ? _newFiles[newIndex] : null;

                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: kIsWeb
                                    ? Image.memory(
                                        imageBytes!,
                                        width: 150, height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        imageFile!,
                                        width: 150, height: 150,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                right: 4, top: 4,
                                child: GestureDetector(
                                  onTap: () => _removeNewImage(newIndex),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
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
                              'Ketuk untuk upload/ganti foto',
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
                            key: const Key('simpan_edit_kegiatan_button'),
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