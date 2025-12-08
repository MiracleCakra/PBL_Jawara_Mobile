import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/broadcast_model.dart';
import 'package:jawara_pintar_kel_5/services/broadcast_service.dart';

class EditBroadcastScreen extends StatefulWidget {
  final BroadcastModel broadcast;
  const EditBroadcastScreen({Key? key,required this.broadcast,}) : super(key: key);

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
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _newPhoto = image);
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf'], withData: true,
    );
    if (result != null) setState(() => _newDocument = result.files.single);
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String? finalPhotoUrl = _existingPhotoUrl;
        String? finalDocUrl = _existingDocUrl;

        if (_newPhoto != null) {
          final bytes = await _newPhoto!.readAsBytes();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_update_${_newPhoto!.name}';
          finalPhotoUrl = await _broadcastService.uploadFile(
            bytes: bytes,
            file: kIsWeb ? null : File(_newPhoto!.path),
            fileName: fileName,
            folderName: 'images',
            contentType: 'image/jpeg',
          );
        }

        if (_newDocument != null) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_update_${_newDocument!.name}';
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

        await _broadcastService.updateBroadcast(widget.broadcast.id!, updatedBroadcast);
        
        if (!mounted) return;
        Navigator.pop(context, true);

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildFileStatus(String label, bool isNewSelected, String? existingUrl, VoidCallback onPick, VoidCallback onClear) {
    bool hasFile = isNewSelected || (existingUrl != null);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPick,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: hasFile ? Colors.blue : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(hasFile ? Icons.check_circle : Icons.upload_file, color: hasFile ? Colors.blue : Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isNewSelected ? 'File Baru Terpilih (Siap Upload)' 
                    : (existingUrl != null ? 'File Lama Tersimpan' : 'Belum ada file'),
                    style: TextStyle(color: hasFile ? Colors.black87 : Colors.grey),
                  ),
                ),
                if (hasFile)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onClear, // Hapus file (jadi null)
                  )
              ],
            ),
          ),
        ),
        if (existingUrl != null && !isNewSelected && label == 'Foto')
           Padding(
             padding: const EdgeInsets.only(top: 8.0),
             child: Image.network(existingUrl, height: 100, width: 100, fit: BoxFit.cover),
           ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Broadcast"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Isi', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib' : null,
              ),
              const SizedBox(height: 24),

              // --- FILE HANDLERS ---
              _buildFileStatus(
                'Foto Lampiran',
                _newPhoto != null,
                _existingPhotoUrl,
                _pickPhoto,
                () => setState(() { _newPhoto = null; _existingPhotoUrl = null; }),
              ),

              _buildFileStatus(
                'Dokumen PDF',
                _newDocument != null,
                _existingDocUrl,
                _pickDocument,
                () => setState(() { _newDocument = null; _existingDocUrl = null; }),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Simpan Perubahan"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}