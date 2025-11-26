import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WargaEditKirimanScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const WargaEditKirimanScreen({super.key, required this.data});

  @override
  State<WargaEditKirimanScreen> createState() => _WargaEditKirimanScreenState();
}

class _WargaEditKirimanScreenState extends State<WargaEditKirimanScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulController;
  late final TextEditingController _isiController;
  
  static const Color _primaryColor = Color(0xFF6366F1); 

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.data['judul'] ?? '');
    _isiController = TextEditingController(text: widget.data['deskripsi'] ?? widget.data['isi'] ?? '');
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'id': widget.data['id'] ?? 'unknown',
        'judul': _judulController.text,
        'deskripsi': _isiController.text,
        'isi': _isiController.text,
        'status': 'Pending',
        'type': 'updated',
        'pengirim': widget.data['pengirim'], 
        'tanggal': widget.data['tanggal'], 
      };
            
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kiriman berhasil diperbarui!'),
          backgroundColor: Color.fromARGB(255, 142, 143, 142),
        ),
      );
      context.pop(updatedData); 
    }
  }

  void _resetForm() {
    setState(() {
      _judulController.text = widget.data['judul'] ?? '';
      _isiController.text = widget.data['deskripsi'] ?? widget.data['isi'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Pesan Warga',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // JUDUL PESAN
              const Text(
                'Judul Pesan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(
                  hintText: 'Masukkan judul pesan',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),

              // ISI PESAN
              const Text(
                'Isi Pesan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _isiController,
                maxLines: 8, 
                decoration: InputDecoration(
                  hintText: 'Tulis isi pesan di sini...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Isi pesan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 32),

              // TOMBOL AKSI
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: _submitForm, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor, 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: _resetForm, 
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Reset', style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}