import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/store_model.dart';
import 'package:jawara_pintar_kel_5/providers/marketplace/store_provider.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/store_service.dart';
import 'package:jawara_pintar_kel_5/widget/marketplace/custom_dialog.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditStoreProfileScreen extends StatefulWidget {
  const EditStoreProfileScreen({super.key});

  @override
  State<EditStoreProfileScreen> createState() => _EditStoreProfileScreenState();
}

class _EditStoreProfileScreenState extends State<EditStoreProfileScreen> {
  static const Color primaryColor = Color(0xFF6A5AE0);

  String _storeName = '';
  String _storeDescription = '';
  String _storePhone = '';
  String _storeAddress = '';
  String? _storeImageUrl;
  int? _storeId;
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    setState(() => _isLoading = true);

    try {
      // Get warga.id from email
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser?.email == null) {
        throw Exception('User tidak login');
      }

      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', authUser!.email!)
          .maybeSingle();

      if (wargaResponse == null) {
        throw Exception('Data warga tidak ditemukan');
      }

      final userId = wargaResponse['id'].toString();

      // Get store data using service directly
      final storeService = StoreService();
      final store = await storeService.getStoreByUserId(userId);

      if (store != null && mounted) {
        setState(() {
          _storeId = store.storeId;
          _storeName = store.nama ?? '';
          _storeDescription = store.deskripsi ?? '';
          _storePhone = store.kontak ?? '';
          _storeAddress = store.alamat ?? '';
          _storeImageUrl = store.logo;
          _isLoading = false;
        });
      } else {
        throw Exception('Toko tidak ditemukan');
      }
    } catch (e) {
      print('Error loading store data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.show(
          context: context,
          message: 'Gagal memuat data toko: $e',
          type: DialogType.error,
        );
      }
    }
  }

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

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih sumber gambar'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Kamera'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('Galeri'),
          ),
        ],
      ),
    );
  }

  void _saveChanges(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      CustomSnackbar.show(
        context: context,
        message: 'Terdapat input yang belum valid. Mohon periksa lagi...',
        type: DialogType.warning,
      );
      return;
    }

    if (_storeId == null) {
      CustomSnackbar.show(
        context: context,
        message: 'Data toko tidak valid',
        type: DialogType.error,
      );
      return;
    }

    _formKey.currentState!.save();

    try {
      final updatedStore = StoreModel(
        storeId: _storeId,
        nama: _storeName,
        deskripsi: _storeDescription,
        kontak: _storePhone,
        alamat: _storeAddress,
        logo: _pickedImage != null
            ? 'local:${_pickedImage!.path}' // TODO: Upload to Supabase Storage
            : _storeImageUrl,
      );

      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      await storeProvider.updateStore(_storeId!, updatedStore);

      if (mounted) {
        CustomDialog.show(
          context: context,
          type: DialogType.success,
          title: 'Berhasil!',
          message: 'Profil toko berhasil diperbarui!',
          buttonText: 'OK',
          onConfirm: () {
            Navigator.pop(context, 'updated');
          },
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.show(
          context: context,
          type: DialogType.error,
          title: 'Gagal Menyimpan',
          message: 'Gagal menyimpan perubahan: $e',
          buttonText: 'Coba Lagi',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profil Toko',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data toko...'),
                ],
              ),
            )
          : Form(
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

                  ElevatedButton(
                    onPressed: () => _saveChanges(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
              color: Color(0xFF1F2937),
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
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarEdit() {
    final imageWidget = _pickedImage != null
        ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
        : (_storeImageUrl != null
              ? Image.network(_storeImageUrl!, fit: BoxFit.cover)
              : const Icon(Icons.store, size: 50, color: primaryColor));

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: primaryColor.withOpacity(0.2),
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
                  color: primaryColor,
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
