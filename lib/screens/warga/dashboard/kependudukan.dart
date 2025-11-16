import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/pie_card_model.dart';
import 'package:jawara_pintar_kel_5/widget/custom_card.dart';
import 'package:jawara_pintar_kel_5/widget/plot_pie_card.dart';
import 'package:moon_design/moon_design.dart';

class Kependudukan extends StatelessWidget {
  const Kependudukan({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                totalX(title: '🏠 Keluarga', value: '1'),
                totalX(title: '👥 Penduduk', value: '1'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Statistik',
              style: MoonTokens.light.typography.heading.text16,
            ),

            PlotPieCard(
              title: '🙏 Agama',
              data: [
                PieCardModel(
                  label: 'Islam',
                  data: PieChartSectionData(
                    value: 100,
                    color: MoonTokens.light.colors.roshi,
                    radius: 40,
                    title: '100%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            PlotPieCard(
              title: '⚤ Jenis Kelamin',
              data: [
                PieCardModel(
                  label: 'Laki-Laki',
                  data: PieChartSectionData(
                    value: 50,
                    color: MoonTokens.light.colors.piccolo,
                    radius: 40,
                    title: '50%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                PieCardModel(
                  label: 'Perempuan',
                  data: PieChartSectionData(
                    value: 50,
                    color: MoonTokens.light.colors.hit,
                    radius: 40,
                    title: '50%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            PlotPieCard(
              title: '🔘 Status Penduduk',
              data: [
                PieCardModel(
                  label: 'Nonaktif',
                  data: PieChartSectionData(
                    value: 50,
                    color: MoonTokens.light.colors.chichi,
                    radius: 40,
                    title: '50%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                PieCardModel(
                  label: 'Aktif',
                  data: PieChartSectionData(
                    value: 50,
                    color: MoonTokens.light.colors.hit,
                    radius: 40,
                    title: '50%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            PlotPieCard(
              title: '👨🏻‍🎓 Pendidikan',
              data: [
                PieCardModel(
                  label: 'Sarjana/Diploma',
                  data: PieChartSectionData(
                    value: 100,
                    color: MoonTokens.light.colors.hit,
                    radius: 40,
                    title: '100%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            PlotPieCard(
              title: '💼 Pekerjaan Penduduk',
              data: [
                PieCardModel(
                  label: 'Lainnya',
                  data: PieChartSectionData(
                    value: 50,
                    color: MoonTokens.light.colors.chichi,
                    radius: 40,
                    title: '50%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                PieCardModel(
                  label: 'Pelajar',
                  data: PieChartSectionData(
                    value: 50,
                    color: MoonTokens.light.colors.hit,
                    radius: 40,
                    title: '50%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            PlotPieCard(
              title: '👪 Peran dalam Keluarga',
              data: [
                PieCardModel(
                  label: 'Kepala Keluarga',
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
                  label: 'Anak',
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
                PieCardModel(
                  label: 'Anggota Lain',
                  data: PieChartSectionData(
                    value: 55,
                    color: MoonTokens.light.colors.chichi,
                    radius: 40,
                    title: '55%',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Expanded totalX({required String title, required String value}) {
    return Expanded(
      child: CustomCard(
        title: title,
        children: [
          Text(value, style: MoonTokens.light.typography.heading.text20),
          Text('Total', style: MoonTokens.light.typography.body.text14),
        ],
      ),
    );
  }
}
