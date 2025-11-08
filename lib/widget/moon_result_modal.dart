import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';

enum ResultType { success, error }

Future<void> showResultModal(
  BuildContext context, {
  required ResultType type,
  String? title,
  String? description,
  String actionLabel = 'Selesai',
  VoidCallback? onAction,
  bool autoProceed = false,
  Duration autoProceedDelay = const Duration(milliseconds: 1200),
}) async {
  final colors = context.moonColors ?? MoonTokens.light.colors;

  final Color accent = switch (type) {
    ResultType.success => const Color(0xFF4CAF50), // green
    ResultType.error => const Color(0xFFE53935), // red
  };

  bool closed = false;

  Future<void> closeAndProceed(BuildContext ctx) async {
    if (closed) return;
    closed = true;
    Navigator.of(ctx).maybePop();
    // Panggil onAction setelah dialog tertutup untuk navigasi tambahan
    await Future.microtask(() => onAction?.call());
  }

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'ResultDialog',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, anim, secAnim) {
      if (autoProceed) {
        // Auto close after a short delay then proceed
        Future.delayed(autoProceedDelay, () => closeAndProceed(ctx));
      }
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.86,
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: MoonSquircleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ).squircleBorderRadius(ctx),
              ),
              shadows: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      type == ResultType.success
                          ? Icons.check_rounded
                          : Icons.close_rounded,
                      color: accent,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title ?? (type == ResultType.success ? 'Berhasil' : 'Gagal'),
                  textAlign: TextAlign.center,
                  style: MoonTokens.light.typography.heading.text18,
                ),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: MoonTokens.light.typography.body.text14.copyWith(
                      color: colors.trunks,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: MoonFilledButton(
                    onTap: () => closeAndProceed(ctx),
                    backgroundColor: colors.piccolo,
                    label: Text(actionLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, anim, secAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(curved);
      final fade = Tween<double>(begin: 0.8, end: 1).animate(curved);
      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}
