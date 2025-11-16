import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/pie_card_model.dart';
import 'package:jawara_pintar_kel_5/widget/custom_card.dart';
import 'package:jawara_pintar_kel_5/widget/plot_pie_card.dart';
import 'package:moon_design/moon_design.dart';

// Enum untuk periode laporan (masih bisa dipakai jika nanti perlu)
enum ReportPeriod { monthly, yearly }

class Marketplace extends StatefulWidget {
  const Marketplace({super.key});

  @override
  State<Marketplace> createState() => _MarketplaceState();
}

class _MarketplaceState extends State<Marketplace> {
  // jika nanti butuh toggle bulanan/tahunan, kamu bisa pakai ini
  ReportPeriod _selectedPeriodType = ReportPeriod.monthly;

  // Pilihan tahun dan bulan (UI opsi A)
  List<String> years = ['2023', '2024', '2025', '2026', '2027', '2028'];
  List<String> months = [
    'Semua Bulan',
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

  String selectedYear = '2025';
  String selectedMonth = 'November';

  // Data dummy untuk contoh
  final int totalProdukAktif = 125;
  final int totalVolumeBulanIni = 7500000;
  final int pesananBaru = 3;
  final int menungguKlasifikasi = 5;
  final int totalActiveAlerts = 4;
  final List<String> produkTopML = const ['Sayur', 'Sembako A', 'Batik'];
  final List<String> penjualTop = const ['Toko Sayursegar', 'Kios sayur'];
  final List<PieCardModel> kategoriData = [
    PieCardModel(
      label: 'Makanan & Minuman',
      data: PieChartSectionData(
        value: 40,
        color: Color(0xFF38BDF8),
        radius: 40,
        title: '40%',
        titleStyle: TextStyle(fontSize: 12, color: Colors.white),
      ),
    ),
    PieCardModel(
      label: 'Kerajinan Tangan',
      data: PieChartSectionData(
        value: 25,
        color: Color(0xFF60A5FA),
        radius: 40,
        title: '25%',
        titleStyle: TextStyle(fontSize: 12, color: Colors.white),
      ),
    ),
    PieCardModel(
      label: 'Sayuran',
      data: PieChartSectionData(
        value: 35,
        color: Color(0xFF4E46B4),
        radius: 40,
        title: '35%',
        titleStyle: TextStyle(fontSize: 12, color: Colors.white),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // tidak perlu generate list periode di opsi A
  }

  // 🔹 Format Rupiah
  String _formatRupiah(num amount) {
    String result = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $result';
  }

  // 🔹 KPI Card Widget
  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: MoonTokens.light.typography.heading.text16
                          .copyWith(fontWeight: FontWeight.bold, color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Fungsi export (menggunakan selectedYear / selectedMonth)
  void _exportReport(BuildContext context) {
    String detail;
    String typeLabel;
    if (selectedMonth == 'Semua Bulan') {
      typeLabel = 'Tahunan';
      detail = selectedYear;
    } else {
      typeLabel = 'Bulanan';
      detail = '$selectedMonth $selectedYear';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '📦 Membuat laporan Marketplace $typeLabel ($detail)...',
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // TODO: tambahkan logika export PDF / API di sini, berdasarkan selectedMonth & selectedYear
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
              spacing: 10,
              children: years.map((year) {
                return MoonMenuItem(
                  onTap: () {
                    setState(() {
                      selectedYear = year;
                      selectedMonth = 'Semua Bulan'; // Reset bulan saat ganti tahun
                    });
                    Navigator.pop(context);
                  },
                  label: Text(year),
                  trailing: year == selectedYear
                      ? const Icon(
                          Icons.check,
                        )
                      : null,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}

  Future<void> _showMonthSelection(BuildContext context) {
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
              'Pilih Bulan ($selectedYear)',
              style: MoonTokens.light.typography.heading.text14,
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              children: months.map((month) {
                return MoonMenuItem(
                  onTap: () {
                    setState(() {
                      selectedMonth = month;
                    });
                    Navigator.pop(context);
                  },
                  label: Text(month),
                  trailing: month == selectedMonth
                      ? const Icon(
                          Icons.check,
                        )
                      : null,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    // teks informasi periode yang dinamis
    String currentDataPeriod = selectedMonth == 'Semua Bulan'
        ? 'Data Tahun $selectedYear'
        : 'Data Bulan $selectedMonth $selectedYear';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ======= HEADER =======
         Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Marketplace',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currentDataPeriod,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

             Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 85,
                  child: MoonTextInput(
                    textInputSize: MoonTextInputSize.md,
                    readOnly: true,
                    hintText: selectedYear,
                    onTap: () => _showYearSelection(context),
                    trailing: const Icon(
                      Icons.unfold_more_rounded,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                SizedBox(
                  width: 100,
                  child: MoonTextInput(
                    textInputSize: MoonTextInputSize.md,
                    readOnly: true,
                    hintText: selectedMonth,
                    onTap: () => _showMonthSelection(context),
                    trailing: const Icon(
                      Icons.unfold_more_rounded,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                  // Notifikasi kecil
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                      if (totalActiveAlerts > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Text(
                              totalActiveAlerts > 9
                                  ? '9+'
                                  : totalActiveAlerts.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),



          const SizedBox(height: 12),

          // KPI
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.0,
            children: [
              _buildKpiCard(
                title: 'Total Produk',
                value: totalProdukAktif.toString(),
                icon: Icons.inventory_2_rounded,
                color: Colors.blue.shade600,
              ),
              _buildKpiCard(
                title: 'Total Transaksi',
                value: _formatRupiah(totalVolumeBulanIni),
                icon: Icons.paid_rounded,
                color: Colors.green.shade600,
              ),
              _buildKpiCard(
                title: 'Pesanan',
                value: pesananBaru.toString(),
                icon: Icons.notifications_active_rounded,
                color: Colors.red.shade600,
                onTap: () => context.pushNamed('marketplaceOrderMonitor'),
              ),
              _buildKpiCard(
                title: 'Menunggu Klasifikasi CV',
                value: menungguKlasifikasi.toString(),
                icon: Icons.camera_alt_rounded,
                color: Colors.orange.shade600,
                onTap: () => context.pushNamed('marketplaceProdukList'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          PlotPieCard(
            title: '📊 Distribusi Kategori Produk (Hasil CV)',
            data: kategoriData,
          ),

          const SizedBox(height: 16),

          CustomCard(
            title: '✨ Produk Paling Direkomendasikan (ML)',
            children: produkTopML
                .asMap()
                .entries
                .map(
                  (e) => MoonMenuItem(
                    label: Text(e.value),
                    trailing: Text('Rank #${e.key + 1}'),
                    backgroundColor: Colors.transparent,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 16),

          CustomCard(
            title: '🏅 Penjual Top Bulan Ini',
            children: penjualTop
                .map((e) => MoonMenuItem(
                      label: Text(e),
                      trailing: const Text('Penjualan Tinggi'),
                      backgroundColor: Colors.transparent,
                    ))
                .toList(),
          ),

          const SizedBox(height: 16),

          // Export
          CustomCard(
            title: 'Akses Laporan & Export',
            children: [
              MoonFilledButton(
                onTap: () => _exportReport(context),
                leading: const Icon(Icons.picture_as_pdf_rounded),
                backgroundColor: Colors.indigo.shade600,
                label: Text(selectedMonth == 'Semua Bulan'
                    ? 'Export Laporan Tahun $selectedYear'
                    : 'Export Laporan $selectedMonth $selectedYear'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
