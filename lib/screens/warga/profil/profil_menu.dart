import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'package:jawara_pintar_kel_5/services/warga_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilMenuWarga extends StatefulWidget {
  const ProfilMenuWarga({super.key});

  @override
  State<ProfilMenuWarga> createState() => _ProfilMenuWargaState();
}

class _ProfilMenuWargaState extends State<ProfilMenuWarga> {
  static const Color _primaryColor = Color(0xFF4E46B4);
  static const Color _secondaryColor = Color(0xFF6366F1);
  static const Color _accentColor = Color(0xFF3B82F6);
  static const Color _logoutColor = Color(0xFFEF4444);

  final WargaService _wargaService = WargaService();
  Warga? _currentUserWarga;
  bool _isLoading = true;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _userEmail = Supabase.instance.client.auth.currentUser?.email ?? '';
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final warga = await _wargaService.getWargaByEmail(_userEmail);
      if (mounted) {
        setState(() {
          _currentUserWarga = warga;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint("Error fetching profile: $e");
      }
    }
  }

  Future<void> _onLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _logoutColor),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(context),
                  const SizedBox(height: 24),

                  const Text(
                    'Pengaturan & Bantuan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.account_circle,
                        label: 'Lihat Profil',
                        color: _primaryColor,
                        onTap: () async {
                          await context.push('/warga/profil/data-diri');
                          _fetchUserData();
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.settings,
                        label: 'Pengaturan Akun',
                        color: _accentColor,
                        onTap: () => context.push('/warga/profil/pengaturan'),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.help_outline,
                        label: 'Pusat Bantuan',
                        color: _secondaryColor,
                        onTap: () => context.push('/warga/profil/bantuan'),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.info_outline,
                        label: 'Tentang Aplikasi',
                        color: _primaryColor.withOpacity(0.7),
                        onTap: () => context.push('/warga/profil/about'),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.logout,
                        label: 'Keluar',
                        color: _logoutColor,
                        onTap: () => _onLogout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final namaWarga = _currentUserWarga?.nama ?? 'Warga';
    final noKtp = _currentUserWarga?.id ?? '-'; // Menggunakan ID sebagai NIK
    final alamat = _currentUserWarga?.keluarga?.alamatRumah ?? '-';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon atau Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: _primaryColor.withOpacity(0.15),
            backgroundImage: _currentUserWarga?.fotoProfil != null
                ? NetworkImage(_currentUserWarga!.fotoProfil!)
                : null,
            child: _currentUserWarga?.fotoProfil == null
                ? Icon(Icons.person, size: 36, color: _primaryColor)
                : null,
          ),
          const SizedBox(width: 16),
          // Detail Profil
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaWarga,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'NIK: $noKtp',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  alamat,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
