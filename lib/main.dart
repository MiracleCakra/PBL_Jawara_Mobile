import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:jawara_pintar_kel_5/router.dart';
import 'package:moon_design/moon_design.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Jawara Pintar',
      theme: ThemeData.light().copyWith(
        colorScheme: ThemeData.light().colorScheme.copyWith(
          primary: ConstantColors.primary,
        ),
        primaryColor: ConstantColors.primary,
        extensions: <ThemeExtension<dynamic>>[
          MoonTheme(tokens: MoonTokens.light),
        ],
        scaffoldBackgroundColor: MoonTokens.light.colors.gohan,
      ),
      // darkTheme: ThemeData.dark().copyWith(
      //   extensions: <ThemeExtension<dynamic>>[
      //     MoonTheme(tokens: MoonTokens.dark),
      //   ],
      // ),
      routerConfig: router,
    );
  }
}
