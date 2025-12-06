import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/aspirasi_model.dart';
import 'package:jawara_pintar_kel_5/services/aspirasi_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WargaTambahAspirasiScreen extends StatefulWidget {
  const WargaTambahAspirasiScreen({super.key});

  @override
  State<WargaTambahAspirasiScreen> createState() =>
      _WargaTambahAspirasiScreenState();
}

class _WargaTambahAspirasiScreenState
    extends State<WargaTambahAspirasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final AspirasiService _aspirasiService = AspirasiService();
  bool _isLoading = false;

  static const Color _primaryColor = Color(0xFF6366F1);

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

    final user = Supabase.instance.client.auth.currentUser;
    final String currentUserId = user?.id ?? '-';
    final String currentUserName = user?.userMetadata?['name'] ?? 'Warga'; 

    final newAspirasi = AspirasiModel(
      judul: _judulController.text,
      isi: _isiController.text,
      pengirim: currentUserName,
      status: 'Pending',
      tanggal: DateTime.now(),
      userId: currentUserId, // Pakai ID asli
    );

      try {
        await _aspirasiService.createAspiration(newAspirasi);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Aspirasi Anda berhasil dikirim!'),
              backgroundColor: Colors.grey.shade800,
            ),
          );
          context.pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengirim aspirasi: $e'),
              backgroundColor: Colors.grey.shade800,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _judulController.clear();
    _isiController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Buat Pesan Warga',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Judul tidak boleh kosong' : null,
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Isi pesan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 32),

              // TOMBOL AKSI
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
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
                          : const Text('Kirim Pesan',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.black87)),
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