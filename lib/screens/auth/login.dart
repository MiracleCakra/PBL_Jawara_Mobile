import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:jawara_pintar_kel_5/widget/login_button.dart';
import 'package:jawara_pintar_kel_5/widget/system_ui_style.dart';
import 'package:jawara_pintar_kel_5/widget/text_input_login.dart';
import 'package:moon_design/moon_design.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;

  // get auth service
  final authService = AuthService();

  final TextEditingController _controllerEmail = TextEditingController(
    text: '',
  );
  final TextEditingController _controllerPassword = TextEditingController(
    text: '',
  );

  @override
  void initState() {
    super.initState();
    debugPrint(
      "Mencoba memuat data warga. Status login: ${Supabase.instance.client.auth.currentSession ?? 'Tidak Login'}",
    );
  }

  /*Future<void> signInWithEmailAndPassword() async {
    try {
      await authService.signInWithEmailPassword(
        _controllerEmail.text,
        _controllerPassword.text,
      );

      // Navigasi ke halaman dashboard setelah berhasil login
      context.go('/warga/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: Email / Password salah')),
      );
      print(e);
    }
  }*/
  Future<void> signIn() async {
    String email = _controllerEmail.text.trim();
    String password = _controllerPassword.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email & Password tidak boleh kosong')),
      );
      return;
    }

    try {
      // Call the auth service (ignore any specific 'error' field here)
      await authService.signInWithEmailPassword(email, password);

      // Cek apakah sesi aktif setelah login
      final session = Supabase.instance.client.auth.currentSession;
      final response = await Supabase.instance.client
          .from('warga')
          .select('role')
          .eq('email', email)
          .single();
      if (session != null) {
        // Shared_preferences
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString('role', response['role']);

        String role = response['role'];

        print(role);
        switch (role) {
          case "Admin":
            context.go('/admin/dashboard', extra: {'role': role});
            break;
          case "RW":
            context.go('/rw/penduduk', extra: {'role': role});
            break;
          case "RT":
            context.go('/rt/penduduk', extra: {'role': role});
            break;
          case "Sekretaris":
            context.go('/sekretaris/kegiatan', extra: {'role': role});
            break;
          case "Bendahara":
            context.go('/bendahara/keuangan', extra: {'role': role});
            break;
          case "Warga":
            context.go('/warga/dashboard', extra: {'role': role});
            break;
          default:
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Role tidak dikenal')));
        }
      } else {
        // Jika session tidak ditemukan, tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session not found after login')),
        );
      }
    } catch (e) {
      // Tampilkan pesan error jika terjadi exception saat login
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  bool _showLoginForm = false;

  final _loginFormHeight = 350.0;

  void _setShowLoginForm(bool value) {
    if (!mounted) return;
    if (!value) {
      FocusScope.of(context).unfocus();
    }
    setState(() => _showLoginForm = value);
  }

  void _toggleLoginForm() => _setShowLoginForm(!_showLoginForm);

  @override
  Widget build(BuildContext context) {
    return SystemUiStyle(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final heightPercentage =
                constraints.maxHeight / MediaQuery.of(context).size.height;
            final mascoutHeight =
                MediaQuery.of(context).size.height * 0.4 * heightPercentage;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox.shrink(),
                    if (constraints.maxHeight > 420)
                      Flexible(
                        child: AnimatedContainer(
                          duration: heightPercentage != 1.0
                              ? Duration.zero
                              : const Duration(milliseconds: 700),
                          curve: Curves.fastOutSlowIn,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          alignment: Alignment.center,
                          height: _showLoginForm
                              ? max(mascoutHeight - _loginFormHeight / 2, 50)
                              : mascoutHeight,
                          child: GestureDetector(
                            onTap: () => _setShowLoginForm(false),
                            child: Image.asset(
                              "assets/login_banner.webp",
                              key: const Key(
                                'banner_image',
                              ), // ---> KEY DITAMBAHKAN
                            ),
                          ),
                        ),
                      ),
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final textStyle =
                                      MediaQuery.of(context).size.height > 600
                                      ? MoonTokens
                                            .light
                                            .typography
                                            .heading
                                            .text48
                                      : MoonTokens
                                            .light
                                            .typography
                                            .heading
                                            .text24;
                                  final children = [
                                    Text(
                                      "Jawara ",
                                      style: textStyle.copyWith(
                                        color: MoonTokens.light.colors.piccolo,
                                      ),
                                    ),
                                    Text("Pintar", style: textStyle),
                                  ];
                                  if (constraints.maxWidth < 300) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: children,
                                    );
                                  }
                                  return Row(children: children);
                                },
                              ),
                              const SizedBox(height: 4),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity: _showLoginForm ? 0 : 1,
                                child: AnimatedContainer(
                                  duration: heightPercentage != 1.0
                                      ? Duration.zero
                                      : const Duration(milliseconds: 300),
                                  curve: Curves.easeInExpo,
                                  height: _showLoginForm ? 0 : 145,
                                  child: SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      spacing: 14,
                                      children: [
                                        loginUntukMengakses(),
                                        LoginButton(
                                          key: const Key(
                                            'btn_show_login_form',
                                          ), // ---> KEY DITAMBAHKAN
                                          text: "Login",
                                          onTap: _toggleLoginForm,
                                        ),
                                        LoginButton(
                                          key: const Key(
                                            'btn_to_register',
                                          ), // ---> KEY DITAMBAHKAN
                                          text: "Daftar",
                                          onTap: () => context.go("/register"),
                                          withColor: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        AnimatedContainer(
                          duration: heightPercentage != 1.0
                              ? Duration.zero
                              : const Duration(milliseconds: 300),
                          curve: Curves.easeInExpo,
                          height: _showLoginForm ? _loginFormHeight : 0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: MoonTokens.light.colors.goku,
                          ),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 24.0,
                                left: 24,
                                bottom: 24,
                              ),
                              child: Column(
                                spacing: 14,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "Login",
                                    style: MoonTokens
                                        .light
                                        .typography
                                        .heading
                                        .text32
                                        .copyWith(
                                          color:
                                              MoonTokens.light.colors.piccolo,
                                        ),
                                  ),
                                  loginUntukMengakses(),
                                  TextInputLogin(
                                    key: const Key('input_email'),
                                    hint: 'Email',
                                    controller: _controllerEmail,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  TextInputLogin(
                                    key: const Key(
                                      'input_password',
                                    ), // ---> KEY DITAMBAHKAN
                                    hint: 'Password',
                                    isPassword: true,
                                    controller: _controllerPassword,
                                    trailing: Center(
                                      child: Text(
                                        'Show',
                                        style: MoonTokens
                                            .light
                                            .typography
                                            .body
                                            .text14
                                            .copyWith(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                      ),
                                    ),
                                  ),
                                  LoginButton(
                                    key: const Key(
                                      'btn_submit_login',
                                    ), // ---> KEY DITAMBAHKAN
                                    text: "Login",
                                    onTap: () => signIn(),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Belum terdaftar? ',
                                        style: MoonTokens
                                            .light
                                            .typography
                                            .body
                                            .text12
                                            .copyWith(
                                              color:
                                                  ConstantColors.separatorColor,
                                            ),
                                      ),
                                      InkWell(
                                        key: const Key(
                                          'link_create_account',
                                        ), // ---> KEY DITAMBAHKAN (OPSIONAL)
                                        onTap: () => context.go('/register'),
                                        child: Text(
                                          'Buat Akun',
                                          style: MoonTokens
                                              .light
                                              .typography
                                              .body
                                              .text12
                                              .copyWith(
                                                color: MoonTokens
                                                    .light
                                                    .colors
                                                    .whis,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Align loginUntukMengakses() {
    return Align(
      alignment: AlignmentGeometry.centerLeft,
      child: Text(
        'Login untuk mengakses sistem Jawara Pintar.',
        style: MoonTokens.light.typography.body.text14,
      ),
    );
  }
}
