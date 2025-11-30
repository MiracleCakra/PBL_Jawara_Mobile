import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/store_model.dart';

class EditStoreProfileScreen extends StatefulWidget {
  const EditStoreProfileScreen({super.key});

  @override
  State<EditStoreProfileScreen> createState() => _EditStoreProfileScreenState();
}

class _EditStoreProfileScreenState extends State<EditStoreProfileScreen> {
  // Menggunakan warna utama dari FormPembayaranScreen (0xFF4E46B4)
  static const Color _formPrimaryColor = Color(0xFF4E46B4); 
  static const Color _textPrimaryColor = Color(0xFF1F2937);

  String _storeName = 'SSS, Sayur Segar Susanto';
  String _storeDescription =
      'Menyediakan sayuran dan buah segar dari kebun lokal dengan pengiriman cepat ke seluruh RW.';
  String _storePhone = '081234567890';
  String _storeAddress = 'Jl. Anggrek No. 5, Blok C1';
  String? _storeImageUrl;

  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  // Menyesuaikan dialog pemilih gambar agar konsisten dengan style modal di FormPembayaranScreen
  void _showImageSourceDialog() {
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
                  leading: CircleAvatar(backgroundColor: const Color(0xFFF4F3FF), child: const Icon(Icons.photo_library, color: _formPrimaryColor)),
                  title: const Text('Ambil dari Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: CircleAvatar(backgroundColor: const Color(0xFFF4F3FF), child: const Icon(Icons.camera_alt, color: _formPrimaryColor)),
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

  void _saveChanges(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedStore = StoreModel(
        name: _storeName,
        description: _storeDescription,
        phone: _storePhone,
        address: _storeAddress,
        imageUrl: _pickedImage != null
            ? 'local:${_pickedImage!.path}'
            : _storeImageUrl, 
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil toko berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, updatedStore);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terdapat input yang belum valid. Mohon periksa lagi...'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Edit Profil Toko',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAvatarEdit(),
            const SizedBox(height: 20),

            _buildInputField(
              label: "Nama Toko",
              initialValue: _storeName,
              hintText: "Masukkan nama toko Anda",
              validator: (value) =>
                  value!.isEmpty ? 'Nama toko tidak boleh kosong' : null,
              onSaved: (value) => _storeName = value!,
            ),

            _buildInputField(
              label: "Deskripsi Toko",
              initialValue: _storeDescription,
              hintText: "Jelaskan tentang toko dan produk Anda",
              maxLines: 5,
              validator: (value) =>
                  value!.length < 10 ? 'Deskripsi terlalu pendek' : null,
              onSaved: (value) => _storeDescription = value!,
            ),

            _buildInputField(
              label: "Nomor Kontak",
              initialValue: _storePhone,
              hintText: "Contoh: 081222222132",
              keyboardType: TextInputType.phone,
              onSaved: (value) => _storePhone = value!,
            ),

            _buildInputField(
              label: "Alamat Toko",
              initialValue: _storeAddress,
              hintText: "Masukkan alamat lengkap toko",
              maxLines: 3,
              onSaved: (value) => _storeAddress = value!,
            ),

            const SizedBox(height: 30),

            // Tombol Simpan Perubahan
            ElevatedButton(
              onPressed: () => _saveChanges(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _formPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Field Input (Disesuaikan border dan fokus)
  Widget _buildInputField({
    required String label,
    String? initialValue,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 15),
            validator: validator,
            onSaved: onSaved,
            decoration: InputDecoration(
              hintText: hintText,
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // Radius 12 konsisten
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _formPrimaryColor, width: 2), // Warna fokus
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk Edit Avatar (Disesuaikan warna)
  Widget _buildAvatarEdit() {
    final imageWidget = _pickedImage != null
        ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
        : (_storeImageUrl != null
            ? Image.network(_storeImageUrl!, fit: BoxFit.cover)
            : const Icon(Icons.store, size: 50, color: _formPrimaryColor)); // Warna ikon

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: _formPrimaryColor.withOpacity(0.2), // Warna background
            child: ClipOval(
              child: SizedBox(width: 100, height: 100, child: imageWidget),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 109, 101, 220),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}