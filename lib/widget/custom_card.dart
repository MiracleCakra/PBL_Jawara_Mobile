import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:moon_design/moon_design.dart';

class CustomCard extends StatelessWidget {
  final Color? color;
  final List<Widget> children;
  final String? title;
  final Widget? titleTrailing;
  final double spacing;

  const CustomCard({
    super.key,
    this.title,
    this.titleTrailing,
    this.color,
    required this.children,
    this.spacing = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: color ?? MoonTokens.light.colors.goten,
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
      child: Column(
        spacing: spacing,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || titleTrailing != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null)
                  Flexible(
                    child: Text(
                      title!,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: MoonTokens.light.typography.heading.text16
                          .copyWith(color: ConstantColors.foreground2),
                    ),
                  ),
                titleTrailing ?? const SizedBox.shrink(),
              ],
            ),
          if (title != null || titleTrailing != null)
            const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
