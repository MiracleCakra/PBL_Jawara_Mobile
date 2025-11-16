import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:jawara_pintar_kel_5/constants/iconify.dart';
import 'package:jawara_pintar_kel_5/models/pie_card_model.dart';
import 'package:jawara_pintar_kel_5/providers/admin_dashboard_provider.dart';
import 'package:jawara_pintar_kel_5/widget/dashboard_count_card.dart';
import 'package:jawara_pintar_kel_5/widget/plot_bar_chart.dart';
import 'package:jawara_pintar_kel_5/widget/plot_pie_card.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';

class Keuangan extends StatefulWidget {
  const Keuangan({super.key});

  @override
  State<Keuangan> createState() => _KeuanganState();
}

class _KeuanganState extends State<Keuangan> {
  late final AdminDashboardProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<AdminDashboardProvider>(context, listen: false);
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
                style: MoonTokens.light.typography.heading.text14.copyWith(
                  color: ConstantColors.foreground2,
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                children: List.generate(10, (index) {
                  final year = DateTime.now().year - index;
                  return MoonMenuItem(
                    onTap: () {
                      _provider.year = year;
                      Navigator.pop(context);
                    },
                    label: Text('$year'),
                    trailing: year == _provider.year
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          spacing: 12,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jumlah Transaksi',
                      style: MoonTokens.light.typography.heading.text20
                          .copyWith(color: ConstantColors.foreground2),
                    ),
                    Text(
                      '1',
                      style: MoonTokens.light.typography.heading.text20,
                    ),
                  ],
                ),
                SizedBox(
                  width: 100,
                  child: MoonDropdown(
                    show: false,
                    content: const SizedBox.shrink(),
                    child: MoonTextInput(
                      textInputSize: MoonTextInputSize.md,
                      readOnly: true,
                      hintText: _provider.year.toString(),
                      onTap: () => bottomSheetBuilder(context),
                      trailing: Icon(
                        MoonIcons.controls_vertical_double_chevron_32_light,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                final spacing = 6.0;
                final width = constraints.maxWidth / 2 - spacing;
                return Row(
                  spacing: spacing,
                  children: [
                    DashboardCountCard(
                      width: width,
                      title: 'Pemasukan',
                      count: '10K',
                      icon: Iconify(
                        IconifyConstants.fluentArrowDown,
                        color: MoonTokens.light.colors.roshi,
                        size: 12,
                      ),
                    ),
                    DashboardCountCard(
                      width: width,
                      title: 'Pengeluaran',
                      count: '10K',
                      icon: Iconify(
                        IconifyConstants.fluentArrowUp,
                        color: MoonTokens.light.colors.dodoria,
                        size: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
            chartKategori(),
            chartPerBulan(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Column chartPerBulan(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text('Per Bulan', style: MoonTokens.light.typography.heading.text16),

        PlotBarChart(
          title: '📈 Pemasukan',
          titleTrailing: Text(
            '${_provider.year}',
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
                style: TextStyle(fontSize: 10),
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
        ),

        PlotBarChart(
          title: '📉 Pengeluaran',
          titleTrailing: Text(
            '${_provider.year}',
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
                style: TextStyle(fontSize: 10),
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
                  color: MoonTokens.light.colors.dodoria,
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Column chartKategori() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text('Kategori', style: MoonTokens.light.typography.heading.text16),
        PlotPieCard(
          title: '📈 Pemasukan',
          titleTrailing: Text(
            '${_provider.year}',
            style: MoonTokens.light.typography.body.text14,
          ),
          data: [
            PieCardModel(
              label: 'Dana Bantuan Pemerintah',
              data: PieChartSectionData(
                value: 15,
                color: MoonTokens.light.colors.roshi,
                radius: 40,
                title: '15%',
                titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            PieCardModel(
              label: 'Dana Bantuan Gaben',
              data: PieChartSectionData(
                value: 30,
                color: MoonTokens.light.colors.dodoria,
                radius: 40,
                title: '30%',
                titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            PieCardModel(
              label: 'Dana Orang Baik',
              data: PieChartSectionData(
                value: 55,
                color: MoonTokens.light.colors.chichi,
                radius: 40,
                title: '55%',
                titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        PlotPieCard(
          title: '📉 Pengeluaran',
          titleTrailing: Text(
            '${_provider.year}',
            style: MoonTokens.light.typography.body.text14,
          ),
          data: [
            PieCardModel(
              label: 'Dana Bantuan Pemerintah',
              data: PieChartSectionData(
                value: 15,
                color: MoonTokens.light.colors.roshi,
                radius: 40,
                title: '15%',
                titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            PieCardModel(
              label: 'Operasional RT/RW',
              data: PieChartSectionData(
                value: 30,
                color: MoonTokens.light.colors.dodoria,
                radius: 40,
                title: '30%',
                titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
            PieCardModel(
              label: 'Ormas',
              data: PieChartSectionData(
                value: 55,
                color: MoonTokens.light.colors.chichi,
                radius: 40,
                title: '55%',
                titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
