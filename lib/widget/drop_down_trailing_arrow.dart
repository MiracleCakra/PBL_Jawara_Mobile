import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class DropDownTrailingArrow extends StatelessWidget {
  final bool isShow;
  const DropDownTrailingArrow({super.key, required this.isShow});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 150),
        turns: isShow ? -0.5 : 0,
        child: const Icon(MoonIcons.controls_chevron_down_small_16_light),
      ),
    );
  }
}
