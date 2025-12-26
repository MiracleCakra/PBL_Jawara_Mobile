import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/screens/admin/pemasukan/tagihan_screen.dart';
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

  group('TagihanScreen Widget Test', () {
    testWidgets('Screen Tagihan dapat dirender',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const TagihanScreen()),
      );

      await tester.pump();

      expect(find.text('Tagihan'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('Search field dapat menerima input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const TagihanScreen()),
      );

      await tester.pump();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Agustusan');
      await tester.pump();

      expect(find.text('Agustusan'), findsOneWidget);
    });

    testWidgets('Menampilkan empty state saat data kosong',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const TagihanScreen()),
      );

      await tester.pump();

      expect(find.text('Tidak ada tagihan ditemukan'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('Filter button membuka modal bottom sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const TagihanScreen()),
      );

      await tester.pump();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.text('Filter Tagihan'), findsOneWidget);
      expect(find.text('Status Pembayaran'), findsOneWidget);
      expect(find.text('Status Keluarga'), findsOneWidget);
      expect(find.text('Iuran'), findsOneWidget);
    });

    testWidgets('Reset Filter dapat ditekan',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const TagihanScreen()),
      );

      await tester.pump();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset Filter'));
      await tester.pump();

      expect(find.text('Reset Filter'), findsOneWidget);
    });

    testWidgets('Tombol Terapkan pada filter dapat ditekan',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const TagihanScreen()),
      );

      await tester.pump();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      // Bottom sheet tertutup → screen utama tampil
      expect(find.text('Tagihan'), findsOneWidget);
    });
  });
}
