import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SapaWarga_kel_2/constants/constant_colors.dart';
import 'package:SapaWarga_kel_2/models/pie_card_model.dart';
import 'package:SapaWarga_kel_2/widget/plot_pie_card.dart';
import 'package:moon_design/moon_design.dart';

class MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  MenuItem({required this.icon, required this.label, required this.onTap});
}

class Marketplace extends StatefulWidget {
  const Marketplace({super.key});

  @override
  State<Marketplace> createState() => _MarketplaceState();
}

class _MarketplaceState extends State<Marketplace> {
  double _opacity = 0;
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;

  // Data Dummy
  final int totalProdukAktif = 125;
  final int menungguValidasi = 5;
  final List<String> produkTopML = const [
    'Wortel Grade A',
    'Tomat Grade B',
    'Tomat Grade C',
  ];
  final List<String> penjualTop = const ['Toko Sayursegar', 'Kios sayur'];

  final List<PieCardModel> kategoriData = [
    PieCardModel(
      label: 'Grade A',
      data: PieChartSectionData(
        value: 45,
        color: ConstantColors.primary,
        radius: 40,
        title: '45%',
        titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
      ),
    ),
    PieCardModel(
      label: 'Grade B',
      data: PieChartSectionData(
        value: 35,
        color: ConstantColors.primary.withOpacity(0.7),
        radius: 40,
        title: '35%',
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    ),
    PieCardModel(
      label: 'Grade C',
      data: PieChartSectionData(
        value: 20,
        color: ConstantColors.primary.withOpacity(0.4),
        radius: 40,
        title: '20%',
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  /*void _goToValidasiProduk() {
    context.pushNamed('validasiProduk');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigasi ke Halaman Validasi Produk')),
    );
  }

  void _goToValidasiAkunToko() {
    context.pushNamed('validasiAkunToko');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigasi ke Halaman Validasi Akun Toko')),
    );
  }

  String _formatRupiah(num amount) {
    String result = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $result';
  }*/

  // Card Total (totalX)
  Widget _buildTotalCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color color,
    required Color valueColor,
    required Color titleColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
      ),
    );
  }

  // Quick Button (Menu Cepat)
  Widget _buildQuickButton({
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

  Widget _buildListCard({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color iconColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 200;
        return Container(
          padding: EdgeInsets.all(isNarrow ? 10 : 14),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: isNarrow ? 18 : 20),
                  SizedBox(width: isNarrow ? 6 : 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: isNarrow ? 12 : 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF374151),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isNarrow ? 8 : 10),
              ...items.asMap().entries.map((entry) {
                int index = entry.key;
                String item = entry.value;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: isNarrow ? 2.0 : 3.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ConstantColors.primary,
                          fontSize: isNarrow ? 11 : 13,
                        ),
                      ),
                      SizedBox(width: isNarrow ? 4 : 6),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: isNarrow ? 11 : 13,
                            color: const Color(0xFF4B5563),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
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

  Future<void> _showYearSelection(BuildContext context) {
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
                margin: const EdgeInsets.symmetric(vertical: 8),
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
                style: MoonTokens.light.typography.heading.text14,
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
                      _showMonthSelection(context, year);
                    },
                    label: Text('$year'),
                    trailing: year == _selectedYear
                        ? const Icon(Icons.check, color: ConstantColors.primary)
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

  Future<void> _showMonthSelection(BuildContext context, int year) {
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
                margin: const EdgeInsets.symmetric(vertical: 8),
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
                style: MoonTokens.light.typography.heading.text14,
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
                        ? const Icon(Icons.check, color: ConstantColors.primary)
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

  Widget _buildFilterInput({
    required String label,
    required VoidCallback onTap,
  }) {
    return MoonDropdown(
      show: false,
      content: const SizedBox.shrink(),
      child: MoonTextInput(
        textInputSize: MoonTextInputSize.md,
        readOnly: true,
        hintText: label,
        onTap: onTap,
        trailing: Icon(
          MoonIcons.controls_vertical_double_chevron_32_light,
          color: ConstantColors.primary,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final quickAccessButtons = [
      _buildQuickButton(
        icon: Icons.checklist_rtl_rounded,
        label: "Validasi Produk",
        onTap: () => context.push('/admin/marketplace/validasiproduk'),
      ),
      _buildQuickButton(
        icon: Icons.storefront_rounded,
        label: "Validasi Akun Toko",
        onTap: () => context.push('/admin/marketplace/validasiakuntoko'),
      ),
    ];

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
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 80),
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
                      "Dashboard Marketplace",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Ringkasan performa dan manajemen marketplace (${_selectedMonth != null ? '${_getMonthName(_selectedMonth!)} $_selectedYear' : '$_selectedYear'})",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -50),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildTotalCard(
                            title: "Validasi Toko",
                            value: totalProdukAktif.toString(),
                            icon: Icons.inventory_2_rounded,
                            color: Colors.white,
                            valueColor: ConstantColors.primary,
                            titleColor: const Color(0xFF4B5563),
                            iconColor: ConstantColors.primary,
                          ),
                          const SizedBox(width: 16),
                          _buildTotalCard(
                            title: "Validasi Produk",
                            value: menungguValidasi.toString(),
                            icon: Icons.pending_actions_rounded,
                            color: Colors.white,
                            valueColor: ConstantColors.primary,
                            titleColor: const Color(0xFF4B5563),
                            iconColor: ConstantColors.primary,
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),
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
                          Expanded(child: quickAccessButtons[0]),
                          const SizedBox(width: 12),
                          Expanded(child: quickAccessButtons[1]),
                        ],
                      ),

                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: const Text(
                              "Performa",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: width > 400 ? 140 : 120,
                            child: _buildFilterInput(
                              onTap: () => _showYearSelection(context),
                              label: _selectedMonth != null
                                  ? '${_getMonthName(_selectedMonth!)} $_selectedYear'
                                  : '$_selectedYear',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: width > 600 ? 2 : 1,
                          childAspectRatio: width > 600
                              ? 1.5
                              : (width > 400 ? 2.8 : 2.2),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        children: [
                          _buildListCard(
                            title: "Sayur Terlaris",
                            items: produkTopML,
                            icon: Icons.local_florist_rounded,
                            iconColor: Colors.green,
                          ),

                          _buildListCard(
                            title: "Top Penjual",
                            items: penjualTop,
                            icon: Icons.group_rounded,
                            iconColor: Colors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      const Text(
                        "Statistik Distribusi Kategori Sayur (Hasil CV)",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 14),

                      PlotPieCard(
                        title: "Distribusi Kategori Produk",
                        data: kategoriData,
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
