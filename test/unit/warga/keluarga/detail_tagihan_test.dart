import 'package:SapaWarga_kel_2/models/keuangan/warga_tagihan_model.dart';
import 'package:SapaWarga_kel_2/screens/warga/keluarga/detail_tagihan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  final dummyTagihan = WargaTagihanModel(
    namaKeluarga: 'Keluarga Santoso',
    statusKeluarga: 'Aktif',
    iuran: 'Agustusan',
    kodeTagihan: 'TAG123',
    nominal: 50,
    periode: DateTime(2025, 8, 1),
    status: 'Belum Dibayar',
    alamat: 'Jl. Mawar No. 1',
    bukti: '',
  );

  group('DetailTagihanWargaScreen Widget Test', () {
    Future<void> pumpPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DetailTagihanWargaScreen(tagihan: dummyTagihan)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Menampilkan judul dan tab', (tester) async {
      await pumpPage(tester);
      expect(find.text('Detail Tagihan'), findsOneWidget);
      expect(find.text('Rincian'), findsOneWidget);
      expect(find.text('Status & Bukti'), findsOneWidget);
    });

    testWidgets('Menampilkan info utama tagihan', (tester) async {
      await pumpPage(tester);
      expect(find.textContaining('Iuran Agustusan'), findsOneWidget);
      expect(find.text('TAG123'), findsOneWidget);
      expect(find.text('Keluarga'), findsOneWidget);
      expect(find.text('Keluarga Santoso'), findsOneWidget);
      expect(find.text('Alamat'), findsOneWidget);
      expect(find.text('Jl. Mawar No. 1'), findsOneWidget);
    });

    testWidgets('Menampilkan tab Status & Bukti', (tester) async {
      await pumpPage(tester);
      await tester.tap(find.text('Status & Bukti'));
      await tester.pumpAndSettle();
      expect(find.text('Status Saat Ini'), findsOneWidget);
      expect(find.textContaining('BELUM DIBAYAR'), findsOneWidget);
    });

    testWidgets('Tombol Bayar Sekarang muncul jika status Belum Dibayar', (
      tester,
    ) async {
      await pumpPage(tester);
      expect(find.text('Bayar Sekarang'), findsOneWidget);
    });
  });
}
