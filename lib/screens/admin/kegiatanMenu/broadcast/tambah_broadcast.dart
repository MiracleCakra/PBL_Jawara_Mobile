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

  // WidgetArea Upload File
  Widget _buildUploadArea(String label, String helpText, VoidCallback onTap, bool isSelected, String? fileName) {
    // ... UI Sama ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(helpText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10.0),
              border: isSelected ? Border.all(color: Colors.green, width: 2) : null, 
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isSelected ? Icons.check : Icons.upload_file, color: isSelected ? Colors.green : Colors.grey),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isSelected ? (fileName ?? 'File Terpilih') : 'Upload $label', 
                      style: TextStyle(
                        color: isSelected ? Colors.green : Colors.grey.shade700, 
                        fontWeight: FontWeight.w500
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isSelected) 
           Padding(
             padding: const EdgeInsets.only(top: 4.0),
             child: InkWell(
               onTap: () {
                 setState(() {
                   if (label == 'Foto') _selectedPhoto = null;
                   if (label == 'Dokumen') _selectedDocument = null;
                 });
               },
               child: const Text("Hapus", style: TextStyle(color: Colors.red, fontSize: 12)),
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
              const Text(
                'Judul Broadcast',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
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

              // ISI broadcst
              const Text(
                'Isi Broadcast',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
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

              //foto
              _buildUploadArea(
                'Foto',
                'Maksimal 1 gambar (.png / .jpg), max 5MB.',
                _pickPhoto,
                _selectedPhoto != null,
                _selectedPhoto?.name,
              ),

              _buildUploadArea(
                'Dokumen',
                'Maksimal 1 file PDF, max 5MB.',
                _pickDocument,
                _selectedDocument != null,
                _selectedDocument?.name,
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 16),
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