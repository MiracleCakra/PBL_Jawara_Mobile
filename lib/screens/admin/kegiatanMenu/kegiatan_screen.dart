import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Model menu item (dipertahankan)
class MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  MenuItem({required this.icon, required this.label, required this.onTap});
}

class KegiatanScreen extends StatelessWidget {
  const KegiatanScreen({super.key});

  final pesanWargaPath = '/admin/kegiatan/pesanwarga';
  final logAktivitasPath = '/admin/kegiatan/logaktivitas';
  
  static const List<Color> _gradientKegiatan = [Color(0xFF4E46B4), Color(0xFF6366F1)]; 
  static const List<Color> _gradientBroadcast = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> _gradientPesanWarga = [Color(0xFF8B5CF6), Color(0xFFA855F7)];
  static const List<Color> _gradientLogAktivitas = [Color(0xFFA855F7), Color(0xFFC084FC)];

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
          'Kegiatan',
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

              /// ========================== KEGIATAN ==========================
              _buildMenuCard(
                context,
                icon: Icons.event,
                title: 'Kegiatan',
                subtitle: 'Kelola data kegiatan',
                gradientColors: _gradientKegiatan, 
                onTapCard: null, 
                menuItems: [
                  MenuItem(
                    icon: Icons.list_alt,
                    label: 'Daftar',
                    onTap: () => context.push('/admin/kegiatan/daftar'),
                  ),
                  MenuItem(
                    icon: Icons.add_circle_outline,
                    label: 'Tambah',
                    onTap: () => context.push('/admin/kegiatan/tambah'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// ========================== BROADCAST ==========================
              _buildMenuCard(
                context,
                icon: Icons.campaign,
                title: 'Broadcast',
                subtitle: 'Kelola data broadcast',
                gradientColors: _gradientBroadcast, 
                onTapCard: null, 
                menuItems: [
                  MenuItem(
                    icon: Icons.list_alt_outlined,
                    label: 'Daftar',
                    onTap: () => context.push('/admin/kegiatan/broadcast/daftar'),
                  ),
                  MenuItem(
                    icon: Icons.add_circle_outline,
                    label: 'Tambah',
                    onTap: () => context.push('/admin/kegiatan/broadcast/tambah'), 
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// ========================== PESAN WARGA (Direct Click) ==========================
              _buildMenuCard(
                context,
                icon: Icons.message,
                title: 'Pesan Warga',
                subtitle: 'Kelola pesan warga',
                gradientColors: _gradientPesanWarga, 
                onTapCard: () => context.push(pesanWargaPath),
                menuItems: const [],
              ),

              const SizedBox(height: 20),

              /// ========================== LOG AKTIVITAS (Direct Click) ==========================
              _buildMenuCard(
                context,
                icon: Icons.history,
                title: 'Log Aktivitas',
                subtitle: 'Jejak aktivitas pengguna',
                gradientColors: _gradientLogAktivitas, 
                onTapCard: () => context.push(logAktivitasPath),
                menuItems: const [],
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
    VoidCallback? onTapCard, 
  }) {
    final bool hasSubMenus = menuItems.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasSubMenus ? null : onTapCard, 
        borderRadius: BorderRadius.circular(20),
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
                color: gradientColors[0].withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, hasSubMenus ? 0 : 24), 
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 32),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ⭐ PERUBAHAN DI SINI: Ikon Panah Bulat Tanpa Border
                    if (!hasSubMenus) 
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),

              if (hasSubMenus) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: _buildFixedMenuGrid(context, menuItems),
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
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
                  color: Colors.white,
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedMenuGrid(BuildContext context, List<MenuItem> items) {
    // ... (Fungsi ini tidak diubah)
    const tileWidth = 86.0;
    const tileHeight = 76.0;
    const spacing = 10.0;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        return SizedBox(
          width: tileWidth,
          height: tileHeight,
          child: _buildGridIconButton(
            icon: item.icon,
            label: item.label,
            onTap: item.onTap,
          ),
        );
      }).toList(),
    );
  }
}
