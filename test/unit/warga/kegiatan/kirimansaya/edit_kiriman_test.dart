import 'package:SapaWarga_kel_2/models/kegiatan/aspirasi_model.dart';
import 'package:SapaWarga_kel_2/screens/warga/kegiatan/kirimansaya/edit_kiriman.dart';
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

  group('WargaEditKirimanScreen Widget Test', () {
    final dummyAspirasi = AspirasiModel(
      judul: 'Judul Dummy',
      isi: 'Isi Dummy',
      pengirim: 'Warga',
      status: 'Pending',
      tanggal: DateTime(2025, 12, 23),
      userId: 'user123',
    );

    Widget buildTestWidget() =>
        MaterialApp(home: WargaEditKirimanScreen(data: dummyAspirasi));

    testWidgets('AppBar and form fields are displayed', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Edit Pesan Warga'), findsOneWidget);
      expect(find.text('Judul Pesan'), findsOneWidget);
      expect(find.text('Isi Pesan'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('Form fields show initial data', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Judul Dummy'), findsOneWidget);
      expect(find.text('Isi Dummy'), findsOneWidget);
    });

    testWidgets('Validation error when fields are empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final judulField = find.byType(TextFormField).first;
      final isiField = find.byType(TextFormField).last;
      await tester.enterText(judulField, '');
      await tester.enterText(isiField, '');
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();
      expect(find.text('Judul tidak boleh kosong'), findsOneWidget);
      expect(find.text('Isi pesan tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Reset button restores initial data', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final judulField = find.byType(TextFormField).first;
      final isiField = find.byType(TextFormField).last;
      await tester.enterText(judulField, 'Baru');
      await tester.enterText(isiField, 'Baru');
      await tester.pump();
      expect(find.text('Baru'), findsNWidgets(2));
      await tester.tap(find.text('Reset'));
      await tester.pump();
      expect(find.text('Judul Dummy'), findsOneWidget);
      expect(find.text('Isi Dummy'), findsOneWidget);
    });
  });
}
