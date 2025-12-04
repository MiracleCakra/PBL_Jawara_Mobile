import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:jawara_pintar_kel_5/widget/plot_bar_chart.dart';
import 'package:moon_design/moon_design.dart';

// Class untuk model menu item
class MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  MenuItem({required this.icon, required this.label, required this.onTap});
}

class Keuangan extends StatefulWidget {
  const Keuangan({super.key});

  @override
  State<Keuangan> createState() => _KeuanganState();
}

class _KeuanganState extends State<Keuangan> {
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;
  double _opacity = 0;
  int _selectedSegment = 0; // 0: Pemasukan, 1: Pengeluaran

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return monthNames[month - 1];
  }

  Widget _buildSegmentButton(String label, int index) {
    final isSelected = _selectedSegment == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isSelected ? ConstantColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedSegment = index;
            });
          },
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

  Widget totalX({
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
          final isSmall = constraints.maxWidth < 160;
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 8 : 10,
              vertical: isSmall ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: isSmall ? 16 : 18),
                    SizedBox(width: isSmall ? 4 : 6),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 16,
                            color: titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmall ? 6 : 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isSmall ? 20 : 24,
                      fontWeight: FontWeight.w900,
                      color: valueColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget quickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            const SizedBox(height: 8),
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

  Future<dynamic> bottomSheetBuilder(BuildContext context) {
    return showMoonModalBottomSheet(
      context: context,
      enableDrag: true,
      height: MediaQuery.of(context).size.height * 0.7,
      builder: (BuildContext context) => Column(
        children: [
          Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: ShapeDecoration(
                  color: context.moonColors!.beerus,
                  shape: MoonSquircleBorder(
                    borderRadius: BorderRadius.circular(
                      16,
                    ).squircleBorderRadius(context),
                  ),
                ),
              ),
              Text(
                'Pilih Tahun',
                style: MoonTokens.light.typography.heading.text14.copyWith(
                  color: ConstantColors.foreground2,
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(10, (index) {
                  final year = DateTime.now().year - index;
                  return MoonMenuItem(
                    onTap: () {
                      Navigator.pop(context);
                      // Setelah memilih tahun, buka modal bulan
                      _showMonthPicker(context, year);
                    },
                    label: Text('$year'),
                    trailing: year == _selectedYear
                        ? const Icon(
                            MoonIcons.generic_check_alternative_32_light,
                          )
                        : null,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _showMonthPicker(BuildContext context, int year) {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return showMoonModalBottomSheet(
      context: context,
      enableDrag: true,
      height: MediaQuery.of(context).size.height * 0.7,
      builder: (BuildContext context) => Column(
        children: [
          Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: ShapeDecoration(
                  color: context.moonColors!.beerus,
                  shape: MoonSquircleBorder(
                    borderRadius: BorderRadius.circular(
                      16,
                    ).squircleBorderRadius(context),
                  ),
                ),
              ),
              Text(
                'Pilih Bulan - $year',
                style: MoonTokens.light.typography.heading.text14.copyWith(
                  color: ConstantColors.foreground2,
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(12, (index) {
                  final monthIndex = index + 1;
                  return MoonMenuItem(
                    onTap: () {
                      setState(() {
                        _selectedYear = year;
                        _selectedMonth = monthIndex;
                      });
                      Navigator.pop(context);
                    },
                    label: Text(monthNames[index]),
                    trailing:
                        _selectedYear == year && _selectedMonth == monthIndex
                        ? const Icon(
                            MoonIcons.generic_check_alternative_32_light,
                          )
                        : null,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPemasukanChart() {
    return PlotBarChart(
      title: '📈 Pemasukan',
      titleTrailing: Text(
        '$_selectedYear',
        style: MoonTokens.light.typography.body.text14,
      ),
      getTitlesWidget: (value, meta) {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agt',
          'Sep',
          'Okt',
          'Nov',
          'Des',
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
        final pemasukanValues = [
          8.0,
          12.0,
          10.0,
          15.0,
          9.0,
          14.0,
          11.0,
          13.0,
          16.0,
          10.0,
          12.0,
          18.0,
        ];

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: pemasukanValues[index],
              color: MoonTokens.light.colors.roshi,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPengeluaranChart() {
    return PlotBarChart(
      title: '📉 Pengeluaran',
      titleTrailing: Text(
        '$_selectedYear',
        style: MoonTokens.light.typography.body.text14,
      ),
      getTitlesWidget: (value, meta) {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agt',
          'Sep',
          'Okt',
          'Nov',
          'Des',
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
        final pengeluaranValues = [
          6.0,
          10.0,
          9.0,
          12.0,
          7.0,
          11.0,
          9.0,
          10.0,
          14.0,
          8.0,
          10.0,
          15.0,
        ];

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: pengeluaranValues[index],
              color: MoonTokens.light.colors.dodoria,
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }),
    );
  }

  List<MenuItem> get menuItems {
    return [
      MenuItem(
        icon: Icons.category_outlined,
        label: 'Kategori Iuran',
        onTap: () => context.push('/admin/pemasukan/kategori-iuran'),
      ),
      MenuItem(
        icon: Icons.payments_outlined,
        label: 'Tagih Iuran',
        onTap: () => context.push('/admin/pemasukan/tagih-iuran'),
      ),
      MenuItem(
        icon: Icons.receipt_long_outlined,
        label: 'Tagihan',
        onTap: () => context.push('/admin/pemasukan/tagihan'),
      ),
      MenuItem(
        icon: Icons.trending_down_outlined,
        label: 'Laporan Pemasukan',
        onTap: () => context.push('/admin/laporan/semua-pemasukan'),
      ),
      MenuItem(
        icon: Icons.trending_up_outlined,
        label: 'Laporan Pengeluaran',
        onTap: () => context.push('/admin/laporan/semua-pengeluaran'),
      ),
      MenuItem(
        icon: Icons.print_outlined,
        label: 'Cetak Laporan',
        onTap: () => context.push('/admin/laporan/cetak-laporan'),
      ),
      MenuItem(
        icon: Icons.compare_arrows,
        label: 'Channel Transfer',
        onTap: () => context.push('/admin/lainnya/manajemen-channel'),
      ),
    ];
  }

  // --- Widget Utama Build ---
  @override
  Widget build(BuildContext context) {
    final allMenuItems = menuItems;
    final row1Items = allMenuItems.sublist(0, 2);
    final row2Items = allMenuItems.sublist(2, 4);
    final row3Items = allMenuItems.sublist(4, 6);
    final row4Items = [allMenuItems[6]];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                      "Dashboard Keuangan",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Ringkasan arus kas dan transaksi",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: totalX(
                              title: 'Pemasukan',
                              value: 'Rp 3.500.000',
                              icon: Icons.trending_up,
                              iconColor: ConstantColors.primary,
                              color: Colors.white,
                              valueColor: ConstantColors.primary,
                              titleColor: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: totalX(
                              title: 'Pengeluaran',
                              value: 'Rp 1.000.000',
                              icon: Icons.trending_down,
                              iconColor: Colors.red,
                              color: Colors.white,
                              valueColor: ConstantColors.primary,
                              titleColor: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),
                      // Menu Navigasi
                      const Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Baris 1 Menu
                      Row(
                        children: [
                          Expanded(
                            child: quickButton(
                              icon: row1Items[0].icon,
                              label: row1Items[0].label,
                              onTap: row1Items[0].onTap,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: quickButton(
                              icon: row1Items[1].icon,
                              label: row1Items[1].label,
                              onTap: row1Items[1].onTap,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Baris 2 Menu
                      Row(
                        children: [
                          Expanded(
                            child: quickButton(
                              icon: row2Items[0].icon,
                              label: row2Items[0].label,
                              onTap: row2Items[0].onTap,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: quickButton(
                              icon: row2Items[1].icon,
                              label: row2Items[1].label,
                              onTap: row2Items[1].onTap,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Baris 3 Menu
                      Row(
                        children: [
                          Expanded(
                            child: quickButton(
                              icon: row3Items[0].icon,
                              label: row3Items[0].label,
                              onTap: row3Items[0].onTap,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: quickButton(
                              icon: row3Items[1].icon,
                              label: row3Items[1].label,
                              onTap: row3Items[1].onTap,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Baris 4 Menu
                      Row(
                        children: [
                          Expanded(
                            child: quickButton(
                              icon: row4Items[0].icon,
                              label: row4Items[0].label,
                              onTap: row4Items[0].onTap,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(child: SizedBox()),
                        ],
                      ),

                      const SizedBox(height: 36),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Statistik Keuangan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                          // Dropdown Tahun dan Bulan
                          SizedBox(
                            width: 140,
                            child: MoonDropdown(
                              show: false,
                              content: const SizedBox.shrink(),
                              child: MoonTextInput(
                                textInputSize: MoonTextInputSize.md,
                                readOnly: true,
                                hintText: _selectedMonth != null
                                    ? '${_getMonthName(_selectedMonth!)} $_selectedYear'
                                    : _selectedYear.toString(),
                                onTap: () => bottomSheetBuilder(context),
                                trailing: Icon(
                                  MoonIcons
                                      .controls_vertical_double_chevron_32_light,
                                  color: ConstantColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Segment Control
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSegmentButton('Pemasukan', 0),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _buildSegmentButton('Pengeluaran', 1),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Chart dengan AnimatedSwitcher
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: _selectedSegment == 0
                            ? _buildPemasukanChart()
                            : _buildPengeluaranChart(),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
