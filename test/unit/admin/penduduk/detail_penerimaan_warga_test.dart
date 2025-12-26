import 'package:SapaWarga_kel_2/screens/admin/penduduk/penerimaan/daftar_penerimaan_warga.dart';
import 'package:SapaWarga_kel_2/screens/admin/penduduk/penerimaan/detail_penerimaan_warga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      anonKey: 'dummy-anon-key',
    );
  });

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(home: child);
  }

  final dummyPenerimaan = PenerimaanWarga(
    nama: 'Budi Santoso',
    nik: '1234567890',
    jenisKelamin: 'Laki-laki',
    status: 'Pending',
    email: 'budi@email.com',
    foto: null,
    alamatRumah: 'Jl. Mawar No. 10',
    namaKeluarga: 'Keluarga Santoso',
    anggotaKeluarga: 'Budi, Siti',
    peran: 'Kepala Keluarga',
  );

  group('DetailPenerimaanWargaPage Widget Test', () {
    testWidgets('Menampilkan judul AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          DetailPenerimaanWargaPage(penerimaan: dummyPenerimaan),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Detail Pendaftaran Warga'), findsOneWidget);
    });

    testWidgets('Menampilkan nama dan NIK', (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          DetailPenerimaanWargaPage(penerimaan: dummyPenerimaan),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.textContaining('NIK: 1234567890'), findsOneWidget);
    });

    testWidgets('Menampilkan tombol menu aksi jika status pending/ditolak', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        makeTestableWidget(
          DetailPenerimaanWargaPage(penerimaan: dummyPenerimaan),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}
