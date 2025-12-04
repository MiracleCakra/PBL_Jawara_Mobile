import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:jawara_pintar_kel_5/constants/constant_colors.dart';
import 'package:jawara_pintar_kel_5/router.dart';
import 'package:moon_design/moon_design.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:jawara_pintar_kel_5/providers/product_provider.dart';
import 'package:jawara_pintar_kel_5/providers/marketplace/cart_provider.dart';
import 'package:jawara_pintar_kel_5/providers/marketplace/store_provider.dart';
import 'package:jawara_pintar_kel_5/providers/marketplace/order_provider.dart';
import 'package:jawara_pintar_kel_5/providers/marketplace/review_provider.dart';
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://vzqzejlragspnqbjxewh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6cXplamxyYWdzcG5xYmp4ZXdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4NDIzMjYsImV4cCI6MjA3ODQxODMyNn0.JtGaxww3HnmFYQ1bpBgDZrCAX6B_kKt8Th1BGnUDNZM',
  );
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()..fetchAllProducts()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: MaterialApp.router(
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
      ),
    );
  }
}
