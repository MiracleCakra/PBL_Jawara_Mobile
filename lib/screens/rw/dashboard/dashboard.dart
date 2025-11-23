import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moon_design/moon_design.dart';

class RWDashboard extends StatefulWidget {
  const RWDashboard({super.key});

  @override
  State<RWDashboard> createState() => _RWDashboardState();
}

class _RWDashboardState extends State<RWDashboard> {
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
                      "Dashboard RW",
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
                    context.go('/rw/penduduk');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: 'Pemasukan',
                  subtitle: 'Kelola data pemasukan',
                  onTap: () {
                    context.go('/rw/keuangan');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.money_off,
                  title: 'Pengeluaran',
                  subtitle: 'Kelola data pengeluaran',
                  onTap: () {
                    context.go('/rw/keuangan');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.assessment,
                  title: 'Laporan Keuangan',
                  subtitle: 'Lihat laporan keuangan',
                  onTap: () {
                    context.go('/rw/keuangan');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.campaign,
                  title: 'Kegiatan & Broadcast',
                  subtitle: 'Kelola kegiatan dan broadcast',
                  onTap: () {
                    context.go('/rw/kegiatan');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.message,
                  title: 'Pesan Warga',
                  subtitle: 'Kelola pesan dari warga',
                  onTap: () {
                    context.pushNamed('rw_pesanWarga');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuCard(
                  context,
                  icon: Icons.history,
                  title: 'Log Aktifitas',
                  subtitle: 'Lihat riwayat aktifitas',
                  onTap: () {
                    context.pushNamed('rw_logAktivitas');
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
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
