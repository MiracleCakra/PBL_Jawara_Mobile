import 'dart:io';
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/broadcast_model.dart';
import 'package:jawara_pintar_kel_5/services/broadcast_service.dart';
import 'package:jawara_pintar_kel_5/widget/moon_result_modal.dart';

class EditBroadcastScreen extends StatefulWidget {
  final BroadcastModel broadcast;
  const EditBroadcastScreen({Key? key, required this.broadcast})
    : super(key: key);

  @override
  State<EditBroadcastScreen> createState() => _EditBroadcastScreenState();
}

class _EditBroadcastScreenState extends State<EditBroadcastScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final BroadcastService _broadcastService = BroadcastService();

  // Variabel untuk menyimpan file baru jika diunggah dan lama
  XFile? _newPhoto;
  PlatformFile? _newDocument;
  String? _existingPhotoUrl;
  String? _existingDocUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.broadcast.judul);
    _contentController = TextEditingController(text: widget.broadcast.konten);
    _existingPhotoUrl = widget.broadcast.lampiranGambarUrl;
    _existingDocUrl = widget.broadcast.lampiranDokumenUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) setState(() => _newPhoto = image);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result != null) setState(() => _newDocument = result.files.single);
    } catch (e) {
      // Handle error
    }
  }

  void _removePhoto() {
    setState(() {
      _newPhoto = null;
      _existingPhotoUrl = null;
    });
  }

  void _removeDocument() {
    setState(() {
      _newDocument = null;
      _existingDocUrl = null;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String? finalPhotoUrl = _existingPhotoUrl;
        String? finalDocUrl = _existingDocUrl;

        if (_newPhoto != null) {
          final bytes = await _newPhoto!.readAsBytes();
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_update_${_newPhoto!.name}';
          finalPhotoUrl = await _broadcastService.uploadFile(
            bytes: bytes,
            file: kIsWeb ? null : File(_newPhoto!.path),
            fileName: fileName,
            folderName: 'images',
            contentType: 'image/jpeg',
          );
        }

        if (_newDocument != null) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_update_${_newDocument!.name}';
          finalDocUrl = await _broadcastService.uploadFile(
            bytes: _newDocument!.bytes,
            file: kIsWeb ? null : File(_newDocument!.path!),
            fileName: fileName,
            folderName: 'documents',
            contentType: 'application/pdf',
          );
        }

        final updatedBroadcast = widget.broadcast.copyWith(
          judul: _titleController.text,
          konten: _contentController.text,
          lampiranGambarUrl: finalPhotoUrl,
          lampiranDokumenUrl: finalDocUrl,
        );

        await _broadcastService.updateBroadcast(
          widget.broadcast.id!,
          updatedBroadcast,
        );

        if (!mounted) return;
        await showResultModal(
          context,
          type: ResultType.success,
          title: 'Berhasil',
          description: 'Perubahan broadcast berhasil disimpan.',
          actionLabel: 'Selesai',
          autoProceed: true,
        );
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (!mounted) return;
        await showResultModal(
          context,
          type: ResultType.error,
          title: 'Gagal',
          description: 'Gagal menyimpan perubahan: $e',
          actionLabel: 'Tutup',
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Broadcast"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                key: const Key('edit_judul_broadcast_field'),
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Masukkan Judul',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              const Text(
                'Isi Broadcast',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('edit_isi_broadcast_field'),
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Tulis isi broadcast...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Isi wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // --- UPLOAD FOTO ---
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

              if (_newPhoto != null)
                // Tampilkan Foto Baru
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: kIsWeb 
                        ? Image.network(_newPhoto!.path, width: double.infinity, height: 200, fit: BoxFit.cover)
                        : Image.file(File(_newPhoto!.path), width: double.infinity, height: 200, fit: BoxFit.cover),
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
              else if (_existingPhotoUrl != null)
                // Tampilkan Foto Lama
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        _existingPhotoUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
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
                // Tombol Upload
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

              // --- UPLOAD DOKUMEN ---
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

              if (_newDocument != null)
                // Dokumen Baru
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
                          _newDocument!.name,
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
              else if (_existingDocUrl != null)
                // Dokumen Lama
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dokumen Tersimpan',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _existingDocUrl!.split('/').last, // Try to show filename
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
                // Tombol Upload
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade500,
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
                        key: const Key('simpan_edit_broadcast_button'),
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ConstantColors.primary,
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
            ],
          ),
        ),
      ),
    );
  }
}