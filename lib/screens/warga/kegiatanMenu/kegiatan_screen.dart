import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'broadcast/daftar_broadcast.dart';
import 'broadcast/tambah_broadcast.dart';
import 'pesanwarga/pesanwarga_tab.dart';

// Gradient color constants
const List<Color> _gradient1 = [Color(0xFF8A2BE2), Color(0xFF9370DB)];
const List<Color> _gradient2 = [Color(0xFF7B68EE), Color(0xFF9932CC)];
const List<Color> _gradient3 = [Color(0xFF4B0082), Color(0xFF9932CC)];
const List<Color> _gradient4 = [Color(0xFFBA55D3), Color(0xFFDA70D6)];

class KegiatanScreen extends StatelessWidget {
  const KegiatanScreen({super.key});

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), 
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.white, 
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 18, bottom: 10), 
                child: const Text(
                  'Kegiatan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
              
              const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)), 
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Pilih Menu',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
              ),
              // Menu Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _MenuCard(
                      title: 'Kegiatan',
                      subtitle: 'Kelola data kegiatan',
                      icon: Icons.event,
                      gradientColors: _gradient1,
                      daftarTap: () => context.push('/admin/kegiatan/daftar'),
                      tambahTap: () => context.push('/admin/kegiatan/tambah'),
                    ),
                    const SizedBox(height: 15),
                    _MenuCard(
                      title: 'Broadcast',
                      subtitle: 'Kelola data broadcast',
                      icon: Icons.campaign,
                      gradientColors: _gradient2,
                      daftarTap: () => _navigateToScreen(context, const DaftarBroadcastScreen()),
                      tambahTap: () => _navigateToScreen(context, const TambahBroadcastScreen()),
                    ),
                    const SizedBox(height: 15),
                    DirectMenuCard(
                      title: 'Pesan Warga',
                      subtitle: 'Kelola pesan warga',
                      icon: Icons.message,
                      gradientColors: _gradient3,
                      onTap: () => context.push('/admin/kegiatan/pesanwarga'),
                    ),
                    const SizedBox(height: 15),
                    DirectMenuCard(
                      title: 'Log Aktivitas',
                      subtitle: 'Lihat log aktivitas pengguna',
                      icon: Icons.history,
                      gradientColors: _gradient4,
                      onTap: () => context.push('/admin/kegiatan/logaktivitas'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback daftarTap;
  final VoidCallback tambahTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.daftarTap,
    required this.tambahTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: daftarTap,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.18),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.list_alt, color: Colors.white, size: 24),
                      SizedBox(height: 2),
                      Text('Daftar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextButton(
                  onPressed: tambahTap,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.18),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.add_circle, color: Colors.white, size: 24),
                      SizedBox(height: 2),
                      Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DirectMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradientColors;

  const DirectMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.gradientColors,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
