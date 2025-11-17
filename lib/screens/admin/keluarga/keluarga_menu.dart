import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KeluargaMenuPage extends StatelessWidget {
  const KeluargaMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text(
          'Keluarga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: SingleChildScrollView(
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
              _buildMenuCard(
                context,
                icon: Icons.people_outline_rounded,
                title: 'Mutasi Keluarga',
                subtitle:
                    'Kelola data mutasi keluarga, perpindahan, dan penambahan',
                gradientColors: const [
                  Color(0xFF1976D2), // Biru tua
                  Color(0xFF8B5CF6)
                ],
                menuItems: [
                  MenuItem(
                    icon: Icons.group_outlined,
                    label: 'Daftar Keluarga',
                    onTap: () => context.goNamed('listKeluarga'),
                  ),
                  MenuItem(
                    icon: Icons.list_alt_rounded,
                    label: 'Daftar Mutasi',
                    onTap: () => context.go('/admin/keluarga/daftar'),
                  ),
                  MenuItem(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Tambah Mutasi',
                    onTap: () => context.go('/admin/keluarga/tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildMenuCard(
                context,
                icon: Icons.person_search_rounded,
                title: 'Manajemen Warga',
                subtitle: 'Kelola data warga, tambah, ubah, dan hapus data',
                gradientColors: const [
                  Color(0xFF6A1B9A), // Ungu tua
                  Color(0xFFEC407A)
                ],
                menuItems: [
                  MenuItem(
                    icon: Icons.group_outlined,
                    label: 'Daftar Warga',
                    onTap: () => context.goNamed('listWarga'),
                  ),
                  MenuItem(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Tambah Warga',
                    onTap: () => context.goNamed('tambahWarga'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // Latar belakang TERANG
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3), // Border TERANG
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25), // Latar ikon TERANG
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24), // Ikon PUTIH
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white, // Teks PUTIH
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required List<MenuItem> menuItems,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // Latar TERANG
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3), // Border TERANG
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32), // Ikon PUTIH
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 24.0, left: 24.0, right: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: menuItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 86,
                      height: 76,
                      child: _buildGridIconButton(
                        icon: item.icon,
                        label: item.label,
                        onTap: item.onTap,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  MenuItem({required this.icon, required this.label, required this.onTap});
}