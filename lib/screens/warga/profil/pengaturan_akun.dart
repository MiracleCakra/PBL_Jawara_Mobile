import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moon_design/moon_design.dart';
import 'package:jawara_pintar_kel_5/widget/marketplace/custom_dialog.dart';


class PengaturanAkunScreen extends StatelessWidget {
  const PengaturanAkunScreen({super.key});

  static const Color _primaryColor = Color(0xFF6A5AE0);
  static const Color _dangerColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            MoonButton.icon(
              onTap: () => context.pop(),
              icon: const Icon(MoonIcons.controls_chevron_left_32_regular, color: Colors.black),
            ),
            const SizedBox(width: 8),
            Text(
              "Pengaturan Akun",
              style: MoonTokens.light.typography.heading.text40.copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w700,
              ),
              textScaler: const TextScaler.linear(0.7),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Keamanan Akun'),
            _buildSettingsCard(
              children: [
                _buildSettingItem(
                  context,
                  icon: Icons.lock_outline,
                  title: 'Ganti Kata Sandi',
                  subtitle: 'Ubah password Anda secara berkala untuk keamanan.',
                  color: _primaryColor,
                  onTap: () => context.push('/warga/profil/pengaturan/ganti-password'),
                ),
              ],
            ),

            const SizedBox(height: 24),
            
            _buildSectionTitle('Zona Bahaya', color: _dangerColor),
            _buildSettingsCard(
              children: [
                _buildSettingItem(
                  context,
                  icon: Icons.person_remove_alt_1_outlined,
                  title: 'Hapus Akun Permanen',
                  subtitle: 'Semua data akan dihapus dan tidak dapat dikembalikan.',
                  color: _dangerColor,
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title, {Color color = const Color(0xFF1F2937)}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1), // Border tipis
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
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final widget = entry.value;
          
          return Column(
            children: [
              widget,
              if (index < children.length - 1)
                const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  // Future<void> _onLogout(BuildContext context) async {
  //   final confirm = await CustomConfirmDialog.show(
  //     context: context,
  //     type: DialogType.warning, 
  //     title: 'Keluar dari Aplikasi',
  //     message: 'Apakah Anda yakin ingin keluar dari aplikasi? Anda harus login kembali untuk mengakses aplikasi.',
  //     cancelText: 'Batal',
  //     confirmText: 'Ya, Keluar',
  //   );

  //   if (confirm == true) {
  //     AuthService().signOut();
  //     if (mounted) {
  //       context.replace('/login'); 
  //     }
  //   }
  // }

void _showDeleteAccountDialog(BuildContext context) async {
  final confirm = await CustomConfirmDialog.show(
    context: context,
    type: DialogType.error, 
    title: 'Hapus Akun Permanen',
    message: 'Anda yakin ingin menghapus akun ini secara permanen? Semua data akan dihapus dan TIDAK dapat dikembalikan. Tindakan ini tidak dapat dibatalkan.',
    cancelText: 'Batal',
    confirmText: 'Ya, Hapus',
  );

  if (confirm == true) {

    // TODO: Implementasi logika hapus akun di sini (misalnya: AuthService().deleteUser())

    if (context.mounted) {
      CustomSnackbar.show(
        context: context,
        message: 'Akun berhasil dihapus.',
        type: DialogType.success,
      );
      
      context.go('/'); 
    }
  }
}

  // void _showDeleteAccountDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       title: const Text('Hapus Akun', style: TextStyle(fontWeight: FontWeight.bold)),
  //       content: const Text(
  //         'Anda yakin ingin menghapus akun ini secara permanen? Tindakan ini tidak dapat dibatalkan.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('Batal', style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600)),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: _dangerColor,
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //             elevation: 0,
  //           ),
  //           onPressed: () {
  //             // TODO: Implementasi logika hapus akun di sini
  //             Navigator.of(context).pop(); 
  //             context.go('/'); 
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(content: Text('Akun berhasil dihapus.')),
  //             );
  //           },
  //           child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}