import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RTMenuPenduduk extends StatelessWidget {
  const RTMenuPenduduk({super.key});

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
          'Menu Penduduk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _buildMenuItem(
                  icon: Icons.people_outline,
                  label: 'Daftar Warga',
                  color: const Color(0xFF6366F1),
                  onTap: () => context.pushNamed('rt_wargaList'),
                ),
                _buildMenuItem(
                  icon: Icons.home_outlined,
                  label: 'Daftar Rumah',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => context.pushNamed('rt_rumahList'),
                ),
                _buildMenuItem(
                  icon: Icons.family_restroom_outlined,
                  label: 'Daftar Keluarga',
                  color: const Color(0xFFA855F7),
                  onTap: () => context.pushNamed('rt_keluargaList'),
                ),
                _buildMenuItem(
                  icon: Icons.swap_horiz,
                  label: 'Mutasi Keluarga',
                  color: const Color(0xFFD946EF),
                  onTap: () => context.pushNamed('rt_mutasiKeluargaList'),
                ),
                _buildMenuItem(
                  icon: Icons.person_add_outlined,
                  label: 'Penerimaan Warga',
                  color: const Color(0xFFEC4899),
                  onTap: () => context.pushNamed('rt_penerimaanList'),
                ),
                _buildMenuItem(
                  icon: Icons.event_outlined,
                  label: 'Daftar Kegiatan',
                  color: const Color(0xFF10B981),
                  onTap: () => context.pushNamed('rt_kegiatanList'),
                  isViewOnly: true,
                ),
                _buildMenuItem(
                  icon: Icons.campaign_outlined,
                  label: 'Daftar Broadcast',
                  color: const Color(0xFF14B8A6),
                  onTap: () => context.pushNamed('rt_broadcastList'),
                  isViewOnly: true,
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isViewOnly = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                if (isViewOnly)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
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
