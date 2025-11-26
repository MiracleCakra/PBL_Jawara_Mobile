import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moon_design/moon_design.dart';

// --- Asumsi Warna Utama ---
const Color _primaryColorApp = Color(0xFF6A5AE0); 
const Color _backgroundColor = Color(0xFFF7F7F7); 
const Color _primaryTextColor = Color(0xFF1F2937);

class WargaDataDiriScreen extends StatefulWidget {
  const WargaDataDiriScreen({super.key});

  @override
  State<WargaDataDiriScreen> createState() => _WargaDataDiriScreenState();
}

class _WargaDataDiriScreenState extends State<WargaDataDiriScreen> {
  late final TextEditingController _namaController;
  late final TextEditingController _nikController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _genderController;
  late final TextEditingController _statusController;
  late final TextEditingController _alamatController;

  final Map<String, dynamic> dummyDataWarga = {
    'nama': 'Susanto',
    'nik': '3200101234567890',
    'email': 'Sasanto@gmail.com',
    'telepon': '081234567890',
    'gender': 'Pria',
    'status': 'Aktif',
    'alamat': 'Blok C No. 5, RT 001 / RW 001, Kelurahan jiwiri',
    'foto_ktp_url': 'https://media.istockphoto.com/id/1403638387/id/foto/kartu-identitas-kewarganegaraan-indonesia.jpg?s=612x612&w=is&k=20&c=o1BJDIL4oYnJagYpGnBJS9Wsg6wQU5HyOXbQ4skRPg4=',
  };

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: dummyDataWarga['nama']);
    _nikController = TextEditingController(text: dummyDataWarga['nik']);
    _emailController = TextEditingController(text: dummyDataWarga['email']);
    _phoneController = TextEditingController(text: dummyDataWarga['telepon']);
    _genderController = TextEditingController(text: dummyDataWarga['gender']);
    _statusController = TextEditingController(text: dummyDataWarga['status']);
    _alamatController = TextEditingController(text: dummyDataWarga['alamat']);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _statusController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, 
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0.5,
        title: Row(
          children: [
            MoonButton.icon(
              onTap: () => context.pop(),
              icon: const Icon(MoonIcons.controls_chevron_left_32_regular),
            ),
            const SizedBox(width: 8),
            Text(
              "Data Diri",
              style: MoonTokens.light.typography.heading.text40.copyWith(
                color: _primaryTextColor,
                fontWeight: FontWeight.w700,
              ),
              textScaler: const TextScaler.linear(0.7),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(right: 16, left: 16, top: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildProfilePictureSection(),
            const SizedBox(height: 24),

            // --- Identitas ---
            _buildInputGroup(
              title: 'Identitas',
              children: [
                _buildReadOnlyField(label: 'Nama Lengkap', value: _namaController.text),
                _buildReadOnlyField(label: 'NIK', value: _nikController.text),
                _buildReadOnlyField(label: 'Jenis Kelamin', value: _genderController.text),
              ],
            ),
            const SizedBox(height: 24),

            // --- Kontak & Akun ---
            _buildInputGroup(
              title: 'Kontak & Akun',
              children: [
                _buildReadOnlyField(label: 'Email', value: _emailController.text),
                _buildReadOnlyField(label: 'No Telepone', value: _phoneController.text),
              ],
            ),
            const SizedBox(height: 24),

            // --- Detail Tempat Tinggal ---
            _buildInputGroup(
              title: 'Detail Tempat Tinggal',
              children: [
                _buildReadOnlyField(label: 'Alamat', value: _alamatController.text, maxLines: 3),
                _buildReadOnlyField(label: 'Status Warga', value: _statusController.text),
              ],
            ),
            const SizedBox(height: 32),

            // --- Tombol Edit ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/warga/profil/edit-data'); 
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Ubah Data Diri',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColorApp, 
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  Widget _buildReadOnlyField({required String label, required String value, int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _primaryTextColor), 
          ),
          const SizedBox(height: 8),
          
          TextFormField(
            initialValue: value.isEmpty ? '-' : value,
            readOnly: true,
            style: const TextStyle(
              color: _primaryTextColor,
              fontSize: 15, 
              fontWeight: FontWeight.w500,
            ),
            maxLines: maxLines,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              
              border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1), 
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide(color: _primaryColorApp.withOpacity(0.5), width: 1.5), 
              ),
              
              fillColor: Colors.white, 
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Column _buildInputGroup({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MoonTokens.light.typography.heading.text16.copyWith(
            color: _primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8), 
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3), 
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildProfilePictureSection() {
    final fotoUrl = dummyDataWarga['foto_ktp_url'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Identitas (KTP)', 
          style: MoonTokens.light.typography.heading.text16.copyWith(fontWeight: FontWeight.w700, color: _primaryTextColor),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 150,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: InkWell(
            onTap: () {
              if (fotoUrl != null && fotoUrl.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => _buildImageDialog(context, fotoUrl),
                );
              }
            },
            child: (fotoUrl != null && fotoUrl.isNotEmpty)
                ? Image.network(
                    fotoUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                          color: _primaryColorApp,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text('Gagal memuat foto', style: TextStyle(color: Colors.red)),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          MoonIcons.generic_picture_32_light,
                          size: 32,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Foto KTP belum diunggah',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (fotoUrl != null && fotoUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Ketuk gambar untuk melihat ukuran penuh.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ),
      ],
    );
  }

  Widget _buildImageDialog(BuildContext context, String imageUrl) {
    return Dialog(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.8,
            maxScale: 4,
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}