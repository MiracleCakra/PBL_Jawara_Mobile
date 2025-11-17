import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/pie_card_model.dart';
import 'package:jawara_pintar_kel_5/widget/custom_card.dart';
import 'package:jawara_pintar_kel_5/widget/plot_bar_chart.dart';
import 'package:jawara_pintar_kel_5/widget/plot_pie_card.dart';
import 'package:moon_design/moon_design.dart';

class Kegiatan extends StatelessWidget {
  Kegiatan({super.key});

  final Map<String, int> kegiatan = {'late': 1, 'today': 0, 'incoming': 0};

  final List<String> penanggungJawab = ['Raruu', 'Azusa', 'Elaina'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          spacing: 8,
          children: [
            CustomCard(
              title: '🎉 Kegiatan',
              spacing: 4.0,
              children: [
                textAndValue(
                  text: 'Total',
                  value: kegiatan.values.reduce((a, b) => a + b).toString(),
                  textstyle: MoonTokens.light.typography.heading.text20,
                ),
                textAndValue(
                  text: 'Sudah lewat',
                  value: kegiatan['late'].toString(),
                ),
                textAndValue(
                  text: 'Hari ini',
                  value: kegiatan['today'].toString(),
                ),
                textAndValue(
                  text: 'Akan Datang',
                  value: kegiatan['incoming'].toString(),
                ),
              ],
            ),
            CustomCard(
              title: '👤 Penanggung Jawab Terbanyak',
              children: penanggungJawab
                  .asMap()
                  .entries
                  .map(
                    (e) => MoonMenuItem(
                      label: Text(e.value),
                      trailing: Text('#${e.key + 1}'),
                    ),
                  )
                  .toList(),
            ),
            PlotPieCard(
              title: '📂 Kegiatan per Kategori',
              data: [
                PieCardModel(
                  label: 'Komunitas & Sosial',
                  data: PieChartSectionData(
                    value: 15,
                    color: MoonTokens.light.colors.roshi,
                    radius: 40,
                    title: '15%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                PieCardModel(
                  label: 'Lainnya',
                  data: PieChartSectionData(
                    value: 30,
                    color: MoonTokens.light.colors.dodoria,
                    radius: 40,
                    title: '30%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            PlotBarChart(
              title: '📅 Kegiatan per Bulan',
              titleTrailing: Text(
                '${DateTime.now().year}',
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Row textAndValue({
    required String text,
    required String value,
    TextStyle? textstyle,
  }) {
    textstyle ??= MoonTokens.light.typography.body.text14;
    return Row(
      spacing: 4,
      children: [
        Text('$text:', style: textstyle.copyWith(fontWeight: FontWeight.w700)),
        Text(value, style: textstyle),
      ],
    );
  }
}
