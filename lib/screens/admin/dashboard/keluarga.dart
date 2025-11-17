import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/widget/gradient_menu_card.dart';

class Keluarga extends StatelessWidget {
  const Keluarga({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          children: [
            GradientMenuCard(
              icon: Icons.people_alt_outlined,
              title: 'Data Keluarga',
              subtitle: 'Lihat dan kelola data keluarga',
              gradientColors: const [Color(0xFF6B8E23), Color(0xFF8FBC8F)],
              onTap: () {
                context.pushNamed('listKeluarga');
              },
            ),
          ],
        ),
      ),
    );
  }
}
