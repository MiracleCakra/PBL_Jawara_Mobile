import 'package:SapaWarga_kel_2/screens/warga/kegiatan/kirimansaya/tambah_aspirasi.dart';
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

  group('WargaTambahAspirasiScreen Widget Test', () {
    testWidgets('AppBar and form fields are displayed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: WargaTambahAspirasiScreen()),
      );

      expect(find.text('Buat Pesan Warga'), findsOneWidget);
      expect(find.text('Judul Pesan'), findsOneWidget);
      expect(find.text('Isi Pesan'), findsOneWidget);
      expect(find.text('Kirim Pesan'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('Validation error when fields are empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: WargaTambahAspirasiScreen()),
      );

      await tester.tap(find.text('Kirim Pesan'));
      await tester.pumpAndSettle();

      expect(find.text('Judul tidak boleh kosong'), findsOneWidget);
      expect(find.text('Isi pesan tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Reset button clears the form', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WargaTambahAspirasiScreen()),
      );

      final judulField = find.byType(TextFormField).first;
      final isiField = find.byType(TextFormField).last;

      await tester.enterText(judulField, 'Judul Dummy');
      await tester.enterText(isiField, 'Isi Dummy');
      await tester.pump();

      expect(find.text('Judul Dummy'), findsOneWidget);
      expect(find.text('Isi Dummy'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(find.text('Judul Dummy'), findsNothing);
      expect(find.text('Isi Dummy'), findsNothing);
    });
  });
}
