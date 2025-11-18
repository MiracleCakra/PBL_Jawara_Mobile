import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/widget/gradient_menu_card.dart';

class PendudukMenuScreen extends StatelessWidget {
  const PendudukMenuScreen({super.key});

  void _showKeluargaSubMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Menu Keluarga',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih menu yang ingin Anda akses',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                // Sub-menu items
                _buildSubMenuItem(
                  context,
                  icon: Icons.family_restroom,
                  title: 'Keluarga',
                  subtitle: 'Kelola data keluarga',
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed('keluargaList');
                  },
                ),
                const SizedBox(height: 12),
                _buildSubMenuItem(
                  context,
                  icon: Icons.sync_alt,
                  title: 'Mutasi Keluarga',
                  subtitle: 'Kelola mutasi data keluarga',
                  color: const Color(0xFFA855F7),
                  onTap: () {
                    Navigator.pop(context);
                    context.pushNamed('mutasiKeluargaList');
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Penduduk',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Menu',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            GradientMenuCard(
              icon: Icons.people_rounded,
              title: 'Warga',
              subtitle: 'Kelola data warga dan penduduk',
              gradientColors: const [Color(0xFF4E46B4), Color(0xFF6366F1)],
              onTap: () => context.pushNamed('wargaList'),
            ),
            const SizedBox(height: 20),
            GradientMenuCard(
              icon: Icons.home_rounded,
              title: 'Rumah',
              subtitle: 'Kelola data rumah dan bangunan',
              gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              onTap: () => context.pushNamed('rumahList'),
            ),
            const SizedBox(height: 20),
            GradientMenuCard(
              icon: Icons.family_restroom_rounded,
              title: 'Keluarga',
              subtitle: 'Kelola data keluarga',
              gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA855F7)],
              onTap: () => _showKeluargaSubMenu(context),
            ),
            const SizedBox(height: 20),
            GradientMenuCard(
              icon: Icons.person_add_rounded,
              title: 'Penerimaan Warga',
              subtitle: 'Kelola pengajuan penerimaan warga baru',
              gradientColors: const [Color(0xFFA855F7), Color(0xFFC084FC)],
              onTap: () => context.pushNamed('penerimaanList'),
            ),
          ],
        ),
      ),
    );
  }
}
