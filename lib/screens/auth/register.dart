import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:jawara_pintar_kel_5/screens/auth/auth_service.dart';
import 'package:jawara_pintar_kel_5/widget/drop_down_trailing_arrow.dart';
import 'package:jawara_pintar_kel_5/widget/login_button.dart';
import 'package:jawara_pintar_kel_5/widget/text_input_login.dart';
import 'package:moon_design/moon_design.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }

  late final TextEditingController _namaController,
      _nikController,
      _phoneController,
      _passwordController,
      _confirmPasswordController,
      _alamatController,
      _controllerJenisKelamin;

  @override
  void initState() {
    _namaController = TextEditingController();
    _nikController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _alamatController = TextEditingController();
    _controllerJenisKelamin = TextEditingController();
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
    super.dispose();
  }

  final Map<int, String> _jenisKelamin = {1: 'Pria', 0: 'Wanita'};
  bool _showDdKelamin = false;

  Future<void> _pickImage() async {
    // Meminta izin akses penyimpanan
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _fotoKtp = pickedFile;
        });
      }
    } else {
      // Menampilkan snackbar atau memberi tahu pengguna bahwa izin diperlukan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin diperlukan untuk mengakses galeri')),
      );
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
              onTap: () => context.go('/login'),
              icon: Icon(MoonIcons.controls_chevron_left_32_regular),
            ),
            Text(
              "Daftar",
              style: MoonTokens.light.typography.heading.text40.copyWith(
                color: MoonTokens.light.colors.piccolo,
                fontWeight: FontWeight.w700,
              ),
              textScaler: TextScaler.linear(0.7),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: SingleChildScrollView(
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
                inputGroup(
                  title: 'Identitas',
                  children: [
                    TextInputLogin(
                      controller: _namaController,
                      hint: 'Nama Lengkap',
                      keyboardType: TextInputType.name,
                    ),
                    TextInputLogin(
                      controller: _nikController,
                      hint: 'NIK',
                      keyboardType: TextInputType.number,
                    ),
                    MoonDropdown(
                      show: _showDdKelamin,
                      constrainWidthToChild: true,
                      onTapOutside: () =>
                          setState(() => _showDdKelamin = false),
                      content: Column(
                        children: [
                          MoonMenuItem(
                            absorbGestures: true,
                            onTap: () => setState(() {
                              _showDdKelamin = false;
                              _controllerJenisKelamin.text =
                                  _jenisKelamin[1]!; // set controller value
                            }),
                            label: Text(_jenisKelamin[1]!),
                          ),
                          MoonMenuItem(
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
                      child: dropDownChild(
                        // show selected value from controller if available
                        hintText: _controllerJenisKelamin.text.isEmpty
                            ? 'Jenis Kelamin'
                            : _controllerJenisKelamin.text,
                        isShow: _showDdKelamin,
                        setState: () =>
                            setState(() => _showDdKelamin = !_showDdKelamin),
                      ),
                    ),
                    // replace the upload Container's onTap to call pickImage and show preview
                    Container(
                      width: double.infinity,
                      height: 100,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: MoonTokens.light.colors.goku,
                        border: Border.all(
                          color: MoonTokens.light.colors.beerus,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _pickImage();
                          },
                          child: _fotoKtp == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(MoonIcons.generic_picture_32_light),
                                    Text(
                                      'Upload foto KK/KTP (.jpg/.png)',
                                      style: MoonTokens
                                          .light
                                          .typography
                                          .heading
                                          .text14,
                                    ),
                                  ],
                                )
                              : Image.file(
                                  File(_fotoKtp!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                inputGroup(
                  title: 'Akun',
                  children: [
                    TextInputLogin(
                      controller: _controllerEmail,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextInputLogin(
                      controller: _phoneController,
                      hint: 'No Telepone',
                      keyboardType: TextInputType.phone,
                    ),
                    TextInputLogin(
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
    return MoonTextInput(
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
