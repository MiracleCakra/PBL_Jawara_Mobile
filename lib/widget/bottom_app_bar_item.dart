import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class BottomAppBarItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final Widget? activeIcon;
  final double? width;
  final Color? activeColor;
  const BottomAppBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    this.width,
    this.onTap,
    this.activeIcon,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        spacing: 0,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: active ? activeIcon ?? icon : icon,
            onPressed: onTap,
            color: active
                ? activeColor ?? Theme.of(context).colorScheme.primary
                : null,
          ),
          Text(
            label,
            style: MoonTokens.light.typography.heading.text12.copyWith(
              height: 0.1,
              color: active
                  ? activeColor ?? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
