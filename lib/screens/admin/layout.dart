import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter/iconify_flutter.dart' show Iconify;
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:jawara_pintar_kel_5/constants/iconify.dart';
import 'package:jawara_pintar_kel_5/widget/bottom_app_bar_item.dart';
import 'package:jawara_pintar_kel_5/widget/system_ui_style.dart';
import 'package:moon_design/moon_design.dart';

class AdminLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AdminLayout({super.key, required this.navigationShell});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  bool _isAnimating = false;

  Widget getIconify(String icon, Color color) =>
      Iconify(icon, size: 24, color: color);

  final Map<String, String> tabs = {
    'Rumah': '',
    'Penduduk': IconifyConstants.fluentPeopleLight,
    'Keuangan': IconifyConstants.letsIconMoneyLight,
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
      backgroundColor:
          widget.navigationShell.currentIndex == 1 ||
              widget.navigationShell.currentIndex == 2 ||
              widget.navigationShell.currentIndex == 3
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
                icon: index == 0
                    ? Icon(MoonIcons.generic_home_32_regular)
                    : Iconify(
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
    // Reset the current branch if tapping the active tab.
    final isReselect = index == widget.navigationShell.currentIndex;
    if (_isAnimating && !isReselect) return; // avoid overlapping animations

    if (isReselect) {
      widget.navigationShell.goBranch(index, initialLocation: true);
      return;
    }

    try {
      _isAnimating = true;
      // Fade out current content
      await _controller.forward();
      if (!mounted) return;

      // Switch branch while content is invisible
      widget.navigationShell.goBranch(index, initialLocation: true);

      // Give a frame for the new content to layout before fade-in
      await Future.delayed(const Duration(milliseconds: 16));
    } finally {
      if (mounted) {
        await _controller.reverse(); // Fade in new content
      }
      _isAnimating = false;
    }
  }
}
