import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SapaWarga_kel_2/constants/constant_colors.dart';
import 'package:SapaWarga_kel_2/models/pie_card_model.dart';
import 'package:SapaWarga_kel_2/widget/plot_pie_card.dart';

class DashboardPendudukPage extends StatefulWidget {
  const DashboardPendudukPage({super.key});

  @override
  State<DashboardPendudukPage> createState() => _DashboardPendudukPageState();
}

class _DashboardPendudukPageState extends State<DashboardPendudukPage> {
  double _opacity = 0;
  int _selectedSegment = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  List<PieCardModel> get pendidikan {
    return [
      PieCardModel(
        label: "SD",
        data: PieChartSectionData(
          value: 25,
          color: ConstantColors.primary,
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "SMP",
        data: PieChartSectionData(
          value: 20,
          color: ConstantColors.primary.withOpacity(0.85),
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "SMA/SMK",
        data: PieChartSectionData(
          value: 30,
          color: ConstantColors.primary.withOpacity(0.70),
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "Diploma",
        data: PieChartSectionData(
          value: 10,
          color: ConstantColors.primary.withOpacity(0.55),
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "S1",
        data: PieChartSectionData(
          value: 8,
          color: ConstantColors.primary.withOpacity(0.40),
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "S2",
        data: PieChartSectionData(
          value: 5,
          color: ConstantColors.primary.withOpacity(0.32),
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "S3",
        data: PieChartSectionData(
          value: 2,
          color: ConstantColors.primary.withOpacity(0.22),
          radius: 32,
        ),
      ),
    ];
  }

  List<PieCardModel> get pekerjaan {
    return [
      PieCardModel(
        label: "Pelajar/Mahasiswa",
        data: PieChartSectionData(
          value: 30,
          color: ConstantColors.primary,
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "Karyawan",
        data: PieChartSectionData(
          value: 35,
          color: ConstantColors.primary.withOpacity(0.85),
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "Wiraswasta",
        data: PieChartSectionData(
          value: 20,
          color: ConstantColors.primary.withOpacity(0.70),
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "Ibu Rumah Tangga",
        data: PieChartSectionData(
          value: 10,
          color: ConstantColors.primary.withOpacity(0.55),
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "Tidak Bekerja",
        data: PieChartSectionData(
          value: 5,
          color: ConstantColors.primary.withOpacity(0.40),
          radius: 32,
        ),
      ),
    ];
  }

  List<PieCardModel> get peranKeluarga {
    return [
      PieCardModel(
        label: "Kepala Keluarga",
        data: PieChartSectionData(
          value: 20,
          color: ConstantColors.primary,
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "Istri",
        data: PieChartSectionData(
          value: 20,
          color: ConstantColors.primary.withOpacity(0.75),
          radius: 32,
        ),
      ),
      PieCardModel(
        label: "Anak",
        data: PieChartSectionData(
          value: 60,
          color: ConstantColors.primary.withOpacity(0.5),
          radius: 32,
        ),
      ),
    ];
  }

  Widget totalX({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color valueColor,
    required Color titleColor,
    required Color iconColor,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: isSmall ? 16 : 18),
                    SizedBox(width: isSmall ? 4 : 6),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmall ? 14 : 16,
                          color: titleColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
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
          mainAxisSize: MainAxisSize.min,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 12.0 : 16.0;

    final quickAccessButtons = [
      quickButton(
        icon: Icons.people,
        label: "Daftar Warga",
        onTap: () => context.pushNamed('wargaList'),
      ),
      quickButton(
        icon: Icons.home,
        label: "Daftar Rumah",
        onTap: () => context.pushNamed('rumahList'),
      ),
      quickButton(
        icon: Icons.family_restroom,
        label: "Daftar Keluarga",
        onTap: () => context.pushNamed('keluargaList'),
      ),
      quickButton(
        icon: Icons.sync_alt,
        label: "Mutasi Keluarga",
        onTap: () => context.pushNamed('mutasiKeluargaList'),
      ),
      quickButton(
        icon: Icons.mail,
        label: "Penerimaan Warga",
        onTap: () => context.pushNamed('penerimaanList'),
      ),
    ];

    final row1 = quickAccessButtons.sublist(0, 2);
    final row2 = quickAccessButtons.sublist(2, 4);
    final row3 = [quickAccessButtons[4]];

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
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  30,
                  horizontalPadding,
                  70,
                ),
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Dashboard Penduduk",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Ringkasan data kependudukan terkini",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          totalX(
                            title: "Total Keluarga",
                            value: "1",
                            icon: Icons.group_work_rounded,
                            color: Colors.white,
                            valueColor: ConstantColors.primary,
                            titleColor: ConstantColors.foreground2,
                            iconColor: ConstantColors.primary,
                          ),
                          const SizedBox(width: 12),
                          totalX(
                            title: "Total Penduduk",
                            value: "1",
                            icon: Icons.people_alt_rounded,
                            color: Colors.white,
                            valueColor: ConstantColors.primary,
                            titleColor: ConstantColors.foreground2,
                            iconColor: ConstantColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "Menu",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: row1[0]),
                          const SizedBox(width: 12),
                          Expanded(child: row1[1]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: row2[0]),
                          const SizedBox(width: 12),
                          Expanded(child: row2[1]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: row3[0]),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        "Statistik Kependudukan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildSegmentButton(
                                        'Pendidikan',
                                        0,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: _buildSegmentButton(
                                        'Pekerjaan',
                                        1,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: _buildSegmentButton(
                                        'Peran Keluarga',
                                        2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: SizedBox(
                                key: ValueKey<int>(_selectedSegment),
                                height: 420,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: _selectedSegment == 0
                                      ? PlotPieCard(
                                          title: "Pendidikan",
                                          data: pendidikan,
                                        )
                                      : _selectedSegment == 1
                                      ? PlotPieCard(
                                          title: "Pekerjaan",
                                          data: pekerjaan,
                                        )
                                      : PlotPieCard(
                                          title: "Peran Dalam Keluarga",
                                          data: peranKeluarga,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
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
