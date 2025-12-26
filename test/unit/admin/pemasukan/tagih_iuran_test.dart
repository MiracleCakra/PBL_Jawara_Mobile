import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/screens/admin/pemasukan/tagih_iuran_screen.dart';
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

  group('TagihIuranScreen Widget Test', () {
    testWidgets('Screen dapat dirender dengan benar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const TagihIuranScreen()),
      );

      // Tunggu frame awal
      await tester.pump();

      expect(find.text('Tagihan Iuran'), findsOneWidget);
      expect(
        find.text('Tagih Iuran ke Semua Keluarga Aktif'),
        findsOneWidget,
      );
    });

    testWidgets('Komponen utama UI tampil',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const TagihIuranScreen()),
      );

      await tester.pump();

      // Label
      expect(find.text('Jenis Iuran'), findsOneWidget);
      expect(find.text('Tanggal'), findsOneWidget);

      // Tombol
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Tagih Iuran'), findsOneWidget);

      // Dropdown (masih loading indicator di awal)
      expect(find.byType(DropdownButtonFormField), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'Klik tombol Tagih Iuran tanpa memilih iuran menampilkan SnackBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const TagihIuranScreen()),
      );

      await tester.pump();

      // Tap tombol Tagih Iuran
      await tester.tap(find.text('Tagih Iuran'));
      await tester.pump(); // Trigger SnackBar

      expect(
        find.text('Mohon pilih jenis iuran terlebih dahulu'),
        findsOneWidget,
      );
    });

    testWidgets('Tombol Reset dapat ditekan tanpa error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const TagihIuranScreen()),
      );

      await tester.pump();

      await tester.tap(find.text('Reset'));
      await tester.pump();

      // Tidak crash = lulus
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('Date picker container dapat ditekan',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const TagihIuranScreen()),
      );

      await tester.pump();

      // Cari icon kalender
      final calendarIcon = find.byIcon(Icons.calendar_today_outlined);
      expect(calendarIcon, findsOneWidget);

      await tester.tap(calendarIcon);
      await tester.pump();

    });
  });
}
