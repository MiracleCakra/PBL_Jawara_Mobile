import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moon_design/moon_design.dart';

class RTDashboard extends StatefulWidget {
  const RTDashboard({super.key});

  @override
  State<RTDashboard> createState() => _RTDashboardState();
}

class _RTDashboardState extends State<RTDashboard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 6),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dashboard RT",
                      style: MoonTokens.light.typography.heading.text20
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    Material(
                      color: Colors.grey,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          // Navigate to edit profile
                        },
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(child: Icon(Icons.person)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildMenuCard(
                  context,
                  icon: Icons.people,
                  title: 'Data Warga & Rumah',
                  subtitle: 'Kelola data warga dan rumah',
                  onTap: () {
                    context.go('/rt/penduduk');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: 'Pemasukan (Lihat Saja)',
                  subtitle: 'Lihat data pemasukan',
                  onTap: () {
                    context.go('/rt/keuangan');
                  },
                  isViewOnly: true,
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.money_off,
                  title: 'Pengeluaran (Lihat Saja)',
                  subtitle: 'Lihat data pengeluaran',
                  onTap: () {
                    context.go('/rt/keuangan');
                  },
                  isViewOnly: true,
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.assessment,
                  title: 'Laporan Keuangan',
                  subtitle: 'Lihat laporan keuangan',
                  onTap: () {
                    context.go('/rt/keuangan');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.campaign,
                  title: 'Kegiatan & Broadcast (Lihat Saja)',
                  subtitle: 'Lihat kegiatan dan broadcast',
                  onTap: () {
                    context.go('/rt/kegiatan');
                  },
                  isViewOnly: true,
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.message,
                  title: 'Pesan Warga',
                  subtitle: 'Kelola pesan dari warga',
                  onTap: () {
                    context.pushNamed('rt_pesanWarga');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.history,
                  title: 'Log Aktifitas',
                  subtitle: 'Lihat riwayat aktifitas',
                  onTap: () {
                    context.pushNamed('rt_logAktivitas');
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isViewOnly = false,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: MoonTokens.light.typography.body.text14.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: MoonTokens.light.typography.body.text12.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isViewOnly)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'View Only',
                    style: MoonTokens.light.typography.body.text10.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
