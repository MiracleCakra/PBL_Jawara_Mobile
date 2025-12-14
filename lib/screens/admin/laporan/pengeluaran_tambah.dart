import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/laporan_keuangan_model.dart';
import 'package:moon_design/moon_design.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PengeluaranTambahScreen extends StatefulWidget {
  const PengeluaranTambahScreen({super.key});

  @override
  State<PengeluaranTambahScreen> createState() =>
      _PengeluaranTambahScreenState();
}

class _PengeluaranTambahScreenState extends State<PengeluaranTambahScreen> {
  LaporanKeuanganModel laporankeuanganmodel = LaporanKeuanganModel(
    tanggal: DateTime.now(),
    nama: "",
    nominal: 0,
    kategoriPengeluaran: '',
    buktiFoto: '',
  );

  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nominalController = TextEditingController();
  final _tanggalController = TextEditingController();
  KategoriPengeluaran? _selectedKategoriPengeluaran;
  DateTime? _selectedDate;
  String? _buktiFotoPath;
  final ImagePicker _picker = ImagePicker();

  // --- FUNGSI DIALOG MODAL BERHASIL ---
  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User tidak bisa tap di luar untuk menutup
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Agar dialog menyesuaikan konten
              children: [
                // Icon Centang Hijau
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50, // Latar hijau muda
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Judul Berhasil
                const Text(
                  'Berhasil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Pengeluaran berhasil ditambahkan.', // Pesan sukses
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Selesai
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup Dialog
                      // Kembali ke halaman sebelumnya setelah menutup dialog
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1), // Warna Ungu
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _buktiFotoPath = image.path;
        });
        if (mounted)
          Navigator.pop(context); // Close bottom sheet after selecting
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
      }
    }
  }

  // Fungsi untuk mengunggah foto ke Supabase
  Future<String?> _uploadFoto(XFile image) async {
    try {
      // Simulate heavy upload task
      await Future.delayed(const Duration(seconds: 1));
      
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = 'foto-pengeluaran/$fileName';

      await Supabase.instance.client.storage
          .from('foto-pengeluaran')
          .upload(
            filePath,
            File(image.path),
            fileOptions: FileOptions(contentType: image.mimeType),
          );
      final imageUrl = Supabase.instance.client.storage
          .from('foto-pengeluaran')
          .getPublicUrl(filePath);
      return imageUrl;
    } on StorageException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengunggah foto, Silakan coba lagi.')),
        );
        debugPrint('error: $e');
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengunggah foto: $e')));
      }
      debugPrint('error: $e');
      return null;
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF6366F1)),
                title: const Text('Kamera'),
                onTap: () => _pickImageFromSource(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF6366F1),
                ),
                title: const Text('Galeri'),
                onTap: () => _pickImageFromSource(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNGSI SIMPAN DENGAN LOGIKA NAVIGASI BARU ---
  void _simpanPengeluaran() async {
    if (_formKey.currentState!.validate()) {
      // Periksa apakah kategori sudah dipilih
      if (_selectedKategoriPengeluaran == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon pilih Kategori pengeluaran')),
        );
        return;
      }
      // Periksa apakah foto bukti sudah diunggah
      if (_buktiFotoPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon unggah Bukti Pengeluaran')),
        );
        return;
      }
      
      // Upload foto sebelum menyimpan data
      final XFile image = XFile(_buktiFotoPath!);
      final imageUrl = await _uploadFoto(image);

      if (imageUrl != null) {
        // Simpan data ke database
        laporankeuanganmodel.savePengeluaran(
          _namaController.text,
          double.tryParse(_nominalController.text) ?? 0,
          _selectedKategoriPengeluaran?.value ?? '',
          imageUrl,
          _selectedDate ?? DateTime.now(),
          Supabase.instance.client.auth.currentUser?.email ?? '',
        );

        // Hapus SnackBar lama dan tampilkan Dialog Sukses
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSuccessDialog();
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nominalController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: Text(
          "Tambah Pengeluaran",
          style: MoonTokens.light.typography.heading.text20.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Pengeluaran
                      const Text(
                        'Nama Pengeluaran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _namaController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama pengeluaran',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF6366F1),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama pengeluaran tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Tanggal Pengeluaran
                      const Text(
                        'Tanggal Pengeluaran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tanggalController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: '--/--/----',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF6366F1),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_selectedDate != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDate = null;
                                      _tanggalController.clear();
                                    });
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.calendar_today, size: 18),
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedDate = picked;
                                      _tanggalController.text =
                                          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Kategori pengeluaran
                      const Text(
                        'Kategori pengeluaran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<KategoriPengeluaran>(
                        value: _selectedKategoriPengeluaran,
                        onChanged: (KategoriPengeluaran? newValue) {
                          setState(() {
                            _selectedKategoriPengeluaran = newValue;
                          });
                        },
                        items: KategoriPengeluaran.values
                            .map<DropdownMenuItem<KategoriPengeluaran>>((
                                KategoriPengeluaran value,
                            ) {
                              return DropdownMenuItem<KategoriPengeluaran>(
                                value: value,
                                child: Text(value.value),
                              );
                            })
                            .toList(),
                        decoration: InputDecoration(
                          hintText: 'Pilih kategori pengeluaran',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Kategori pengeluaran tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Nominal
                      const Text(
                        'Nominal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nominalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nominal',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF6366F1),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nominal tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Bukti Pengeluaran
                      const Text(
                        'Bukti Pengeluaran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showImageSourcePicker,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _buktiFotoPath == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Upload bukti pengeluaran (.png/.jpg)',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap untuk memilih foto',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_buktiFotoPath!),
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: InkWell(
                                        onTap: () =>
                                            setState(() => _buktiFotoPath = null),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF6366F1),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _simpanPengeluaran, // Panggil fungsi simpan yang baru
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}