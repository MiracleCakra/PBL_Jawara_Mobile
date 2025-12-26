import 'package:SapaWarga_kel_2/screens/admin/penduduk/penerimaan/daftar_penerimaan_warga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      anonKey: 'dummy-anon-key',
    );
  });

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(home: child);
  }

  group('DaftarPenerimaanWargaPage Widget Test', () {
    testWidgets('Menampilkan judul AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const DaftarPenerimaanWargaPage()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Daftar Penerimaan Warga'), findsOneWidget);
    });

    testWidgets('Menampilkan tombol filter', (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const DaftarPenerimaanWargaPage()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Filter Penerimaan Warga'), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('Menampilkan empty state jika tidak ada data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        makeTestableWidget(const DaftarPenerimaanWargaPage()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tidak ada data penerimaan warga'), findsOneWidget);
    });
  });
}
