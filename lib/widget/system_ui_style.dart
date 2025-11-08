import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUiStyle extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? systemNavigationBarColor;
  final Brightness? overlayIconBrightness;

  const SystemUiStyle({
    super.key,
    required this.child,
    this.backgroundColor,
    this.overlayIconBrightness,
    this.systemNavigationBarColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
    final brightness =
        overlayIconBrightness ??
        (Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: bgColor,
        systemNavigationBarColor: systemNavigationBarColor ?? bgColor,
        statusBarIconBrightness: brightness,
        systemNavigationBarIconBrightness: brightness,
      ),
      child: child,
    );
  }
}
