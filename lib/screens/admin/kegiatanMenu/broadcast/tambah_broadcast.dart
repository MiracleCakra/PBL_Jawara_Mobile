import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:file_picker/file_picker.dart'; 
import 'package:jawara_pintar_kel_5/models/kegiatan/broadcast_model.dart';
import 'package:jawara_pintar_kel_5/services/broadcast_service.dart';

class TambahBroadcastScreen extends StatefulWidget {
  const TambahBroadcastScreen({super.key});

  @override
  State<TambahBroadcastScreen> createState() => _TambahBroadcastScreenState();
}

class _TambahBroadcastScreenState extends State<TambahBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  XFile? _selectedPhoto; 
  PlatformFile? _selectedDocument;
  bool _isLoading = false;
  final BroadcastService _broadcastService = BroadcastService();

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }
  

  // Foto
  Future<void> _pickPhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Validasi size manual bisa ditambahkan disini (readAsBytes lalu length)
        setState(() {
          _selectedPhoto = image;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Gagal memilih foto.'), backgroundColor: Colors.grey.shade800),
      );
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true, // PENTING: Supaya bytes terbaca di Web
      );
      if (result != null) {
        final file = result.files.single;
        if (file.size > 5 * 1024 * 1024) { // 5MB Limit
           if (!mounted) return;
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("File max 5MB"), backgroundColor: Colors.grey.shade800));
           return;
        }
        setState(() {
          _selectedDocument = file;
        });
      }
    } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Gagal memilih dokumen.'), backgroundColor: Colors.grey.shade800),
      );
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedPhoto = null;
    });
  }

  void _removeDocument() {
    setState(() {
      _selectedDocument = null;
    });
  }

  void _simpanBroadcast() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String? imageUrl;
        String? docUrl;

        if (_selectedPhoto != null) {
          final bytes = await _selectedPhoto!.readAsBytes();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedPhoto!.name}';
          
          // Upload platform-aware
          if (kIsWeb) {
            imageUrl = await _broadcastService.uploadFile(
              bytes: bytes,
              file: null,
              fileName: fileName,
              folderName: 'images',
              contentType: 'image/jpeg',
            );
          } else {
            imageUrl = await _broadcastService.uploadFile(
              bytes: bytes,
              file: File(_selectedPhoto!.path),
              fileName: fileName,
              folderName: 'images',
              contentType: 'image/jpeg',
            );
          }
        }

        if (_selectedDocument != null) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedDocument!.name}';
          
          docUrl = await _broadcastService.uploadFile(
            bytes: _selectedDocument!.bytes,
            file: kIsWeb ? null : File(_selectedDocument!.path!),
            fileName: fileName,
            folderName: 'documents',
            contentType: 'application/pdf',
          );
        }

        final newBroadcast = BroadcastModel(
          judul: _judulController.text,
          konten: _isiController.text,
          pengirim: 'Admin Jawara',
          kategori: 'Pemberitahuan',
          tanggal: DateTime.now(),
          lampiranGambarUrl: imageUrl,
          lampiranDokumenUrl: docUrl,
        );

        await _broadcastService.createBroadcast(newBroadcast);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Broadcast berhasil dibuat!'), backgroundColor: Colors.grey.shade800),
        );
        Navigator.pop(context, true);

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.grey.shade800),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _batalForm() {
    Navigator.pop(context);
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
          'Buat Broadcast Baru',
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
              const Text(
                'Judul Broadcast',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('judul_broadcast_field'),
                controller: _judulController,
                decoration: InputDecoration(
                  hintText: 'Masukkan Judul Broadcast',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul Broadcast wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ISI
              const Text(
                'Isi Broadcast',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('isi_broadcast_field'),
                controller: _isiController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Tulis isi broadcast...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Isi Broadcast wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- UPLOAD FOTO (Style: Kegiatan) ---
              const Text(
                'Upload Dokumentasi (Foto)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                'Maksimal 1 gambar (.png / .jpg), max 5MB.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              
              if (_selectedPhoto != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: kIsWeb 
                        ? Image.network(_selectedPhoto!.path, width: double.infinity, height: 200, fit: BoxFit.cover) // XFile on Web usually has blob url in path
                        : Image.file(File(_selectedPhoto!.path), width: double.infinity, height: 200, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: _removePhoto,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              else
                InkWell(
                  onTap: _pickPhoto,
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
                        Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Ketuk untuk upload foto',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // --- UPLOAD DOKUMEN (Style: Kegiatan-ish) ---
              const Text(
                'Upload Dokumen (PDF)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                'Maksimal 1 file PDF, max 5MB.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),

              if (_selectedDocument != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDocument!.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: _removeDocument,
                      ),
                    ],
                  ),
                )
              else
                InkWell(
                  onTap: _pickDocument,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Ketuk untuk upload dokumen',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // TOMBOL
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _batalForm,
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('simpan_broadcast_button'),
                        onPressed: _isLoading ? null : _simpanBroadcast,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: simpanColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
