import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class DashboardCountCard extends StatelessWidget {
  final String title;
  final String count;
  final Widget icon;
  final double? width;
  final double? height;

  const DashboardCountCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: MoonSquircleBorder(
          borderRadius: BorderRadius.circular(8).squircleBorderRadius(context),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              Text(title, style: MoonTokens.light.typography.heading.text12),
            ],
          ),
          Text(count, style: MoonTokens.light.typography.heading.text14),
        ],
      ),
    );
  }
}
