import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BendaharaMenuKeuangan extends StatelessWidget {
  const BendaharaMenuKeuangan({super.key});

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
          'Keuangan',
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
              icon: Icons.category_outlined,
              label: 'Kategori Iuran',
              color: const Color(0xFF6366F1),
              onTap: () => context.pushNamed('bendahara_kategoriIuran'),
            ),
            _buildMenuItem(
              icon: Icons.request_page_outlined,
              label: 'Tagih Iuran',
              color: const Color(0xFF8B5CF6),
              onTap: () => context.pushNamed('bendahara_tagihIuran'),
            ),
            _buildMenuItem(
              icon: Icons.receipt_long_outlined,
              label: 'Tagihan',
              color: const Color(0xFFA855F7),
              onTap: () => context.pushNamed('bendahara_tagihan'),
            ),
            _buildMenuItem(
              icon: Icons.attach_money,
              label: 'Pemasukan Lain',
              color: const Color(0xFFD946EF),
              onTap: () => context.pushNamed('bendahara_pemasukanLain'),
            ),
            _buildMenuItem(
              icon: Icons.list_alt_outlined,
              label: 'Daftar Pengeluaran',
              color: const Color(0xFFEC4899),
              onTap: () => context.pushNamed('bendahara_pengeluaranList'),
            ),
            _buildMenuItem(
              icon: Icons.add_circle_outline,
              label: 'Tambah Pengeluaran',
              color: const Color(0xFFF43F5E),
              onTap: () => context.pushNamed('bendahara_pengeluaranAdd'),
            ),
            _buildMenuItem(
              icon: Icons.trending_down_outlined,
              label: 'Laporan Pemasukan',
              color: const Color(0xFFF97316),
              onTap: () => context.pushNamed('bendahara_laporanPemasukan'),
            ),
            _buildMenuItem(
              icon: Icons.trending_up_outlined,
              label: 'Laporan Pengeluaran',
              color: const Color(0xFFFB923C),
              onTap: () => context.pushNamed('bendahara_laporanPengeluaran'),
            ),
            _buildMenuItem(
              icon: Icons.print_outlined,
              label: 'Cetak Laporan',
              color: const Color(0xFFFBBF24),
              onTap: () => context.pushNamed('bendahara_cetakLaporan'),
            ),
            _buildMenuItem(
              icon: Icons.list_outlined,
              label: 'Daftar Channel',
              color: const Color(0xFF10B981),
              onTap: () => context.pushNamed('bendahara_channelList'),
            ),
            _buildMenuItem(
              icon: Icons.add_outlined,
              label: 'Tambah Channel',
              color: const Color(0xFF14B8A6),
              onTap: () => context.pushNamed('bendahara_channelAdd'),
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
                  colors: [
                    color.withOpacity(0.8),
                    color,
                  ],
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
