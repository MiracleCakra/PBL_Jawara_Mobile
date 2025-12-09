import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'package:jawara_pintar_kel_5/services/warga_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final WargaService _wargaService = WargaService();
  
  // Controllers
  late TextEditingController _namaController;
  late TextEditingController _teleponController;
  
  File? _imageFile; // Tetap digunakan untuk Mobile
  Uint8List? _imageBytes; // Tambahan untuk Web
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  String _userEmail = '';
  Warga? _currentUserWarga;
  String _role = '-';

  @override
  void initState() {
    super.initState();
    _userEmail = Supabase.instance.client.auth.currentUser?.email ?? '';
    _namaController = TextEditingController();
    _teleponController = TextEditingController();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final warga = await _wargaService.getWargaByEmail(_userEmail);
      
      // Fetch role from warga table
      final response = await Supabase.instance.client
          .from('warga')
          .select('role')
          .eq('email', _userEmail)
          .maybeSingle();
      
      String fetchedRole = response != null ? (response['role'] ?? '-') : '-';

      if (warga != null) {
        if (mounted) {
          setState(() {
            _currentUserWarga = warga;
            _namaController.text = warga.nama;
            _teleponController.text = warga.telepon ?? '';
            _role = fetchedRole;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Data profil tidak ditemukan.'), backgroundColor: Colors.grey.shade800),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint("Error fetching profile: $e");
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUserWarga == null) return;

    setState(() => _isLoading = true);

    try {
      String? fotoUrl = _currentUserWarga?.fotoProfil;
      if (_imageBytes != null || _imageFile != null) {
        final fileName = 'pfp_${DateTime.now().millisecondsSinceEpoch}.jpg';
        fotoUrl = await _wargaService.uploadFotoProfil(
          file: _imageFile,
          bytes: _imageBytes, // Kirim bytes juga
          fileName: fileName,
          contentType: 'image/jpeg',
        );
      }
      
      final updatedWarga = Warga(
        id: _currentUserWarga!.id,
        nama: _namaController.text,
        email: _userEmail,
        telepon: _teleponController.text,
        pekerjaan: _currentUserWarga!.pekerjaan, // Keep existing value
        fotoProfil: fotoUrl,
        tanggalLahir: _currentUserWarga!.tanggalLahir,
        tempatLahir: _currentUserWarga!.tempatLahir,
        gender: _currentUserWarga!.gender,
        golDarah: _currentUserWarga!.golDarah,
        pendidikanTerakhir: _currentUserWarga!.pendidikanTerakhir,
        statusPenduduk: _currentUserWarga!.statusPenduduk,
        statusHidupWafat: _currentUserWarga!.statusHidupWafat,
        keluargaId: _currentUserWarga!.keluargaId,
        agama: _currentUserWarga!.agama,
        fotoKtp: _currentUserWarga!.fotoKtp,
        role: _currentUserWarga!.role,
      );

      await _wargaService.updateWarga(_currentUserWarga!.id, updatedWarga);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.grey.shade800),
        );
        context.pop(true); 
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.grey.shade800),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentUserWarga == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    ImageProvider? imageProvider;
    if (_imageBytes != null) {
      imageProvider = MemoryImage(_imageBytes!);
    } else if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (_currentUserWarga?.fotoProfil != null) {
      imageProvider = NetworkImage(_currentUserWarga!.fotoProfil!);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF6366F1),
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? Text(
                              _namaController.text.isNotEmpty ? _namaController.text[0].toUpperCase() : 'A',
                              style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildTextField(
                label: "Nama Lengkap",
                controller: _namaController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _userEmail,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "Nomor Telepon",
                controller: _teleponController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Role Field (Read Only)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Role", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _role,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (val) => val == null || val.isEmpty ? '$label tidak boleh kosong' : null,
        ),
      ],
    );
  }
}
