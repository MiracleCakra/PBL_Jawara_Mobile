import 'package:SapaWarga_kel_2/screens/admin/laporan/cetak_laporan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moon_design/moon_design.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
   setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      anonKey: 'dummy-anon-key',
    );
  });
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        extensions: <ThemeExtension<dynamic>>[
          MoonTheme(tokens: MoonTokens.light),
        ],
      ),
      home: child,
    );
  }


  group('CetakLaporanScreen Widget Test', () {
    testWidgets('Menampilkan judul dan subtitle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const CetakLaporanScreen()),
      );

      await tester.pumpAndSettle();

      // AppBar title
      expect(find.text('Cetak Laporan'), findsOneWidget);

      // Subtitle
      expect(
        find.text('Cetak atau ekspor laporan keuangan'),
        findsOneWidget,
      );
    });

    testWidgets('Menampilkan segmented jenis laporan',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const CetakLaporanScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Jenis Laporan'), findsOneWidget);
      expect(find.text('Pemasukan'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
    });

    testWidgets('Menampilkan field periode tanggal',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const CetakLaporanScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Periode'), findsOneWidget);
      expect(find.text('Dari tanggal'), findsOneWidget);
      expect(find.text('Sampai tanggal'), findsOneWidget);
    });

    testWidgets('Menampilkan tombol Cetak',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const CetakLaporanScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Cetak'), findsOneWidget);
      expect(find.byType(MoonFilledButton), findsOneWidget);
    });
  });
}
