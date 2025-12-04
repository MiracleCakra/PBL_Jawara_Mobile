import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/channel_transfer_model.dart';
import 'package:jawara_pintar_kel_5/services/channel_transfer_service.dart';

class TambahChannelPage extends StatefulWidget {
  const TambahChannelPage({super.key});

  @override
  State<TambahChannelPage> createState() => _TambahChannelPageState();
}

class _TambahChannelPageState extends State<TambahChannelPage> {
  final Color primary = const Color(0xFF4E46B4);
  final _channelService = ChannelTransferService();
  bool _isLoading = false;

  // Controllers
  final _namaChannelCtl = TextEditingController();
  final _nomorRekeningCtl = TextEditingController();
  final _namaPemilikCtl = TextEditingController();
  final _catatanCtl = TextEditingController();

  // Dropdown state & QR image
  String? _tipeChannel;
  XFile? _qrImageFile;

  @override
  void dispose() {
    _namaChannelCtl.dispose();
    _nomorRekeningCtl.dispose();
    _namaPemilikCtl.dispose();
    _catatanCtl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _namaChannelCtl.clear();
      _nomorRekeningCtl.clear();
      _namaPemilikCtl.clear();
      _catatanCtl.clear();
      _tipeChannel = null;
      _qrImageFile = null;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final size = await image.length();
        if (size > 2 * 1024 * 1024) {
           if (!mounted) return;
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Ukuran gambar maksimal 2MB")),
           );
           return;
        }
        setState(() {
          _qrImageFile = image;
        });
      }
    } catch (e) {
      debugPrint("Gagal pick image: $e");
    }
  }

  Future<void> _saveData() async {
    if (_namaChannelCtl.text.isEmpty || _tipeChannel == null || _nomorRekeningCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi data wajib (Nama, Tipe, No. Rek)')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      String? qrImageUrl;
      if (_tipeChannel == 'QRIS' && _qrImageFile != null) {
        final bytes = await _qrImageFile!.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_qrImageFile!.name}';
        
        qrImageUrl = await _channelService.uploadQrImage(
          bytes: bytes,
          file: kIsWeb ? null : File(_qrImageFile!.path),
          fileName: fileName,
        );
      }

      final newChannel = ChannelTransferModel(
        nama: _namaChannelCtl.text,
        tipe: _tipeChannel!,
        norek: _nomorRekeningCtl.text,
        pemilik: _namaPemilikCtl.text,
        catatan: _catatanCtl.text,
        qrisImg: qrImageUrl,
      );

      await _channelService.createChannel(newChannel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Channel berhasil disimpan!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Tambah Transfer Channel',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Nama Channel',
                controller: _namaChannelCtl,
                hint: 'Contoh : BCA, Dana, Qris',
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Tipe',
                value: _tipeChannel,
                hint: 'Pilih tipe',
                items: const [
                  DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                  DropdownMenuItem(value: 'E-Wallet', child: Text('E-Wallet')),
                  DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipeChannel = value;
                    if (_tipeChannel != 'QRIS') _qrImageFile = null; // reset QR jika bukan QRIS
                  });
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Nomor Rekening / Akun',
                controller: _nomorRekeningCtl,
                hint: 'Contoh : 1234567890',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Nama Pemilik',
                controller: _namaPemilikCtl,
                hint: 'Contoh : John Doe',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Catatan',
                controller: _catatanCtl,
                hint: 'Contoh : Transfer hanya dari bank yang sama',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Upload QR hanya jika tipe QRIS
              if (_tipeChannel == 'QRIS')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Gambar QR (opsional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _qrImageFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_outlined, size: 50, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap untuk pilih gambar QR',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb 
                                  ? Image.network(_qrImageFile!.path, fit: BoxFit.cover) // Di web path = blob url
                                  : Image.file(File(_qrImageFile!.path), fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _reset,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _saveData,
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
