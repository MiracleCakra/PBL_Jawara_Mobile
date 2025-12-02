import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:jawara_pintar_kel_5/models/pie_card_model.dart';
import 'package:jawara_pintar_kel_5/widget/custom_card.dart';
import 'package:moon_design/moon_design.dart';

class PlotPieCard extends StatelessWidget {
  const PlotPieCard({
    super.key,
    this.title,
    this.titleTrailing,
    required this.data,
    this.wrapCard = true,
  });

  final String? title;
  final Widget? titleTrailing;
  final List<PieCardModel> data;
  final bool wrapCard;

  Widget _buildLegendItem(Color color, String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: MoonTokens.light.typography.body.text14.copyWith(
                color: ConstantColors.foreground2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: MoonTokens.light.typography.body.text14.copyWith(
              color: ConstantColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total value
    final totalValue = data.fold<double>(
      0,
      (sum, item) => sum + item.data.value,
    );

    final widgets = [
      SizedBox(
        height: 180,
        child: PieChart(
          PieChartData(
            sections: data
                .map(
                  (e) => e.data.copyWith(
                    showTitle: false, // Hide numbers in pie chart
                  ),
                )
                .toList(),
            centerSpaceRadius: 18,
            sectionsSpace: 4,
          ),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        ),
      ),
      const SizedBox(height: 12),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.map((e) {
          final percentage = (e.data.value / totalValue) * 100;
          return _buildLegendItem(e.data.color, e.label, percentage);
        }).toList(),
      ),
    ];

    return wrapCard
        ? CustomCard(
            title: title,
            titleTrailing: titleTrailing,
            children: widgets,
          )
        : Column(children: widgets);
  }
}
