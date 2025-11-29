import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:jawara_pintar_kel_5/models/warga_tagihan_model.dart';

class FormPembayaranScreen extends StatefulWidget {
  final WargaTagihanModel tagihan; // Sudah pakai WargaTagihanModel

  const FormPembayaranScreen({super.key, required this.tagihan});

  @override
  State<FormPembayaranScreen> createState() => _FormPembayaranScreenState();
}

class _FormPembayaranScreenState extends State<FormPembayaranScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final TextEditingController _noteController = TextEditingController();

  // Variabel untuk validasi nominal OCR
  bool _isNominalValid = true;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));

        // Jalankan OCR
        await _scanStrukWithOCR(_imageFile!);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _scanStrukWithOCR(File imageFile) async {
  final inputImage = InputImage.fromFile(imageFile);
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  try {
    final recognizedText = await textRecognizer.processImage(inputImage);
    String scannedText = recognizedText.text;
    debugPrint("Hasil OCR: $scannedText");

    if (scannedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tidak ada teks yang terdeteksi pada gambar."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final regExp = RegExp(r'\d{1,3}(?:[.,]\d{3})*');
    final match = regExp.firstMatch(scannedText);

    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nominal tidak dapat ditemukan di struk."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String scannedAmountStr = match.group(0)!.replaceAll('.', '').replaceAll(',', '');
    double scannedAmount = double.tryParse(scannedAmountStr) ?? 0;

    setState(() {
      _isNominalValid = scannedAmount == widget.tagihan.nominal * 1000;
    });

    if (_isNominalValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nominal struk sesuai dengan tagihan ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Nominal struk tidak sesuai! Tagihan: ${_formatCurrency(widget.tagihan.nominal)}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    debugPrint('OCR Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Terjadi kesalahan saat memproses gambar."),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    textRecognizer.close();
  }
}


  void _submitPayment() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon upload bukti transfer terlebih dahulu"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_isNominalValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nominal struk tidak sesuai tagihan!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 12),
            Text("Berhasil Dikirim", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Bukti pembayaran Anda sedang diverifikasi oleh Bendahara.\nMohon tunggu status berubah dalam 1x24 jam.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Tutup Dialog
              Navigator.pop(context, true); // Kembali ke DetailTagihan
            },
            child: const Text(
              "OK, Mengerti",
              style: TextStyle(color: Color(0xFF4E46B4), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final realAmount = amount * 1000;
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(realAmount);
  }

  @override
  Widget build(BuildContext context) {
    final totalBayar = widget.tagihan.nominal * 1000;
    final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Pembayaran",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black, onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // REKENING TUJUAN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4E46B4), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF4E46B4).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                children: [
                  const Text("Silakan transfer ke:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        child: const Text("BRI", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF00529C))),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "1234-5678-9012-3456",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("a.n Bendahara RW 05 (Budi Santoso)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Bayar:", style: TextStyle(color: Colors.white)),
                      Text(currencyFormatter.format(totalBayar),
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Bukti Transfer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => _showPickerOption(context),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                dashPattern: const [8, 4],
                color: Colors.grey.shade400,
                strokeWidth: 1.5,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: _imageFile != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(width: double.infinity, height: double.infinity, child: Image.file(_imageFile!, fit: BoxFit.cover)),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.edit, color: Colors.white, size: 20)),
                            )
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(color: Color(0xFFF4F3FF), shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, size: 40, color: Color(0xFF4E46B4)),
                            ),
                            const SizedBox(height: 16),
                            const Text("Ketuk untuk upload Struk", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E46B4))),
                            const SizedBox(height: 4),
                            Text("Format JPG/PNG, Max 2MB", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text("Catatan (Opsional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "Contoh: Sudah lunas ya pak",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4E46B4))),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E46B4),
              disabledBackgroundColor: const Color(0xFF4E46B4).withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text("Kirim Bukti Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  void _showPickerOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFF4F3FF), child: Icon(Icons.photo_library, color: Color(0xFF4E46B4))),
                  title: const Text('Ambil dari Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFF4F3FF), child: Icon(Icons.camera_alt, color: Color(0xFF4E46B4))),
                  title: const Text('Ambil Foto Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
