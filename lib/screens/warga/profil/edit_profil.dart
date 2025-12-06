import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moon_design/moon_design.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'package:jawara_pintar_kel_5/services/warga_service.dart';

const Color _primaryColorApp = Color(0xFF6A5AE0);
const Color _backgroundColor = Color(0xFFF7F7F7);
const Color _primaryTextColor = Color(0xFF1F2937);

class WargaEditDataDiriScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const WargaEditDataDiriScreen({
    super.key,
    this.initialData = const {},
  });

  @override
  State<WargaEditDataDiriScreen> createState() => _WargaEditDataDiriScreenState();
}

class _WargaEditDataDiriScreenState extends State<WargaEditDataDiriScreen> {
  final _formKey = GlobalKey<FormState>();
  final WargaService _wargaService = WargaService();
  final ImagePicker _picker = ImagePicker();

  // Controllers for editable fields
  late final TextEditingController _phoneController;
  
  // Dropdown values
  Gender? _selectedGender;
  GolonganDarah? _selectedBloodType;
  String? _selectedAgama;

  final List<String> _agamaList = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Khonghucu'
  ];

  // Data
  Warga? _currentWarga;
  bool _isLoading = false;
  late String _nik = ''; 

  // Images
  File? _imageFile;
  Uint8List? _imageBytes;
  File? _ktpFile;
  Uint8List? _ktpBytes;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialData['telepon']);
    
    _nik = widget.initialData['nik'] ?? widget.initialData['id'] ?? '';

    _fetchFullWargaData();
  }

  Future<void> _fetchFullWargaData() async {
    try {
      if (_nik.isNotEmpty && _nik != '-') {
         final warga = await _wargaService.getWargaById(_nik);
         if (mounted) {
           setState(() {
             _currentWarga = warga;
             if (_phoneController.text.isEmpty) _phoneController.text = warga.telepon ?? '';
             _selectedGender = warga.gender;
             _selectedBloodType = warga.golDarah;
             
             // Set agama if matches list, otherwise null
             if (warga.agama != null && _agamaList.contains(warga.agama)) {
                _selectedAgama = warga.agama;
             }
           });
         }
      }
    } catch (e) {
      debugPrint("Error fetching full warga data: $e");
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
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
    } catch (e) {
      debugPrint("Error picking profile image: $e");
    }
  }

  Future<void> _pickKtpImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _ktpFile = File(pickedFile.path);
          _ktpBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Error picking KTP image: $e");
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentWarga == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Data warga belum dimuat sempurna. Mohon tunggu.'), backgroundColor: Colors.grey.shade800),
        );
        return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload Profile Picture
      String? fotoUrl = _currentWarga?.fotoProfil;
      if (_imageBytes != null) { 
        final fileName = 'pfp_${_currentWarga!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        fotoUrl = await _wargaService.uploadFotoProfil(
          file: kIsWeb ? null : _imageFile,
          bytes: _imageBytes,
          fileName: fileName,
          contentType: 'image/jpeg',
        );
      }

      // 2. Upload KTP
      String? fotoKtpUrl = _currentWarga?.fotoKtp;
      if (_ktpBytes != null) {
         final fileName = 'ktp_${_currentWarga!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
         fotoKtpUrl = await _wargaService.uploadFotoKtp(
            file: kIsWeb ? null : _ktpFile, 
            bytes: _ktpBytes, 
            fileName: fileName, 
            contentType: 'image/jpeg'
         );
      }

      // 3. Update Data
      final updatedWarga = Warga(
        id: _currentWarga!.id,
        nama: _currentWarga!.nama, // Disabled
        email: _currentWarga!.email, // Disabled
        telepon: _phoneController.text, // Editable
        pekerjaan: _currentWarga!.pekerjaan, // Disabled
        fotoProfil: fotoUrl, // Editable
        tanggalLahir: _currentWarga!.tanggalLahir, // Disabled
        tempatLahir: _currentWarga!.tempatLahir, // Disabled
        gender: _selectedGender, // Editable
        golDarah: _selectedBloodType, // Editable
        pendidikanTerakhir: _currentWarga!.pendidikanTerakhir, // Disabled
        statusPenduduk: _currentWarga!.statusPenduduk, // Disabled
        statusHidupWafat: _currentWarga!.statusHidupWafat, // Disabled
        keluargaId: _currentWarga!.keluargaId,
        agama: _selectedAgama, // Editable (Dropdown)
        fotoKtp: fotoKtpUrl, // Editable
      );

      await _wargaService.updateWarga(_currentWarga!.id, updatedWarga);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.grey.shade800,
            behavior: SnackBarBehavior.floating,
          ),
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
    if (_isLoading || _currentWarga == null) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Providers for Images
    ImageProvider? imageProvider;
    if (_imageBytes != null) {
      imageProvider = MemoryImage(_imageBytes!);
    } else if (_currentWarga?.fotoProfil != null) {
      imageProvider = NetworkImage(_currentWarga!.fotoProfil!);
    }

    ImageProvider? ktpProvider;
    if (_ktpBytes != null) {
        ktpProvider = MemoryImage(_ktpBytes!);
    } else if (_currentWarga?.fotoKtp != null) {
        ktpProvider = NetworkImage(_currentWarga!.fotoKtp!);
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: Row(
          children: [
            MoonButton.icon(
              onTap: () => context.pop(),
              icon: const Icon(MoonIcons.controls_chevron_left_32_regular),
            ),
            const SizedBox(width: 8),
            Text(
              "Ubah Data Diri",
              style: MoonTokens.light.typography.heading.text40.copyWith(
                color: _primaryTextColor,
                fontWeight: FontWeight.w700,
              ),
              textScaler: const TextScaler.linear(0.7),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(right: 16, left: 16, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // --- Foto Profil (Editable) ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: _primaryColorApp.withOpacity(0.1),
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? Text(
                              _currentWarga?.nama.isNotEmpty == true ? _currentWarga!.nama[0].toUpperCase() : 'A',
                              style: const TextStyle(fontSize: 32, color: _primaryColorApp, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primaryColorApp,
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
              const SizedBox(height: 24),

              // --- Identitas ---
              _buildInputGroup(
                title: 'Identitas',
                children: [
                  // Nama (Disabled)
                  _buildReadOnlyField(label: 'Nama Lengkap', value: _currentWarga?.nama ?? '-'),
                  // NIK (Disabled)
                  _buildReadOnlyField(label: 'NIK', value: _currentWarga?.id ?? '-'),
                  // Jenis Kelamin (Editable)
                  _buildDropdownField<Gender>(
                    label: 'Jenis Kelamin',
                    value: _selectedGender,
                    items: Gender.values,
                    itemLabel: (g) => g.value,
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                  // Golongan Darah (Editable)
                  _buildDropdownField<GolonganDarah>(
                    label: 'Golongan Darah',
                    value: _selectedBloodType,
                    items: GolonganDarah.values,
                    itemLabel: (g) => g.value,
                    onChanged: (val) => setState(() => _selectedBloodType = val),
                  ),
                  // Agama (Editable Dropdown)
                  _buildDropdownField<String>(
                    label: 'Agama',
                    value: _selectedAgama,
                    items: _agamaList,
                    itemLabel: (val) => val,
                    onChanged: (val) => setState(() => _selectedAgama = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Kontak & Akun ---
              _buildInputGroup(
                title: 'Kontak & Akun',
                children: [
                   // Email (Disabled)
                  _buildReadOnlyField(label: 'Email', value: _currentWarga?.email ?? '-'),
                   // Telepon (Editable)
                  _buildEditableField(
                    label: 'Nomor Telepon', 
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Detail Tempat Tinggal ---
              _buildInputGroup(
                title: 'Detail Tempat Tinggal',
                children: [
                  _buildReadOnlyField(label: 'Alamat', value: _currentWarga?.keluarga?.alamatRumah ?? '-', maxLines: 3),
                  _buildReadOnlyField(label: 'Status Warga', value: _currentWarga?.statusPenduduk?.value ?? '-'),
                ],
              ),
              const SizedBox(height: 24),

              // --- Dokumen KTP (Editable) ---
              _buildInputGroup(
                title: 'Dokumen',
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foto KTP',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _primaryTextColor),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickKtpImage,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ktpProvider != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image(image: ktpProvider, fit: BoxFit.cover),
                                    Container(
                                      color: Colors.black.withOpacity(0.3),
                                      child: const Center(
                                        child: Icon(Icons.edit, color: Colors.white, size: 32),
                                      ),
                                    )
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text('Ketuk untuk unggah KTP', style: TextStyle(color: Colors.grey.shade500)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- Tombol Simpan ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColorApp,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  
  // 1. Read Only Field
  Widget _buildReadOnlyField({required String label, required String value, int? maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey(value),
            initialValue: value.isEmpty ? '-' : value,
            readOnly: true,
            maxLines: maxLines,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: _inputDecoration(isReadOnly: true),
          ),
        ],
      ),
    );
  }

  // 2. Editable Text Field
  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: _primaryTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: _inputDecoration(),
          ),
        ],
      ),
    );
  }

  // 3. Dropdown Field
  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
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
          DropdownButtonFormField<T>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: _inputDecoration(),
            style: const TextStyle(
              color: _primaryTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 4. Input Decoration
  InputDecoration _inputDecoration({bool isReadOnly = false}) {
    final Color borderColor = isReadOnly ? Colors.grey.shade200 : Colors.grey.shade300;
    final Color focusedColor = isReadOnly ? Colors.grey.shade300 : _primaryColorApp.withOpacity(0.5);
    final Color fillColor = isReadOnly ? Colors.grey.shade100 : Colors.white;

    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: focusedColor, width: isReadOnly ? 1 : 1.5),
      ),
      fillColor: fillColor,
      filled: true,
    );
  }

  // 5. Input Group Container
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
}