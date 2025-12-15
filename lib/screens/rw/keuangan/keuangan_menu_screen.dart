import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RWMenuKeuangan extends StatelessWidget {
  const RWMenuKeuangan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keuangan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Kelola keuangan RW',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(top: BorderSide(color: iconColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.05),
                  iconColor.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [iconColor, iconColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: itemCount == 4
                  ? 1.4
                  : itemCount == 2
                  ? 1.6
                  : 1.3,
              children: children,
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled
                ? Colors.grey.shade300
                : const Color(0xFF6366F1).withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDisabled
                  ? Colors.transparent
                  : const Color(0xFF6366F1).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isDisabled
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade300,
                            ],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isDisabled
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                if (isViewOnly)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFFA726)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDisabled
                    ? Colors.grey.shade500
                    : const Color(0xFF1F2937),
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
