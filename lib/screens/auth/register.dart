import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:SapaWarga_kel_2/constants/constant_colors.dart';
import 'package:SapaWarga_kel_2/screens/auth/auth_service.dart';
import 'package:SapaWarga_kel_2/widget/drop_down_trailing_arrow.dart';
import 'package:SapaWarga_kel_2/widget/login_button.dart';
import 'package:SapaWarga_kel_2/widget/system_ui_style.dart';
import 'package:SapaWarga_kel_2/widget/text_input_login.dart';
import 'package:moon_design/moon_design.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? errorMessage;
  XFile? _fotoKtp;
  final _imagePicker = ImagePicker();

  final supabase = Supabase.instance.client;
  final authService = AuthService();

  final TextEditingController _controllerEmail = TextEditingController(text: '');
  final TextEditingController _controllerPassword = TextEditingController(text: '');

  // --- LOGIC BACKEND ---
  Future<void> createUserWithEmailAndPassword() async {
    try {
      await authService.signUpWithEmailPassword(
        _controllerEmail.text,
        _controllerPassword.text,
      );

      String fotoUrl = '';
      if (_fotoKtp != null) {
        final uploadedUrl = await _uploadFotoKtp(_fotoKtp!);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          fotoUrl = uploadedUrl;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gagal mengunggah foto. Melanjutkan tanpa foto.'),
              ),
            );
          }
        }
      }

      await supabase.from('warga').insert({
        'nama': _namaController.text,
        'id': _nikController.text,
        'gender': _controllerJenisKelamin.text,
        'email': _controllerEmail.text,
        'telepon': _phoneController.text,
        'foto_ktp': fotoUrl,
        'role': 'Warga',
      });

      if (mounted) context.go('/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: $e')));
      }
    }
  }

  late final TextEditingController _namaController,
      _nikController,
      _phoneController,
      _passwordController,
      _confirmPasswordController,
      _alamatController,
      _controllerJenisKelamin,
      _tempatLahirController,
      _rumahManualController;

  DateTime? _tanggalLahir;
  String? _agama;
  String? _golonganDarah;
  String? _peranKeluarga;
  String? _pendidikanTerakhir;
  String? _pekerjaan;
  String? _statusHidup;
  String? _statusKependudukan;
  String? _rumahSaatIni;
  bool _isRumahManual = false;

  @override
  void initState() {
    _namaController = TextEditingController();
    _nikController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _alamatController = TextEditingController();
    _controllerJenisKelamin = TextEditingController();
    _tempatLahirController = TextEditingController();
    _rumahManualController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _alamatController.dispose();
    _controllerJenisKelamin.dispose();
    _tempatLahirController.dispose();
    _rumahManualController.dispose();
    super.dispose();
  }

  final Map<int, String> _jenisKelamin = {1: 'Pria', 0: 'Wanita'};
  bool _showDdKelamin = false;
  bool _showDdRumah = false;
  bool _showDdAgama = false;
  bool _showDdGolDarah = false;
  bool _showDdPeranKeluarga = false;
  bool _showDdPendidikan = false;
  bool _showDdPekerjaan = false;
  bool _showDdStatusHidup = false;
  bool _showDdStatusKependudukan = false;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MoonTokens.light.colors.piccolo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: MoonTokens.light.colors.piccolo,
                    ),
                  ),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MoonTokens.light.colors.piccolo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: MoonTokens.light.colors.piccolo,
                    ),
                  ),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _fotoKtp = pickedFile;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.camera
                    ? 'Foto berhasil diambil'
                    : 'Foto berhasil dipilih',
              ),
              backgroundColor: Colors.grey.shade800,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: Colors.grey.shade800,
          ),
        );
      }
    }
  }

  Future<String?> _uploadFotoKtp(XFile image) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = 'foto-ktp/$fileName';

      await Supabase.instance.client.storage
          .from('foto_ktp')
          .upload(
            filePath,
            File(image.path),
            fileOptions: FileOptions(contentType: image.mimeType),
          );
      final imageUrl = Supabase.instance.client.storage
          .from('foto_ktp')
          .getPublicUrl(filePath);
      return imageUrl;
    } on StorageException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengunggah foto: ${e.message}. Pastikan bucket "foto_ktp" ada di Supabase Storage.',
            ),
          ),
        );
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengunggah foto: $e')));
      }
      return null;
    }
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    // Definisi Warna Biru Primary
    final Color primaryColor = MoonTokens.light.colors.piccolo;

    return SystemUiStyle(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // --- BACKGROUND GRADIENT (Sama seperti Login) ---
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    primaryColor.withOpacity(0.10),
                    Colors.white,
                    primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
            ),

            // --- DECORATIVE ORBS (Sama seperti Login) ---
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.06),
                ),
              ),
            ),

            // --- MAIN CONTENT ---
            SafeArea(
              child: SingleChildScrollView(
                key: const Key('scroll_view_register'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    children: [
                      // --- CARD PUTIH FORM REGISTER ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 25,
                              spreadRadius: 1,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Header Custom dalam Card ---
                            Row(
                              children: [
                                IconButton(
                                  key: const Key('btn_back_nav'),
                                  onPressed: () => context.go('/login'),
                                  // Icon Panah Warna Biru Primary
                                  icon: Icon(Icons.arrow_back, color: primaryColor),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  style: const ButtonStyle(
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Daftar",
                                  // Judul Warna Biru Primary
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lengkapi data untuk membuat akun baru.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ================= DATA DIRI =================
                            inputGroup(
                              title: 'Data Diri',
                              children: [
                                TextInputLogin(
                                  key: const Key('input_nama_lengkap'),
                                  controller: _namaController,
                                  hint: 'Nama Lengkap',
                                  keyboardType: TextInputType.name,
                                ),
                                TextInputLogin(
                                  key: const Key('input_nik'),
                                  controller: _nikController,
                                  hint: 'NIK',
                                  keyboardType: TextInputType.number,
                                ),
                                TextInputLogin(
                                  key: const Key('input_phone'),
                                  controller: _phoneController,
                                  hint: 'No Telepon',
                                  keyboardType: TextInputType.phone,
                                ),
                                TextInputLogin(
                                  controller: _tempatLahirController,
                                  hint: 'Tempat Lahir',
                                  keyboardType: TextInputType.text,
                                ),
                                TextInputLogin(
                                  controller: TextEditingController(
                                    text: _tanggalLahir != null
                                        ? '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}'
                                        : '',
                                  ),
                                  hint: 'Tanggal Lahir (dd/mm/yyyy)',
                                  readOnly: true,
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _tanggalLahir ?? DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setState(() => _tanggalLahir = picked);
                                    }
                                  },
                                ),
                                // Alamat Rumah dropdown/manual
                                if (!_isRumahManual)
                                  MoonDropdown(
                                    show: _showDdRumah,
                                    constrainWidthToChild: true,
                                    onTapOutside: () =>
                                        setState(() => _showDdRumah = false),
                                    content: Column(
                                      children: [
                                        MoonMenuItem(
                                          onTap: () => setState(() {
                                            _rumahSaatIni = 'Blok A No. 1';
                                            _showDdRumah = false;
                                          }),
                                          label: const Text('Blok A No. 1'),
                                        ),
                                        MoonMenuItem(
                                          onTap: () => setState(() {
                                            _rumahSaatIni = 'Blok A No. 2';
                                            _showDdRumah = false;
                                          }),
                                          label: const Text('Blok A No. 2'),
                                        ),
                                        MoonMenuItem(
                                          onTap: () => setState(() {
                                            _rumahSaatIni = 'Blok B No. 1';
                                            _showDdRumah = false;
                                          }),
                                          label: const Text('Blok B No. 1'),
                                        ),
                                        MoonMenuItem(
                                          onTap: () => setState(() {
                                            _isRumahManual = true;
                                            _rumahSaatIni = null;
                                            _showDdRumah = false;
                                          }),
                                          label: const Text('Lainnya'),
                                        ),
                                      ],
                                    ),
                                    child: MoonTextInput(
                                      textInputSize: MoonTextInputSize.xl,
                                      readOnly: true,
                                      hintText: _rumahSaatIni ?? 'Alamat Rumah',
                                      onTap: () => setState(
                                          () => _showDdRumah = !_showDdRumah),
                                      trailing: DropDownTrailingArrow(
                                          isShow: _showDdRumah),
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      TextInputLogin(
                                        controller: _rumahManualController,
                                        hint: 'Masukkan Alamat Rumah',
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _isRumahManual = false;
                                              _rumahManualController.clear();
                                            });
                                          },
                                          child: Text(
                                            'Kembali ke pilihan dropdown',
                                            // Teks link warna Primary
                                            style: TextStyle(color: primaryColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                            // ================= ATRIBUT PERSONAL =================
                            inputGroup(
                              title: 'Atribut Personal',
                              children: [
                                MoonDropdown(
                                  show: _showDdKelamin,
                                  constrainWidthToChild: true,
                                  onTapOutside: () =>
                                      setState(() => _showDdKelamin = false),
                                  content: Column(
                                    children: [
                                      MoonMenuItem(
                                        key: const Key('option_gender_pria'),
                                        onTap: () => setState(() {
                                          _showDdKelamin = false;
                                          _controllerJenisKelamin.text =
                                              _jenisKelamin[1]!;
                                        }),
                                        label: Text(_jenisKelamin[1]!),
                                      ),
                                      MoonMenuItem(
                                        key: const Key('option_gender_wanita'),
                                        onTap: () => setState(() {
                                          _showDdKelamin = false;
                                          _controllerJenisKelamin.text =
                                              _jenisKelamin[0]!;
                                        }),
                                        label: Text(_jenisKelamin[0]!),
                                      ),
                                    ],
                                  ),
                                  child: MoonTextInput(
                                    key: const Key('dropdown_trigger_gender'),
                                    textInputSize: MoonTextInputSize.xl,
                                    readOnly: true,
                                    hintText:
                                        _controllerJenisKelamin.text.isEmpty
                                            ? 'Jenis Kelamin'
                                            : _controllerJenisKelamin.text,
                                    onTap: () => setState(
                                        () => _showDdKelamin = !_showDdKelamin),
                                    trailing: DropDownTrailingArrow(
                                        isShow: _showDdKelamin),
                                  ),
                                ),
                                // Dropdown Agama
                                MoonDropdown(
                                  show: _showDdAgama,
                                  constrainWidthToChild: true,
                                  onTapOutside: () =>
                                      setState(() => _showDdAgama = false),
                                  content: Column(
                                    children: [
                                      'Islam', 'Kristen', 'Katolik', 'Hindu',
                                      'Buddha', 'Konghucu'
                                    ].map((agama) => MoonMenuItem(
                                          onTap: () => setState(() {
                                            _agama = agama;
                                            _showDdAgama = false;
                                          }),
                                          label: Text(agama),
                                        )).toList(),
                                  ),
                                  child: MoonTextInput(
                                    textInputSize: MoonTextInputSize.xl,
                                    readOnly: true,
                                    hintText: _agama ?? 'Agama',
                                    onTap: () => setState(
                                        () => _showDdAgama = !_showDdAgama),
                                    trailing: DropDownTrailingArrow(
                                        isShow: _showDdAgama),
                                  ),
                                ),
                                MoonDropdown(
                                  show: _showDdGolDarah,
                                  constrainWidthToChild: true,
                                  onTapOutside: () =>
                                      setState(() => _showDdGolDarah = false),
                                  content: Column(
                                    children: [
                                      'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-',
                                      'O+', 'O-'
                                    ].map((gol) => MoonMenuItem(
                                          onTap: () => setState(() {
                                            _golonganDarah = gol;
                                            _showDdGolDarah = false;
                                          }),
                                          label: Text(gol),
                                        )).toList(),
                                  ),
                                  child: MoonTextInput(
                                    textInputSize: MoonTextInputSize.xl,
                                    readOnly: true,
                                    hintText: _golonganDarah ?? 'Golongan Darah',
                                    onTap: () => setState(() =>
                                        _showDdGolDarah = !_showDdGolDarah),
                                    trailing: DropDownTrailingArrow(
                                      isShow: _showDdGolDarah,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ================= PERAN & LATAR BELAKANG =================
                            inputGroup(
                              title: 'Peran & Latar Belakang',
                              children: [
                                MoonDropdown(
                                  show: _showDdPeranKeluarga,
                                  constrainWidthToChild: true,
                                  onTapOutside: () => setState(
                                      () => _showDdPeranKeluarga = false),
                                  content: Column(
                                    children: [
                                      'Kepala Keluarga', 'Ibu', 'Anak',
                                      'Lainnya'
                                    ].map((peran) => MoonMenuItem(
                                          onTap: () => setState(() {
                                            _peranKeluarga = peran;
                                            _showDdPeranKeluarga = false;
                                          }),
                                          label: Text(peran),
                                        )).toList(),
                                  ),
                                  child: MoonTextInput(
                                    textInputSize: MoonTextInputSize.xl,
                                    readOnly: true,
                                    hintText:
                                        _peranKeluarga ?? 'Peran Keluarga',
                                    onTap: () => setState(
                                      () => _showDdPeranKeluarga =
                                          !_showDdPeranKeluarga,
                                    ),
                                    trailing: DropDownTrailingArrow(
                                      isShow: _showDdPeranKeluarga,
                                    ),
                                  ),
                                ),
                                MoonDropdown(
                                  show: _showDdPendidikan,
                                  constrainWidthToChild: true,
                                  onTapOutside: () =>
                                      setState(() => _showDdPendidikan = false),
                                  content: Column(
                                    children: [
                                      'SD', 'SMP', 'SMA/SMK', 'Diploma', 'S1',
                                      'S2', 'S3'
                                    ].map((pend) => MoonMenuItem(
                                          onTap: () => setState(() {
                                            _pendidikanTerakhir = pend;
                                            _showDdPendidikan = false;
                                          }),
                                          label: Text(pend),
                                        )).toList(),
                                  ),
                                  child: MoonTextInput(
                                    textInputSize: MoonTextInputSize.xl,
                                    readOnly: true,
                                    hintText: _pendidikanTerakhir ??
                                        'Pendidikan Terakhir',
                                    onTap: () => setState(
                                      () => _showDdPendidikan =
                                          !_showDdPendidikan,
                                    ),
                                    trailing: DropDownTrailingArrow(
                                      isShow: _showDdPendidikan,
                                    ),
                                  ),
                                ),
                                MoonDropdown(
                                  show: _showDdPekerjaan,
                                  constrainWidthToChild: true,
                                  onTapOutside: () =>
                                      setState(() => _showDdPekerjaan = false),
                                  content: Column(
                                    children: [
                                      'Pelajar/Mahasiswa', 'Karyawan',
                                      'Wiraswasta', 'Ibu Rumah Tangga',
                                      'Tidak Bekerja'
                                    ].map((job) => MoonMenuItem(
                                          onTap: () => setState(() {
                                            _pekerjaan = job;
                                            _showDdPekerjaan = false;
                                          }),
                                          label: Text(job),
                                        )).toList(),
                                  ),
                                  child: MoonTextInput(
                                    textInputSize: MoonTextInputSize.xl,
                                    readOnly: true,
                                    hintText: _pekerjaan ?? 'Pekerjaan',
                                    onTap: () => setState(
                                      () => _showDdPekerjaan = !_showDdPekerjaan,
                                    ),
                                    trailing: DropDownTrailingArrow(
                                      isShow: _showDdPekerjaan,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ================= STATUS =================
                            inputGroup(
                              title: 'Status',
                              children: [
                                MoonDropdown(
                                  show: _showDdStatusHidup,
                                  constrainWidthToChild: true,
                                  onTapOutside: () => setState(
                                      () => _showDdStatusHidup = false),
                                  content: Column(
                                    children: ['Hidup', 'Wafat']
                                        .map((status) => MoonMenuItem(
                                              onTap: () => setState(() {
                                                _statusHidup = status;
                                                _showDdStatusHidup = false;
                                              }),
                                              label: Text(status),
                                            ))
                                        .toList(),
                                  ),
                                  child: MoonTextInput(
                                    textInputSize: MoonTextInputSize.xl,
                                    readOnly: true,
                                    hintText: _statusHidup ?? 'Status Hidup',
                                    onTap: () => setState(
                                      () => _showDdStatusHidup =
                                          !_showDdStatusHidup,
                                    ),
                                    trailing: DropDownTrailingArrow(
                                      isShow: _showDdStatusHidup,
                                    ),
                                  ),
                                ),
                                MoonDropdown(
                                  show: _showDdStatusKependudukan,
                                  constrainWidthToChild: true,
                                  onTapOutside: () => setState(
                                      () => _showDdStatusKependudukan = false),
                                  content: Column(
                                    children: ['Aktif', 'Nonaktif']
                                        .map((status) => MoonMenuItem(
                                              onTap: () => setState(() {
                                                _statusKependudukan = status;
                                                _showDdStatusKependudukan =
                                                    false;
                                              }),
                                              label: Text(status),
                                            ))
                                        .toList(),
                                  ),
                                  child: MoonTextInput(
                                    textInputSize: MoonTextInputSize.xl,
                                    readOnly: true,
                                    hintText: _statusKependudukan ??
                                        'Status Kependudukan',
                                    onTap: () => setState(
                                      () => _showDdStatusKependudukan =
                                          !_showDdStatusKependudukan,
                                    ),
                                    trailing: DropDownTrailingArrow(
                                      isShow: _showDdStatusKependudukan,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ================= FOTO IDENTITAS =================
                            inputGroup(
                              title: 'Foto Identitas',
                              children: [
                                Container(
                                  key: const Key('area_upload_foto'),
                                  width: double.infinity,
                                  height: 200,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: MoonTokens.light.colors.goku,
                                    border: Border.all(
                                      color: MoonTokens.light.colors.beerus,
                                      width: 2,
                                    ),
                                  ),
                                  child: _fotoKtp == null
                                      ? Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: _pickImage,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  MoonIcons
                                                      .generic_picture_32_light,
                                                  size: 48,
                                                  color: MoonTokens
                                                      .light.colors.bulma,
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Upload Foto KK/KTP',
                                                  style: MoonTokens.light
                                                      .typography.heading.text16
                                                      .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Tap untuk memilih dari galeri atau kamera',
                                                  style: MoonTokens
                                                      .light.typography.body.text12
                                                      .copyWith(
                                                    color: MoonTokens
                                                        .light.colors.trunks,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Image.file(
                                                File(_fotoKtp!.path),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Row(
                                                children: [
                                                  Material(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                    child: InkWell(
                                                      onTap: _pickImage,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8,
                                                      ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8),
                                                        child: const Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Material(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _fotoKtp = null;
                                                        });
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8,
                                                      ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),

                            // ================= AKUN =================
                            inputGroup(
                              title: 'Akun',
                              children: [
                                TextInputLogin(
                                  key: const Key('input_email_reg'),
                                  controller: _controllerEmail,
                                  hint: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                TextInputLogin(
                                  key: const Key('input_password_reg'),
                                  controller: _controllerPassword,
                                  hint: 'Password',
                                  isPassword: true,
                                ),
                                TextInputLogin(
                                  key: const Key('input_confirm_password'),
                                  controller: _confirmPasswordController,
                                  hint: 'Konfirmasi Password',
                                  isPassword: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Tombol Submit
                            LoginButton(
                              key: const Key('btn_submit_register'),
                              text: 'Daftar',
                              onTap: () {
                                createUserWithEmailAndPassword();
                              },
                              // Tombol warna Biru Primary
                              withColor: true,
                            ),

                            const SizedBox(height: 20),

                            // Link ke Login (Dalam Card)
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  children: [
                                    const TextSpan(text: 'Sudah punya akun? '),
                                    TextSpan(
                                      text: 'Login',
                                      style: TextStyle(
                                        // Link Login warna Primary
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => context.go('/login'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Padding bawah extra
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column inputGroup({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 8),
        ...children.expand((element) => [element, const SizedBox(height: 8)]),
      ],
    );
  }
}