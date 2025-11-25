import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SekretarisMenuKegiatan extends StatelessWidget {
  const SekretarisMenuKegiatan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text(
          'Kegiatan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            _buildMenuItem(
              icon: Icons.event_outlined,
              label: 'Daftar Kegiatan',
              color: const Color(0xFF6366F1),
              onTap: () => context.pushNamed('sekretaris_kegiatanList'),
            ),
            _buildMenuItem(
              icon: Icons.campaign_outlined,
              label: 'Daftar Broadcast',
              color: const Color(0xFF8B5CF6),
              onTap: () => context.pushNamed('sekretaris_broadcastList'),
            ),
            _buildMenuItem(
              icon: Icons.history,
              label: 'Log Aktifitas',
              color: const Color(0xFFA855F7),
              onTap: () => context.pushNamed('sekretaris_logAktivitas'),
            ),
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
