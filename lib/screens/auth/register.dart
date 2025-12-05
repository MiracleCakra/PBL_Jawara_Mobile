import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:jawara_pintar_kel_5/screens/auth/auth_service.dart';
import 'package:jawara_pintar_kel_5/widget/drop_down_trailing_arrow.dart';
import 'package:jawara_pintar_kel_5/widget/login_button.dart';
import 'package:jawara_pintar_kel_5/widget/text_input_login.dart';
import 'package:moon_design/moon_design.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? errorMessage;
  bool isLogin = true;
  XFile? _fotoKtp;
  final _imagePicker = ImagePicker();

  final supabase = Supabase.instance.client;
  final authService = AuthService();

  final TextEditingController _controllerEmail = TextEditingController(
    text: '',
  );
  final TextEditingController _controllerPassword = TextEditingController(
    text: '',
  );

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await authService.signUpWithEmailPassword(
        _controllerEmail.text,
        _controllerPassword.text,
      );

      // upload foto KTP first (if selected) and get its public URL
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
        // use the .text values from controllers
        'nama': _namaController.text,
        'id': _nikController.text,
        'gender': _controllerJenisKelamin.text,
        'email': _controllerEmail.text,
        'telepon': _phoneController.text,
        'foto_ktp': fotoUrl,
      });

      // Navigasi ke halaman dashboard setelah berhasil login
      context.go('/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
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
    // Tampilkan bottom sheet untuk memilih sumber gambar
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
      // Langsung ambil gambar tanpa request permission
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
        print(e);
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengunggah foto: $e')));
      }
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Row(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MoonButton.icon(
              key: const Key('btn_back_nav'), // ---> TAMBAHAN KEY 1
              onTap: () => context.go('/login'),
              icon: const Icon(MoonIcons.controls_chevron_left_32_regular),
            ),
            Text(
              "Daftar",
              style: MoonTokens.light.typography.heading.text40.copyWith(
                color: MoonTokens.light.colors.piccolo,
                fontWeight: FontWeight.w700,
              ),
              textScaler: const TextScaler.linear(0.7),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: SingleChildScrollView(
          key: const Key('scroll_view_register'), // ---> TAMBAHAN KEY 2
          child: Padding(
            padding: const EdgeInsets.only(right: 24, left: 24),
            child: Column(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar untuk mengakses sistem Jawara Pintar.',
                  style: MoonTokens.light.typography.body.text14,
                ),
                const SizedBox(height: 8),
                // ================= DATA DIRI =================
                inputGroup(
                  title: 'Data Diri',
                  children: [
                    TextInputLogin(
                      key: const Key(
                        'input_nama_lengkap',
                      ), // ---> TAMBAHAN KEY 3
                      controller: _namaController,
                      hint: 'Nama Lengkap',
                      keyboardType: TextInputType.name,
                    ),
                    TextInputLogin(
                      key: const Key('input_nik'), // ---> TAMBAHAN KEY 4
                      controller: _nikController,
                      hint: 'NIK',
                      keyboardType: TextInputType.number,
                    ),
                    TextInputLogin(
                      key: const Key('input_phone'), // ---> TAMBAHAN KEY 10
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
                          onTap: () =>
                              setState(() => _showDdRumah = !_showDdRumah),
                          trailing: DropDownTrailingArrow(isShow: _showDdRumah),
                        ),
                      )
                    else
                      Column(
                        spacing: 8,
                        children: [
                          TextInputLogin(
                            controller: _rumahManualController,
                            hint: 'Masukkan Alamat Rumah',
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isRumahManual = false;
                                _rumahManualController.clear();
                              });
                            },
                            child: const Text('Kembali ke pilihan dropdown'),
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
                            key: const Key(
                              'option_gender_pria',
                            ), // ---> TAMBAHAN KEY 5
                            absorbGestures: true,
                            onTap: () => setState(() {
                              _showDdKelamin = false;
                              _controllerJenisKelamin.text =
                                  _jenisKelamin[1]!; // set controller value
                            }),
                            label: Text(_jenisKelamin[1]!),
                          ),
                          MoonMenuItem(
                            key: const Key(
                              'option_gender_wanita',
                            ), // ---> TAMBAHAN KEY 6
                            absorbGestures: true,
                            onTap: () => setState(() {
                              _showDdKelamin = false;
                              _controllerJenisKelamin.text =
                                  _jenisKelamin[0]!; // set controller value
                            }),
                            label: Text(_jenisKelamin[0]!),
                          ),
                        ],
                      ),
                      child: MoonTextInput(
                        key: const Key('dropdown_trigger_gender'),
                        textInputSize: MoonTextInputSize.xl,
                        readOnly: true,
                        hintText: _controllerJenisKelamin.text.isEmpty
                            ? 'Jenis Kelamin'
                            : _controllerJenisKelamin.text,
                        onTap: () =>
                            setState(() => _showDdKelamin = !_showDdKelamin),
                        trailing: DropDownTrailingArrow(isShow: _showDdKelamin),
                      ),
                    ),
                    // Dropdown Agama
                    MoonDropdown(
                      show: _showDdAgama,
                      constrainWidthToChild: true,
                      onTapOutside: () => setState(() => _showDdAgama = false),
                      content: Column(
                        children: [
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _agama = 'Islam';
                              _showDdAgama = false;
                            }),
                            label: const Text('Islam'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _agama = 'Kristen';
                              _showDdAgama = false;
                            }),
                            label: const Text('Kristen'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _agama = 'Katolik';
                              _showDdAgama = false;
                            }),
                            label: const Text('Katolik'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _agama = 'Hindu';
                              _showDdAgama = false;
                            }),
                            label: const Text('Hindu'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _agama = 'Buddha';
                              _showDdAgama = false;
                            }),
                            label: const Text('Buddha'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _agama = 'Konghucu';
                              _showDdAgama = false;
                            }),
                            label: const Text('Konghucu'),
                          ),
                        ],
                      ),
                      child: MoonTextInput(
                        textInputSize: MoonTextInputSize.xl,
                        readOnly: true,
                        hintText: _agama ?? 'Agama',
                        onTap: () =>
                            setState(() => _showDdAgama = !_showDdAgama),
                        trailing: DropDownTrailingArrow(isShow: _showDdAgama),
                      ),
                    ),
                    MoonDropdown(
                      show: _showDdGolDarah,
                      constrainWidthToChild: true,
                      onTapOutside: () =>
                          setState(() => _showDdGolDarah = false),
                      content: Column(
                        children: [
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _golonganDarah = 'A+';
                              _showDdGolDarah = false;
                            }),
                            label: const Text('A+'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _golonganDarah = 'A-';
                              _showDdGolDarah = false;
                            }),
                            label: const Text('A-'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _golonganDarah = 'B+';
                              _showDdGolDarah = false;
                            }),
                            label: const Text('B+'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _golonganDarah = 'B-';
                              _showDdGolDarah = false;
                            }),
                            label: const Text('B-'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _golonganDarah = 'AB+';
                              _showDdGolDarah = false;
                            }),
                            label: const Text('AB+'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _golonganDarah = 'AB-';
                              _showDdGolDarah = false;
                            }),
                            label: const Text('AB-'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _golonganDarah = 'O+';
                              _showDdGolDarah = false;
                            }),
                            label: const Text('O+'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _golonganDarah = 'O-';
                              _showDdGolDarah = false;
                            }),
                            label: const Text('O-'),
                          ),
                        ],
                      ),
                      child: MoonTextInput(
                        textInputSize: MoonTextInputSize.xl,
                        readOnly: true,
                        hintText: _golonganDarah ?? 'Golongan Darah',
                        onTap: () =>
                            setState(() => _showDdGolDarah = !_showDdGolDarah),
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
                      onTapOutside: () =>
                          setState(() => _showDdPeranKeluarga = false),
                      content: Column(
                        children: [
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _peranKeluarga = 'Kepala Keluarga';
                              _showDdPeranKeluarga = false;
                            }),
                            label: const Text('Kepala Keluarga'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _peranKeluarga = 'Ibu';
                              _showDdPeranKeluarga = false;
                            }),
                            label: const Text('Ibu'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _peranKeluarga = 'Anak';
                              _showDdPeranKeluarga = false;
                            }),
                            label: const Text('Anak'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _peranKeluarga = 'Lainnya';
                              _showDdPeranKeluarga = false;
                            }),
                            label: const Text('Lainnya'),
                          ),
                        ],
                      ),
                      child: MoonTextInput(
                        textInputSize: MoonTextInputSize.xl,
                        readOnly: true,
                        hintText: _peranKeluarga ?? 'Peran Keluarga',
                        onTap: () => setState(
                          () => _showDdPeranKeluarga = !_showDdPeranKeluarga,
                        ),
                        trailing: DropDownTrailingArrow(
                          isShow: _showDdPeranKeluarga,
                        ),
                      ),
                    ),
                    // Dropdown Pendidikan Terakhir
                    MoonDropdown(
                      show: _showDdPendidikan,
                      constrainWidthToChild: true,
                      onTapOutside: () =>
                          setState(() => _showDdPendidikan = false),
                      content: Column(
                        children: [
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pendidikanTerakhir = 'SD';
                              _showDdPendidikan = false;
                            }),
                            label: const Text('SD'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pendidikanTerakhir = 'SMP';
                              _showDdPendidikan = false;
                            }),
                            label: const Text('SMP'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pendidikanTerakhir = 'SMA/SMK';
                              _showDdPendidikan = false;
                            }),
                            label: const Text('SMA/SMK'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pendidikanTerakhir = 'Diploma';
                              _showDdPendidikan = false;
                            }),
                            label: const Text('Diploma'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pendidikanTerakhir = 'S1';
                              _showDdPendidikan = false;
                            }),
                            label: const Text('S1'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pendidikanTerakhir = 'S2';
                              _showDdPendidikan = false;
                            }),
                            label: const Text('S2'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pendidikanTerakhir = 'S3';
                              _showDdPendidikan = false;
                            }),
                            label: const Text('S3'),
                          ),
                        ],
                      ),
                      child: MoonTextInput(
                        textInputSize: MoonTextInputSize.xl,
                        readOnly: true,
                        hintText: _pendidikanTerakhir ?? 'Pendidikan Terakhir',
                        onTap: () => setState(
                          () => _showDdPendidikan = !_showDdPendidikan,
                        ),
                        trailing: DropDownTrailingArrow(
                          isShow: _showDdPendidikan,
                        ),
                      ),
                    ),
                    // Dropdown Pekerjaan
                    MoonDropdown(
                      show: _showDdPekerjaan,
                      constrainWidthToChild: true,
                      onTapOutside: () =>
                          setState(() => _showDdPekerjaan = false),
                      content: Column(
                        children: [
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pekerjaan = 'Pelajar/Mahasiswa';
                              _showDdPekerjaan = false;
                            }),
                            label: const Text('Pelajar/Mahasiswa'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pekerjaan = 'Karyawan';
                              _showDdPekerjaan = false;
                            }),
                            label: const Text('Karyawan'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pekerjaan = 'Wiraswasta';
                              _showDdPekerjaan = false;
                            }),
                            label: const Text('Wiraswasta'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pekerjaan = 'Ibu Rumah Tangga';
                              _showDdPekerjaan = false;
                            }),
                            label: const Text('Ibu Rumah Tangga'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _pekerjaan = 'Tidak Bekerja';
                              _showDdPekerjaan = false;
                            }),
                            label: const Text('Tidak Bekerja'),
                          ),
                        ],
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
                      onTapOutside: () =>
                          setState(() => _showDdStatusHidup = false),
                      content: Column(
                        children: [
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _statusHidup = 'Hidup';
                              _showDdStatusHidup = false;
                            }),
                            label: const Text('Hidup'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _statusHidup = 'Wafat';
                              _showDdStatusHidup = false;
                            }),
                            label: const Text('Wafat'),
                          ),
                        ],
                      ),
                      child: MoonTextInput(
                        textInputSize: MoonTextInputSize.xl,
                        readOnly: true,
                        hintText: _statusHidup ?? 'Status Hidup',
                        onTap: () => setState(
                          () => _showDdStatusHidup = !_showDdStatusHidup,
                        ),
                        trailing: DropDownTrailingArrow(
                          isShow: _showDdStatusHidup,
                        ),
                      ),
                    ),
                    // Dropdown Status Kependudukan
                    MoonDropdown(
                      show: _showDdStatusKependudukan,
                      constrainWidthToChild: true,
                      onTapOutside: () =>
                          setState(() => _showDdStatusKependudukan = false),
                      content: Column(
                        children: [
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _statusKependudukan = 'Aktif';
                              _showDdStatusKependudukan = false;
                            }),
                            label: const Text('Aktif'),
                          ),
                          MoonMenuItem(
                            onTap: () => setState(() {
                              _statusKependudukan = 'Nonaktif';
                              _showDdStatusKependudukan = false;
                            }),
                            label: const Text('Nonaktif'),
                          ),
                        ],
                      ),
                      child: MoonTextInput(
                        textInputSize: MoonTextInputSize.xl,
                        readOnly: true,
                        hintText: _statusKependudukan ?? 'Status Kependudukan',
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
                      key: const Key('area_upload_foto'), // ---> TAMBAHAN KEY 8
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      MoonIcons.generic_picture_32_light,
                                      size: 48,
                                      color: MoonTokens.light.colors.bulma,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Upload Foto KK/KTP',
                                      style: MoonTokens
                                          .light
                                          .typography
                                          .heading
                                          .text16
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap untuk memilih dari galeri atau kamera',
                                      style: MoonTokens
                                          .light
                                          .typography
                                          .body
                                          .text12
                                          .copyWith(
                                            color:
                                                MoonTokens.light.colors.trunks,
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
                                      // Tombol ganti foto
                                      Material(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(8),
                                        child: InkWell(
                                          onTap: _pickImage,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Tombol hapus foto
                                      Material(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _fotoKtp = null;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
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
                      trailing: Center(
                        child: Text(
                          'Show',
                          style: MoonTokens.light.typography.body.text14
                              .copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    TextInputLogin(
                      key: const Key(
                        'input_confirm_password',
                      ), // ---> TAMBAHAN KEY 12
                      controller: _confirmPasswordController,
                      hint: 'Konfirmasi Password',
                      isPassword: true,
                      trailing: Center(
                        child: Text(
                          'Show',
                          style: MoonTokens.light.typography.body.text14
                              .copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                LoginButton(
                  key: const Key('btn_submit_register'),
                  text: 'Daftar',
                  onTap: () {
                    createUserWithEmailAndPassword();
                  },
                  withColor: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(right: 8.0),
                        color: ConstantColors.separatorColor,
                      ),
                    ),
                    Text(
                      'Sudah punya akun?',
                      style: MoonTokens.light.typography.body.text12.copyWith(
                        color: ConstantColors.separatorColor,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 8.0),
                        color: ConstantColors.separatorColor,
                      ),
                    ),
                  ],
                ),
                LoginButton(
                  key: const Key('btn_goto_login'), // ---> TAMBAHAN KEY 14
                  text: 'Login',
                  onTap: () => context.go('/login'),
                  withColor: false,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  MoonTextInput dropDownChild({
    required String hintText,
    required bool isShow,
    required VoidCallback setState,
  }) {
    // Tambahan Key di sini juga biar aman jika mau testing dropdown detail
    return MoonTextInput(
      key: const Key('dropdown_child_input'),
      textInputSize: MoonTextInputSize.xl,
      readOnly: true,
      hintText: hintText,
      onTap: setState,
      trailing: DropDownTrailingArrow(isShow: isShow),
    );
  }

  Column inputGroup({required String title, required List<Widget> children}) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: MoonTokens.light.typography.heading.text16),
        ...children,
      ],
    );
  }
}
