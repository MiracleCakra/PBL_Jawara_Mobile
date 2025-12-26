import 'package:SapaWarga_kel_2/models/keuangan/warga_tagihan_model.dart';
import 'package:SapaWarga_kel_2/screens/warga/keluarga/form_pembayaran.dart';
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
  final dummyChannel = {
    'type': 'BRI',
    'account': '1234-5678-9012-3456',
    'owner': 'Bendahara RW 05 (Budi Santoso)',
  };

  group('FormPembayaranScreen Widget Test', () {
    Future<void> pumpPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormPembayaranScreen(
            tagihan: dummyTagihan,
            channel: dummyChannel,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Menampilkan judul dan rekening tujuan', (tester) async {
      await pumpPage(tester);
      expect(find.text('Konfirmasi Pembayaran'), findsOneWidget);
      expect(find.textContaining('Silakan transfer ke:'), findsOneWidget);
      expect(find.text('BRI'), findsOneWidget);
      expect(find.text('1234-5678-9012-3456'), findsOneWidget);
      expect(find.textContaining('Bendahara RW 05'), findsOneWidget);
    });

    testWidgets('Menampilkan upload bukti transfer dan catatan', (
      tester,
    ) async {
      await pumpPage(tester);
      expect(find.text('Bukti Transfer'), findsOneWidget);
      expect(find.text('Ketuk untuk upload Struk'), findsOneWidget);
      expect(find.text('Catatan (Opsional)'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Tombol Kirim Bukti Pembayaran muncul', (tester) async {
      await pumpPage(tester);
      expect(find.text('Kirim Bukti Pembayaran'), findsOneWidget);
    });
  });
}
