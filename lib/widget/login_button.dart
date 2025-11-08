import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

class LoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool withColor;

  const LoginButton({
    super.key,
    required this.text,
    required this.onTap,
    this.withColor = true,
  });

  @override
  Widget build(BuildContext context) {
    final moonColors = MoonTokens.light.colors;
    return MoonFilledButton(
      isFullWidth: true,
      buttonSize: MoonButtonSize.lg,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: withColor ? moonColors.piccolo : moonColors.goku,
        border: Border(
          bottom: BorderSide(width: 4, color: MoonTokens.light.colors.bulma),
        ),
      ),
      onTap: onTap,
      label: Text(
        text,
        style: (MoonTokens.light.typography.heading.text16).copyWith(
          color: withColor ? null : moonColors.bulma,
        ),
      ),
    );
  }
}
