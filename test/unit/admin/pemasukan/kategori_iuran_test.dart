import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/screens/admin/pemasukan/kategori_iuran_screen.dart';

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

  TestWidgetsFlutterBinding.ensureInitialized();

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('KategoriIuranScreen Widget Test', () {
    testWidgets('Menampilkan judul dan komponen utama',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const KategoriIuranScreen()),
      );

      await tester.pump();

      // Judul AppBar
      expect(find.text('Kategori Iuran'), findsOneWidget);

      // Search Field
      expect(find.byType(TextField), findsOneWidget);

      // Tombol filter
      expect(find.byIcon(Icons.tune), findsOneWidget);

      // Floating Action Button
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Menampilkan pesan kosong saat data tidak ada',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const KategoriIuranScreen()),
      );

      await tester.pump();

      expect(find.text('Tidak ada data'), findsOneWidget);
    });

    testWidgets('Bottom sheet filter muncul saat tombol filter ditekan',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const KategoriIuranScreen()),
      );

      await tester.pump();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.text('Filter Kategori Iuran'), findsOneWidget);
      expect(find.byKey(const Key('dropdown_filter_jenis_iuran')),
          findsOneWidget);
      expect(find.text('Terapkan'), findsOneWidget);
    });
  });
}
