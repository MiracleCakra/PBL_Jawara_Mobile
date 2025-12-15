import 'package:SapaWarga_kel_2/constants/constant_colors.dart';
import 'package:SapaWarga_kel_2/constants/iconify.dart';
import 'package:SapaWarga_kel_2/widget/bottom_app_bar_item.dart';
import 'package:SapaWarga_kel_2/widget/system_ui_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter/iconify_flutter.dart' show Iconify;

class SekretarisLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const SekretarisLayout({super.key, required this.navigationShell});

  @override
  State<SekretarisLayout> createState() => _SekretarisLayoutState();
}

class _SekretarisLayoutState extends State<SekretarisLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  bool _isAnimating = false;

  Widget getIconify(String icon, Color color) =>
      Iconify(icon, size: 24, color: color);

  // Sekretaris Menu: Kegiatan, Lainnya
  final Map<String, String> tabs = {
    'Kegiatan': IconifyConstants.arcticonActiviyManager,
    'Lainnya': IconifyConstants.fluentMoreHorizontalREG,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _fade = CurvedAnimation(
      parent: ReverseAnimation(_controller),
      curve: Curves.easeOutSine,
      reverseCurve: Curves.easeInSine,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SystemUiStyle(
      backgroundColor: widget.navigationShell.currentIndex == 0
          ? Colors.white
          : Colors.transparent,
      systemNavigationBarColor: Colors.white,
      child: Scaffold(
        body: SafeArea(
          child: FadeTransition(opacity: _fade, child: widget.navigationShell),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          height: 72,
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              tabs.length,
              (index) => BottomAppBarItem(
                icon: Iconify(
                  tabs.values.elementAt(index),
                  size: 24,
                  color: widget.navigationShell.currentIndex == index
                      ? ConstantColors.primary
                      : Colors.black,
                ),
                label: tabs.keys.elementAt(index),
                active: widget.navigationShell.currentIndex == index,
                onTap: () => _goTo(index),
              ),
            ).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _goTo(int index) async {
    final isReselect = index == widget.navigationShell.currentIndex;
    if (_isAnimating && !isReselect) return;

    if (isReselect) {
      widget.navigationShell.goBranch(index, initialLocation: true);
      return;
    }

    try {
      _isAnimating = true;
      await _controller.forward();
      if (!mounted) return;

      widget.navigationShell.goBranch(index, initialLocation: true);
      await Future.delayed(const Duration(milliseconds: 16));
    } finally {
      if (mounted) {
        await _controller.reverse();
      }
      _isAnimating = false;
    }
  }
}
