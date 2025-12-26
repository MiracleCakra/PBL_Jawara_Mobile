import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/screens/admin/laporan/semua_pengeluaran_screen.dart';
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

  group('SemuaPengeluaranScreen Widget Test', () {
    testWidgets('Menampilkan judul dan komponen utama',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const SemuaPengeluaranScreen()),
      );

      await tester.pump();

      // AppBar title
      expect(find.text('Semua Pengeluaran'), findsOneWidget);

      // Search field
      expect(find.byType(TextField), findsOneWidget);

      // Filter button
      expect(find.byIcon(Icons.tune), findsOneWidget);

      // Floating Action Button
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Menampilkan pesan kosong saat data belum ada',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const SemuaPengeluaranScreen()),
      );

      await tester.pump();

      expect(find.text('Tidak ada data'), findsOneWidget);
    });
  });
}
