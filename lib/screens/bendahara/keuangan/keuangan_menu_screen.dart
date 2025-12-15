import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BendaharaMenuKeuangan extends StatelessWidget {
  const BendaharaMenuKeuangan({super.key});

  // Palette warna ungu yang konsisten
  static const Color _primaryPurple = Color(0xFF6366F1);
  static const Color _lightPurple = Color(0xFF8B5CF6);
  static const Color _mediumPurple = Color(0xFFA855F7);
  static const Color _deepPurple = Color(0xFF7C3AED);
  static const Color _softPurple = Color(0xFF9333EA);
  static const Color _palePurple = Color(0xFFC084FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF), // Ungu sangat terang
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Keuangan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card dengan Gradient
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // Section: Manajemen Iuran
            _buildSectionHeader('Manajemen Iuran', Icons.receipt_long),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                _buildMenuItem(
                  icon: Icons.category_outlined,
                  label: 'Kategori Iuran',
                  color: _primaryPurple,
                  onTap: () => context.pushNamed('bendahara_kategoriIuran'),
                ),
                _buildMenuItem(
                  icon: Icons.request_page_outlined,
                  label: 'Tagih Iuran',
                  color: _lightPurple,
                  onTap: () => context.pushNamed('bendahara_tagihIuran'),
                ),
                _buildMenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Tagihan',
                  color: _mediumPurple,
                  onTap: () => context.pushNamed('bendahara_tagihan'),
                ),
                _buildMenuItem(
                  icon: Icons.attach_money,
                  label: 'Pemasukan Lain',
                  color: _deepPurple,
                  onTap: () => context.pushNamed('bendahara_pemasukanLain'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section: Pengeluaran
            _buildSectionHeader('Pengeluaran', Icons.trending_up),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                _buildMenuItem(
                  icon: Icons.list_alt_outlined,
                  label: 'Daftar Pengeluaran',
                  color: _softPurple,
                  onTap: () => context.pushNamed('bendahara_pengeluaranList'),
                ),
                _buildMenuItem(
                  icon: Icons.add_circle_outline,
                  label: 'Tambah Pengeluaran',
                  color: _palePurple,
                  onTap: () => context.pushNamed('bendahara_pengeluaranAdd'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section: Laporan
            _buildSectionHeader('Laporan & Cetak', Icons.bar_chart),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                _buildMenuItem(
                  icon: Icons.trending_down_outlined,
                  label: 'Laporan Pemasukan',
                  color: _primaryPurple,
                  onTap: () => context.pushNamed('bendahara_laporanPemasukan'),
                ),
                _buildMenuItem(
                  icon: Icons.trending_up_outlined,
                  label: 'Laporan Pengeluaran',
                  color: _lightPurple,
                  onTap: () =>
                      context.pushNamed('bendahara_laporanPengeluaran'),
                ),
                _buildMenuItem(
                  icon: Icons.print_outlined,
                  label: 'Cetak Laporan',
                  color: _mediumPurple,
                  onTap: () => context.pushNamed('bendahara_cetakLaporan'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section: Channel Pembayaran
            _buildSectionHeader('Channel Pembayaran', Icons.payment),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                _buildMenuItem(
                  icon: Icons.list_outlined,
                  label: 'Daftar Channel',
                  color: _deepPurple,
                  onTap: () => context.pushNamed('bendahara_channelList'),
                ),
                _buildMenuItem(
                  icon: Icons.add_outlined,
                  label: 'Tambah Channel',
                  color: _softPurple,
                  onTap: () => context.pushNamed('bendahara_channelAdd'),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sistem Keuangan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kelola keuangan RT/RW',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Akses Bendahara',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 3,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
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
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color.withOpacity(0.9),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
