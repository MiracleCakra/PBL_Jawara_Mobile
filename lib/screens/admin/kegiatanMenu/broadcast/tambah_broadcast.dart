import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:file_picker/file_picker.dart'; 

class TambahBroadcastScreen extends StatefulWidget {
  const TambahBroadcastScreen({super.key});

  @override
  State<TambahBroadcastScreen> createState() => _TambahBroadcastScreenState();
}

class _TambahBroadcastScreenState extends State<TambahBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  List<XFile> _selectedPhotos = [];
  List<PlatformFile> _selectedDocuments = [];

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }
  

  // Foto (Max 10)
  Future<void> _pickPhotos() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _selectedPhotos = images.take(10).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih foto.')),
      );
    }
  }

  // Dokumen
  Future<void> _pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedDocuments = result.files.take(10).toList();
        });
      }
    } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih dokumen.')),
      );
    }
  }

  // Simpan Broadcast
  void _simpanBroadcast() {
    if (_formKey.currentState!.validate()) {
      final newBroadcast = {
        'judul': _judulController.text,
        'isi': _isiController.text,
        'foto_files': _selectedPhotos.map((f) => f.path).toList(),
        'dokumen_files': _selectedDocuments.map((f) => f.path).toList(),
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Broadcast "${newBroadcast['judul']}" berhasil dibuat!')),
      );
      Navigator.pop(context, newBroadcast);
    }
  }

  // batal
  void _batalForm() {
    Navigator.pop(context);
  }

  // WidgetArea Upload File
  Widget _buildUploadArea(String label, String helpText, VoidCallback onTap, int count) {
    String buttonText;
    bool isDocument = label == 'Dokumen';
        if (count > 0) {
        buttonText = isDocument ? '$count dokumen terpilih' : '$count foto terpilih';
    } else {
        buttonText = isDocument ? 'Upload Dokumen pdf' : 'Upload Foto png/jpg';
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          helpText,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10.0),
              border: count > 0 ? Border.all(color: Colors.green, width: 2) : null, 
            ),
            child: Center(
              child: Text(
                buttonText, 
                style: TextStyle(
                  color: count > 0 ? Colors.green : Colors.grey.shade700, 
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
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
                'Maksimal 10 gambar (.png / .jpg), ukuran maksimal 5MB per gambar.',
                _pickPhotos,
                _selectedPhotos.length, 
              ),

              //dokumen
              _buildUploadArea(
                'Dokumen',
                'Maksimal 10 file (pdf), ukuran maksimal 5MB per file.',
                _pickDocuments,
                _selectedDocuments.length,
              ),

              const SizedBox(height: 16),

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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _simpanBroadcast,
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
          