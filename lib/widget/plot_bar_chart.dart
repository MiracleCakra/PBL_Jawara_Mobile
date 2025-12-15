import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:SapaWarga_kel_2/widget/custom_card.dart';
import 'package:moon_design/moon_design.dart';

class PlotBarChart extends StatelessWidget {
  final String title;
  final List<BarChartGroupData> barGroups;
  final Widget Function(double value, TitleMeta meta) getTitlesWidget;
  final Widget? titleTrailing;
  final bool wrapCard;

  const PlotBarChart({
    super.key,
    required this.title,
    required this.barGroups,
    required this.getTitlesWidget,
    this.titleTrailing,
    this.wrapCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final widget = SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.grey.shade800,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTitlesWidget,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}K',
                    style: TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
        duration: Duration(milliseconds: 150),
        curve: Curves.linear,
      ),
    );

    return wrapCard
        ? CustomCard(
            title: title,
            titleTrailing: titleTrailing,
            children: [widget],
          )
        : widget;
  }
}
