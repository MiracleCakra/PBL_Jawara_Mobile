import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/channel_transfer_model.dart'; // Sesuaikan path
import 'package:jawara_pintar_kel_5/services/channel_transfer_service.dart';
class EditChannelPage extends StatefulWidget {
  final ChannelTransferModel channelData;

  const EditChannelPage({
    super.key,
    required this.channelData,
  });

  @override
  State<EditChannelPage> createState() => _EditChannelPageState();
}

class _EditChannelPageState extends State<EditChannelPage> {
  final Color primary = const Color(0xFF4E46B4);
  final _channelService = ChannelTransferService();
  bool _isLoading = false;

  // Controllers - Initialize dengan data yang ada
  late final TextEditingController _namaChannelCtl;
  late final TextEditingController _nomorRekeningCtl;
  late final TextEditingController _namaPemilikCtl;
  late final TextEditingController _catatanCtl;

  String? _tipeChannel;
  XFile? _newQrImageFile;
  String? _existingQrUrl;

  @override
  void initState() {
    super.initState();
    _namaChannelCtl = TextEditingController(text: widget.channelData.nama);
    _nomorRekeningCtl = TextEditingController(text: widget.channelData.norek);
    _namaPemilikCtl = TextEditingController(text: widget.channelData.pemilik);
    _catatanCtl = TextEditingController(text: widget.channelData.catatan);
    
    _tipeChannel = widget.channelData.tipe;
    _existingQrUrl = widget.channelData.qrisImg;
  }

  @override
  void dispose() {
    _namaChannelCtl.dispose();
    _nomorRekeningCtl.dispose();
    _namaPemilikCtl.dispose();
    super.dispose();
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
          _newQrImageFile = image;
        });
      }
    } catch (e) {
      debugPrint("Gagal pick image: $e");
    }
  }

  Future<void> _saveChanges() async {
    if (_namaChannelCtl.text.isEmpty || _tipeChannel == null || _nomorRekeningCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi data wajib (Nama, Tipe, No. Rek)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? finalQrUrl = _existingQrUrl;
      if (_tipeChannel == 'QRIS' && _newQrImageFile != null) {
        final bytes = await _newQrImageFile!.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_update_${_newQrImageFile!.name}';
        
        finalQrUrl = await _channelService.uploadQrImage(
          bytes: bytes,
          file: kIsWeb ? null : File(_newQrImageFile!.path),
          fileName: fileName,
        );
      } else if (_tipeChannel != 'QRIS') {
        finalQrUrl = null;
      }

      final updatedChannel = widget.channelData.copyWith(
        nama: _namaChannelCtl.text,
        tipe: _tipeChannel!,
        norek: _nomorRekeningCtl.text,
        pemilik: _namaPemilikCtl.text,
        catatan: _catatanCtl.text,
        qrisImg: finalQrUrl,
      );

      await _channelService.updateChannel(widget.channelData.id!, updatedChannel);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan!'), backgroundColor: Colors.green),
        );
        context.pop(); 
        context.pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: $e'), backgroundColor: Colors.red),
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
          'Edit Transfer Channel',
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
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: 'Tipe',
                value: _tipeChannel,
                items: const [
                  DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                  DropdownMenuItem(value: 'E-Wallet', child: Text('E-Wallet')),
                  DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                ],
                onChanged: (value) => setState(() => _tipeChannel = value),
              ),
              const SizedBox(height: 16),

              _buildTextField(label: 'Nomor Rekening / Akun', controller: _nomorRekeningCtl, keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              _buildTextField(label: 'Nama Pemilik', controller: _namaPemilikCtl),
              const SizedBox(height: 16),
              
              _buildTextField(label: 'Catatan', controller: _catatanCtl),
              const SizedBox(height: 16),

              if (_tipeChannel == 'QRIS')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gambar QR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                        child: _newQrImageFile != null
                            ? ClipRRect( // 1. Gambar Baru Terpilih
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb 
                                  ? Image.network(_newQrImageFile!.path, fit: BoxFit.cover)
                                  : Image.file(File(_newQrImageFile!.path), fit: BoxFit.cover),
                              )
                            : (_existingQrUrl != null // 2. Gambar Lama Ada
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(_existingQrUrl!, width: double.infinity, height: 150, fit: BoxFit.cover),
                                      ),
                                      Center(child: Container(
                                        padding: const EdgeInsets.all(8),
                                        color: Colors.black54,
                                        child: const Text("Tap untuk ganti", style: TextStyle(color: Colors.white)),
                                      ))
                                    ],
                                  )
                                : Column( // 3. Kosong
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                      const Text("Upload Gambar", style: TextStyle(color: Colors.grey))
                                    ],
                                  )
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.pop(),
                      child: Text('Batal', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
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
                      onPressed: _isLoading ? null : _saveChanges,
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}