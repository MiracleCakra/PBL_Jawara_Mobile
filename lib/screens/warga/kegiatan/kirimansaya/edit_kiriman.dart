import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/aspirasi_model.dart';
import 'package:SapaWarga_kel_2/services/aspirasi_service.dart';
import 'package:SapaWarga_kel_2/widget/moon_result_modal.dart';

class WargaEditKirimanScreen extends StatefulWidget {
  final AspirasiModel data;

  const WargaEditKirimanScreen({super.key, required this.data});

  @override
  State<WargaEditKirimanScreen> createState() => _WargaEditKirimanScreenState();
}

class _WargaEditKirimanScreenState extends State<WargaEditKirimanScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulController;
  late final TextEditingController _isiController;
  final AspirasiService _aspirasiService = AspirasiService();
  bool _isLoading = false;

  static const Color _primaryColor = Color(
    0xFF6366F1,
  ); // Biru utama sama seperti di halaman kegiatan

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.data.judul);
    _isiController = TextEditingController(text: widget.data.isi);
  }

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

      final updatedAspirasi = widget.data.copyWith(
        judul: _judulController.text,
        isi: _isiController.text,
      );

      try {
        await _aspirasiService.updateAspiration(updatedAspirasi);
        if (mounted) {
          await showResultModal(
            context,
            type: ResultType.success,
            title: 'Berhasil',
            description: 'Kiriman berhasil diperbarui!',
            actionLabel: 'Selesai',
            autoProceed: true,
          );
          if (mounted) context.pop(true);
        }
      } catch (e) {
        if (mounted) {
          await showResultModal(
            context,
            type: ResultType.error,
            title: 'Gagal',
            description: 'Gagal memperbarui: $e',
            actionLabel: 'Tutup',
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
    _judulController.text = widget.data.judul;
    _isiController.text = widget.data.isi;
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
                key: const Key('edit_judul_aspirasi'),
                controller: _judulController,
                decoration: InputDecoration(
                  hintText: 'Masukkan judul pesan',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Judul tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 24),

              // ISI PESAN
              const Text(
                'Isi Pesan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('edit_isi_aspirasi'),
                controller: _isiController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Tulis isi pesan di sini...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Isi pesan tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 32),

              // TOMBOL AKSI
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      key: const Key('btn_save_edit_aspirasi'),
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
