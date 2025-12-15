import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SapaWarga_kel_2/constants/constant_colors.dart';
import 'package:SapaWarga_kel_2/models/pie_card_model.dart';
import 'package:SapaWarga_kel_2/services/kegiatan_service.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/kegiatan_model.dart';
import 'package:SapaWarga_kel_2/widget/plot_bar_chart.dart';
import 'package:SapaWarga_kel_2/widget/plot_pie_card.dart';

// Model menu item
class MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  MenuItem({required this.icon, required this.label, required this.onTap});
}

class KegiatanScreen extends StatefulWidget {
  const KegiatanScreen({super.key});

  @override
  State<KegiatanScreen> createState() => _KegiatanScreenState();
}

class _KegiatanScreenState extends State<KegiatanScreen> {
  late final KegiatanService _kegiatanService;
  late Stream<List<KegiatanModel>> _kegiatanStream;
  double _opacity = 0;
  int _selectedSegment = 0; // 0: Per Kategori, 1: Per Bulan

  @override
  void initState() {
    super.initState();
    _kegiatanService = KegiatanService();
    _kegiatanStream = _kegiatanService.getKegiatanStream();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _kegiatanStream = _kegiatanService.getKegiatanStream();
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  Widget _buildSegmentButton(String label, int index) {
    final isSelected = _selectedSegment == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected ? ConstantColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => setState(() => _selectedSegment = index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKategoriChart(List<KegiatanModel> data) {
    if (data.isEmpty) {
      return const Center(child: Text("Belum ada data kegiatan"));
    }

    final Map<String, int> counts = {};
    for (var k in data) {
      counts[k.kategori] = (counts[k.kategori] ?? 0) + 1;
    }

    int total = data.length;
    
    // Define specific colors for known categories, fallback for others
    final Map<String, Color> categoryColors = {
      'Komunitas & Sosial': Colors.blue,
      'Kebersihan dan Keamanan': Colors.green,
      'Keagamaan': Colors.orange,
      'Pendidikan': Colors.purple,
      'Kesehatan & Olahraga': Colors.red,
      'Lainnya': Colors.grey,
    };
    
    // Generate PieCardModel list
    List<PieCardModel> sections = [];
    int index = 0;
    counts.forEach((key, value) {
      final percentage = (value / total) * 100;
      final color = categoryColors[key] ?? ConstantColors.primary.withOpacity(0.5 + (index * 0.1) % 0.5);
      
      sections.add(
        PieCardModel(
          label: '$key (${percentage.toStringAsFixed(1)}%)',
          data: PieChartSectionData(
            value: value.toDouble(),
            color: color,
            radius: 40,
            showTitle: false,
          ),
        ),
      );
      index++;
    });

    return PlotPieCard(
      title: 'Distribusi Kategori Kegiatan',
      data: sections,
    );
  }

  Widget _buildBulanChart(List<KegiatanModel> data) {
    if (data.isEmpty) {
      return const Center(child: Text("Belum ada data kegiatan"));
    }

    final int currentYear = DateTime.now().year;
    
    // Initialize counts for 12 months (0-11)
    final List<int> monthlyCounts = List.filled(12, 0);

    for (var k in data) {
      if (k.tanggal.year == currentYear) {
        // Month is 1-based, convert to 0-based index
        monthlyCounts[k.tanggal.month - 1]++;
      }
    }

    return PlotBarChart(
      title: '📅 Grafik Kegiatan Bulanan',
      titleTrailing: Text(
        '$currentYear',
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      getTitlesWidget: (value, meta) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
        ];
        if (value.toInt() >= 0 && value.toInt() < months.length) {
          return Text(
            months[value.toInt()],
            style: const TextStyle(fontSize: 10),
          );
        }
        return const Text('');
      },
      barGroups: List.generate(12, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: monthlyCounts[index].toDouble(),
              color: ConstantColors.primary,
              width: 8,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                 show: true,
                 toY: monthlyCounts.reduce((curr, next) => curr > next ? curr : next).toDouble() + 2, // Dynamic max height
                 color: Colors.grey.withOpacity(0.1), 
              )
            ),
          ],
        );
      }),
    );
  }

  Widget quickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Key? key,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ConstantColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: ConstantColors.primary, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget totalCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color color,
    required Color valueColor,
    required Color titleColor,
  }) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 100;
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 8 : 10,
              vertical: isSmall ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isSmall ? 18 : 20,
                      fontWeight: FontWeight.w900,
                      color: valueColor,
                    ),
                  ),
                ),
                SizedBox(height: isSmall ? 4 : 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmall ? 10 : 11,
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<MenuItem> get menuItems => [
    MenuItem(
      icon: Icons.list_alt,
      label: 'Daftar Kegiatan',
      onTap: () async {
        await context.push('/admin/kegiatan/daftar');
        _handleRefresh();
      },
    ),
    MenuItem(
      icon: Icons.campaign_outlined,
      label: 'Daftar Broadcast',
      onTap: () async {
        await context.push('/admin/kegiatan/broadcast/daftar');
        _handleRefresh();
      },
    ),
    MenuItem(
      icon: Icons.message_outlined,
      label: 'Pesan Warga',
      onTap: () => context.push('/admin/kegiatan/pesanwarga'),
    ),
    MenuItem(
      icon: Icons.history,
      label: 'Log Aktivitas',
      onTap: () => context.push('/admin/kegiatan/logaktivitas'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final allMenuItems = menuItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: ConstantColors.primary,
        child: StreamBuilder<List<KegiatanModel>>(
          stream: _kegiatanStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              debugPrint("❌ Stream Error: ${snapshot.error}");
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Terjadi kesalahan memuat data.\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            }

            final List<KegiatanModel> dataKegiatan = snapshot.data ?? [];

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            int total = dataKegiatan.length;
            int sudahLewat = 0;
            int hariIni = 0;
            int akanDatang = 0;

            for (var k in dataKegiatan) {
              final kDate = DateTime(
                k.tanggal.year,
                k.tanggal.month,
                k.tanggal.day,
              );
              if (kDate.isBefore(today)) {
                sudahLewat++;
              } else if (kDate.isAtSameMomentAs(today)) {
                hariIni++;
              } else {
                akanDatang++;
              }
            }

            return AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 80),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dashboard Kegiatan",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Ringkasan kegiatan dan aktivitas warga",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Transform.translate(
                      offset: const Offset(0, -60),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Statistik
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.event_note,
                                        color: ConstantColors.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Kegiatan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Text(
                                        'Total:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                            255,
                                            62,
                                            62,
                                            63,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$total',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: ConstantColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      totalCard(
                                        title: 'Sudah Lewat',
                                        value: '$sudahLewat',
                                        icon: Icons.history,
                                        iconColor: const Color(0xFF9CA3AF),
                                        color: Colors.white,
                                        valueColor: ConstantColors.primary,
                                        titleColor: const Color(0xFF1F2937),
                                      ),
                                      const SizedBox(width: 10),
                                      totalCard(
                                        title: 'Hari Ini',
                                        value: '$hariIni',
                                        icon: Icons.today,
                                        iconColor: const Color(0xFF3B82F6),
                                        color: Colors.white,
                                        valueColor: ConstantColors.primary,
                                        titleColor: const Color(0xFF1F2937),
                                      ),
                                      const SizedBox(width: 10),
                                      totalCard(
                                        title: 'Akan Datang',
                                        value: '$akanDatang',
                                        icon: Icons.upcoming,
                                        iconColor: const Color(0xFF10B981),
                                        color: Colors.white,
                                        valueColor: ConstantColors.primary,
                                        titleColor: const Color(0xFF1F2937),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Menu
                            const Text(
                              'Menu',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: quickButton(
                                    key: const Key('daftar_kegiatan_button'),
                                    icon: allMenuItems[0].icon,
                                    label: allMenuItems[0].label,
                                    onTap: allMenuItems[0].onTap,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: quickButton(
                                    key: const Key('daftar_broadcast_button'),
                                    icon: allMenuItems[1].icon,
                                    label: allMenuItems[1].label,
                                    onTap: allMenuItems[1].onTap,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: quickButton(
                                    icon: allMenuItems[2].icon,
                                    label: allMenuItems[2].label,
                                    onTap: allMenuItems[2].onTap,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: quickButton(
                                    icon: allMenuItems[3].icon,
                                    label: allMenuItems[3].label,
                                    onTap: allMenuItems[3].onTap,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 36),

                            // Chart
                            const Text(
                              'Statistik Kegiatan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildSegmentButton(
                                      'Per Kategori',
                                      0,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: _buildSegmentButton('Per Bulan', 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: _selectedSegment == 0
                                  ? _buildKategoriChart(dataKegiatan)
                                  : _buildBulanChart(dataKegiatan),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
