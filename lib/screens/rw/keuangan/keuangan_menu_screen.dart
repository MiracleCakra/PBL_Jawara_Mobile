import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RWMenuKeuangan extends StatelessWidget {
  const RWMenuKeuangan({super.key});

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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Pemasukan
            _buildSectionCard(
              context: context,
              title: 'Pemasukan',
              subtitle: 'Kelola data pemasukan',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFF6366F1),
              itemCount: 4,
              children: [
                _buildMenuItem(
                  icon: Icons.category_outlined,
                  label: 'Kategori Iuran',
                  onTap: () => context.pushNamed('rw_kategoriIuran'),
                ),
                _buildMenuItem(
                  icon: Icons.request_page_outlined,
                  label: 'Tagih Iuran',
                  onTap: () => context.pushNamed('rw_tagihIuran'),
                ),
                _buildMenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Tagihan',
                  onTap: () => context.pushNamed('rw_tagihan'),
                ),
                _buildMenuItem(
                  icon: Icons.attach_money,
                  label: 'Pemasukan Lain',
                  onTap: () => context.pushNamed('rw_pemasukanLain'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section Pengeluaran
            _buildSectionCard(
              context: context,
              title: 'Pengeluaran',
              subtitle: 'Kelola data pengeluaran',
              icon: Icons.trending_up_outlined,
              iconColor: const Color(0xFF8B5CF6),
              itemCount: 2,
              children: [
                _buildMenuItem(
                  icon: Icons.list_alt_outlined,
                  label: 'Daftar',
                  onTap: () => context.pushNamed('rw_pengeluaranList'),
                ),
                _buildMenuItem(
                  icon: Icons.add_circle_outline,
                  label: 'Tambah',
                  onTap: () => context.pushNamed('rw_pengeluaranAdd'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section Laporan Keuangan
            _buildSectionCard(
              context: context,
              title: 'Laporan Keuangan',
              subtitle: 'Lihat laporan dan analisis keuangan',
              icon: Icons.assessment_outlined,
              iconColor: const Color(0xFFA855F7),
              itemCount: 3,
              children: [
                _buildMenuItem(
                  icon: Icons.trending_down_outlined,
                  label: 'Pemasukan',
                  onTap: () => context.pushNamed('rw_laporanPemasukan'),
                ),
                _buildMenuItem(
                  icon: Icons.trending_up_outlined,
                  label: 'Pengeluaran',
                  onTap: () => context.pushNamed('rw_laporanPengeluaran'),
                ),
                _buildMenuItem(
                  icon: Icons.print_outlined,
                  label: 'Cetak Laporan',
                  onTap: () => context.pushNamed('rw_cetakLaporan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required int itemCount,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [iconColor.withOpacity(0.8), iconColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: itemCount == 4
                ? GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: children,
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: children.map((child) {
                      return SizedBox(
                        width: itemCount == 2
                            ? (MediaQuery.of(context).size.width - 80) / 2
                            : (MediaQuery.of(context).size.width - 92) / 3,
                        child: child,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isViewOnly = false,
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled ? Colors.grey.shade300 : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? Colors.grey.shade300
                        : const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDisabled
                        ? Colors.grey.shade500
                        : const Color(0xFF6366F1),
                    size: 24,
                  ),
                ),
                if (isViewOnly)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDisabled ? Colors.grey.shade500 : Colors.black87,
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
