import 'package:SapaWarga_kel_2/models/kegiatan/aspirasi_model.dart';
import 'package:SapaWarga_kel_2/screens/warga/kegiatan/kirimansaya/detail_kiriman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

dummyAspirasi({String? status, String? userId}) => AspirasiModel(
  id: 1,
  judul: 'Judul Dummy',
  isi: 'Isi Dummy',
  pengirim: 'Warga',
  status: status ?? 'Pending',
  tanggal: DateTime(2025, 12, 23),
  userId: userId ?? 'user123',
);

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

  group('WargaDetailKirimanScreen Widget Test', () {
    testWidgets('AppBar and section titles are displayed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WargaDetailKirimanScreen(data: dummyAspirasi())),
      );
      expect(find.text('Detail Kiriman'), findsOneWidget);
      expect(find.text('Informasi Pesan'), findsOneWidget);
      expect(find.text('Metadata'), findsOneWidget);
      expect(find.text('Deskripsi'), findsOneWidget);
    });

    testWidgets('Show aspirasi data and deskripsi', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WargaDetailKirimanScreen(data: dummyAspirasi())),
      );
      expect(find.text('Judul Dummy'), findsOneWidget);
      expect(find.text('Isi Dummy'), findsOneWidget);
      expect(find.text('Warga'), findsOneWidget);
      expect(find.text('Pending'), findsWidgets);
      // Cari label tanggal dan pastikan ada value tanggal setelahnya
      final labelFinder = find.text('Tanggal Dikirim');
      expect(labelFinder, findsOneWidget);
      // Cari Text widget value tanggal
      final valueFinder = find.byWidgetPredicate(
        (w) =>
            w is Text &&
            w.data != null &&
            w.data!.contains('23') &&
            w.data!.contains('2025'),
      );
      expect(valueFinder, findsWidgets);
    });

    testWidgets('Action menu appears if canModify is true', (tester) async {
      final aspirasi = dummyAspirasi(status: 'Pending', userId: '');
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return WargaDetailKirimanScreen(data: aspirasi);
            },
          ),
        ),
      );
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('Tidak ada action menu jika status bukan Pending', (
      tester,
    ) async {
      final aspirasi = dummyAspirasi(status: 'Diterima', userId: 'user123');
      await tester.pumpWidget(
        MaterialApp(home: WargaDetailKirimanScreen(data: aspirasi)),
      );
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });
  });
}
