import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final authService = AuthService();
  final TextEditingController _controllerEmail = TextEditingController(text: '');
  final TextEditingController _controllerPassword = TextEditingController(text: '');

  bool _showLoginForm = false;
  final _loginFormHeight = 420.0;

  // --- LOGIC AUTHENTICATION ---
  @override
  void initState() {
    super.initState();
    debugPrint("Mencoba memuat data warga. Status: ${Supabase.instance.client.auth.currentSession ?? 'Tidak Login'}");
  }

  Future<void> signIn() async {
    String email = _controllerEmail.text.trim();
    String password = _controllerPassword.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email & Password tidak boleh kosong')));
      return;
    }

    try {
      await authService.signInWithEmailPassword(email, password);
      final session = Supabase.instance.client.auth.currentSession;
      final response = await Supabase.instance.client
          .from('warga')
          .select('role')
          .eq('email', email)
          .single();

      if (session != null) {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString('role', response['role']);
        String role = response['role'];

        if (!mounted) return;

        switch (role) {
          case "Admin": context.go('/admin/penduduk', extra: {'role': role}); break;
          case "RW": context.go('/rw/penduduk', extra: {'role': role}); break;
          case "RT": context.go('/rt/penduduk', extra: {'role': role}); break;
          case "Sekretaris": context.go('/sekretaris/kegiatan', extra: {'role': role}); break;
          case "Bendahara": context.go('/bendahara/keuangan', extra: {'role': role}); break;
          case "Warga": context.go('/warga/dashboard', extra: {'role': role}); break;
          default: ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role tidak dikenal')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session not found after login')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _setShowLoginForm(bool value) {
    if (!mounted) return;
    if (!value) FocusScope.of(context).unfocus();
    setState(() => _showLoginForm = value);
  }

  void _toggleLoginForm() => _setShowLoginForm(!_showLoginForm);

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Biru Primary (Piccolo)
    final Color primaryColor = MoonTokens.light.colors.piccolo;

    return SystemUiStyle(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // --- BACKGROUND GRADIENT (Dengan Nuansa Biru Primary) ---
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    // Bagian atas: Biru Primary transparansi 10%
                    primaryColor.withOpacity(0.10),
                    Colors.white,
                    // Bagian bawah: Biru Primary transparansi 5%
                    primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
            ),

            // --- DECORATIVE ELEMENTS (ORBS - Nuansa Biru) ---
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Spacer animasi
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        height: _showLoginForm ? 20 : 80,
                        curve: Curves.fastOutSlowIn,
                      ),

                      // --- LOGO & HEADER SECTION ---
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.fastOutSlowIn,
                        alignment: _showLoginForm ? Alignment.centerLeft : Alignment.center,
                        child: Column(
                          crossAxisAlignment: _showLoginForm ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _setShowLoginForm(false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.fastOutSlowIn,
                                height: _showLoginForm ? 120 : 250,
                                width: _showLoginForm ? 120 : 250,
                                child: Image.asset(
                                  "assets/sapa_warga.webp",
                                  key: const Key('banner_image'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Judul "Sapa Warga" (Sapa = Biru Primary)
                            _buildAnimatedTitle(primaryColor),

                            // Slogan
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Warga Berdaya, Usaha Berjaya.',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: _showLoginForm ? TextAlign.left : TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- INITIAL BUTTONS (Tampilan Awal) ---
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height: _showLoginForm ? 0 : 250,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Opacity(
                            opacity: _showLoginForm ? 0 : 1,
                            child: Column(
                              children: [
                                LoginButton(
                                  key: const Key('btn_show_login_form'),
                                  text: "Login",
                                  onTap: _toggleLoginForm,
                                  withColor: true, // Akan menggunakan warna Primary
                                ),
                                const SizedBox(height: 16),
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
                                      'Belum punya akun?',
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
                                const SizedBox(height: 16),
                                LoginButton(
                                  key: const Key('btn_to_register'),
                                  text: "Daftar",
                                  onTap: () => context.go("/register"),
                                  withColor: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // --- FORM LOGIN (Card Putih) ---
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.fastOutSlowIn,
                        height: _showLoginForm ? _loginFormHeight : 0,
                        margin: EdgeInsets.only(top: _showLoginForm ? 30 : 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _showLoginForm ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 25,
                              spreadRadius: 1,
                              offset: const Offset(0, 5)
                            )
                          ] : [],
                        ),
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Form (Back + Title dengan Warna Primary)
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: _toggleLoginForm,
                                      // Panah Back jadi Biru Primary
                                      icon: Icon(Icons.arrow_back, color: primaryColor),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Login",
                                      // Tulisan Login jadi Biru Primary
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
                                  'Masuk untuk melanjutkan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Inputs
                                TextInputLogin(
                                  key: const Key('input_email'),
                                  hint: 'Email',
                                  controller: _controllerEmail,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),

                                TextInputLogin(
                                  key: const Key('input_password'),
                                  hint: 'Password',
                                  isPassword: true,
                                  controller: _controllerPassword,
                                ),
                                const SizedBox(height: 24),

                                // Submit Button
                                LoginButton(
                                  key: const Key('btn_submit_login'),
                                  text: "Login",
                                  onTap: () => signIn(),
                                  withColor: true, // Akan menggunakan warna Primary
                                ),
                                
                                const SizedBox(height: 20),

                                // Link Daftar
                                Center(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      children: [
                                        const TextSpan(text: 'Belum punya akun? '),
                                        TextSpan(
                                          text: 'Daftar Sekarang',
                                          style: TextStyle(
                                            color: primaryColor, // Link warna Primary
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () => context.go('/register'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Padding bawah extra agar aman saat scroll
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

  Widget _buildAnimatedTitle(Color primaryColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double fontSize = _showLoginForm ? 28 : 36;
        return Row(
          mainAxisAlignment: _showLoginForm ? MainAxisAlignment.start : MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Sapa",
              // Tulisan "Sapa" jadi Biru Primary
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            Text(
              "Warga",
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }
}