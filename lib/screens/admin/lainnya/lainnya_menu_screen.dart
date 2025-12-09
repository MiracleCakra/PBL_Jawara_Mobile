import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:jawara_pintar_kel_5/screens/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model menu item
class MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  MenuItem({required this.icon, required this.label, required this.onTap});
}

class LainnyaScreen extends StatefulWidget {
  const LainnyaScreen({super.key});

  @override
  State<LainnyaScreen> createState() => _LainnyaScreenState();
}

class _LainnyaScreenState extends State<LainnyaScreen> {
  final authService = AuthService();
  final _currentEmail = Supabase.instance.client.auth.currentUser?.email;
  double _opacity = 0;
  String _namaPengguna = 'Memuat...';
  String _emailPengguna = '';
  String _rolePengguna = '-';
  String? _fotoProfilUrl;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _opacity = 1);
    });
    _fetchUserData();
  }

  // FETCH
  Future<void> _fetchUserData() async {
    try {
      final userEmail = Supabase.instance.client.auth.currentUser?.email;
      
      if (userEmail != null) {
        setState(() {
          _emailPengguna = userEmail;
        });

        final response = await Supabase.instance.client
            .from('warga')
            .select('nama, role, foto_profil')
            .eq('email', userEmail)
            .single();

        if (mounted) {
          setState(() {
            _namaPengguna = response['nama'] ?? 'Tanpa Nama';
            _rolePengguna = response['role'] ?? 'Warga';
            _fotoProfilUrl = response['foto_profil'];
            _isLoadingProfile = false;
          });
        }
      } else {
        // Tidak ada user yang terautentikasi
        if (mounted) {
          setState(() {
            _isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetch profile: $e');
      if (mounted) {
        setState(() {
          _namaPengguna = 'Gagal memuat';
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _onLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 48),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Keluar dari Aplikasi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Apakah Anda yakin ingin keluar dari aplikasi? Anda harus login kembali untuk mengakses aplikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('confirm_logout_button'),
                        onPressed: () {
                          Navigator.pop(context);
                          authService.signOut();
                          context.go('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    );
  }

  // Quick Button (Menu Grid)
  Widget quickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? iconBackgroundColor,
    Key? key,
  }) {
    final effectiveIconColor = iconColor ?? ConstantColors.primary;
    final effectiveBackgroundColor =
        iconBackgroundColor ?? ConstantColors.primary.withOpacity(0.15);

    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: effectiveIconColor, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Daftar menu items
  List<MenuItem> get menuItems {
    return [
      MenuItem(
        icon: Icons.person_outline,
        label: 'Pengguna',
        onTap: () => context.push('/admin/lainnya/manajemen-pengguna'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final allMenuItems = menuItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 80),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lainnya",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Pengaturan akun dan manajemen sistem",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          final result = await context.push('/admin/lainnya/edit-profile');
                          if (result == true) {
                            _fetchUserData();
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _fotoProfilUrl != null && _fotoProfilUrl!.isNotEmpty
                                  ? Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: DecorationImage(
                                          image: NetworkImage(_fotoProfilUrl!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6366F1),
                                            Color(0xFF8B5CF6),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Tampilkan Nama (atau Loading)
                                    _isLoadingProfile 
                                      ? Container(
                                          width: 100, height: 16, 
                                          color: Colors.grey[200],
                                        )
                                      : Text(
                                          _namaPengguna,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                    const SizedBox(height: 4),
                                    // Tampilkan Email
                                    Text(
                                      _emailPengguna,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _isLoadingProfile
                                      ? Container(width: 60, height: 20, color: Colors.grey[200])
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ConstantColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _rolePengguna,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: ConstantColors.primary,
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Menu Section
                      const Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid Menu
                      Row(
                        children: [
                          Expanded(
                            child: quickButton(
                              icon: allMenuItems[0].icon,
                              label: allMenuItems[0].label,
                              onTap: allMenuItems[0].onTap,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: quickButton(
                              key: const Key('logout_button'),
                              icon: Icons.logout,
                              label: 'Keluar',
                              onTap: () => _onLogout(context),
                              iconColor: Colors.red,
                              iconBackgroundColor: Colors.red.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}