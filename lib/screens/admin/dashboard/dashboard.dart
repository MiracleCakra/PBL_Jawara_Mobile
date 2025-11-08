import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/providers/admin_dashboard_provider.dart';
import 'package:jawara_pintar_kel_5/screens/admin/dashboard/kegiatan.dart';
import 'package:jawara_pintar_kel_5/screens/admin/dashboard/kependudukan.dart';
import 'package:jawara_pintar_kel_5/screens/admin/dashboard/keuangan.dart';
import 'package:moon_design/moon_design.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _previousPage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _previousPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AdminDashboardProvider(),
      child: Consumer<AdminDashboardProvider>(
        builder: (context, provider, child) {
          final current = provider.page;

          // keep pageController in sync when provider changes programmatically
          if (_pageController.hasClients &&
              _pageController.page?.round() != current) {
            _pageController.animateToPage(
              current,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }

          return Column(
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 16.0, top: 6),
                child: Column(
                  spacing: 8.0,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Dashboard",
                            style: MoonTokens.light.typography.heading.text20
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          Material(
                            color: Colors.grey,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => context.pushNamed('editProfile'),
                              child: const SizedBox(
                                width: 44,
                                height: 44,
                                child: Center(child: Icon(Icons.person)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    MoonSegmentedControl(
                      isExpanded: true,
                      segmentedControlSize: MoonSegmentedControlSize.md,
                      onSegmentChanged: (value) {
                        provider.page = value;
                        if (_pageController.hasClients) {
                          _pageController.animateToPage(
                            value,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      segments: provider.pages
                          .map(
                            (key) => Segment(
                              segmentStyle: SegmentStyle(
                                selectedSegmentColor: Theme.of(
                                  context,
                                ).primaryColor,
                                selectedTextColor: Colors.white,
                              ),
                              label: Flexible(
                                child: Text(
                                  key,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: MoonTokens.light.typography.body.text12
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    _previousPage = provider.page;
                    provider.page = index;
                  },
                  children: [Keuangan(), Kegiatan(), Kependudukan()],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
