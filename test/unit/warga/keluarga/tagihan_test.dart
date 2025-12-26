import 'package:SapaWarga_kel_2/screens/warga/keluarga/tagihan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('DaftarTagihanWargaScreen Widget Test', () {
    Future<void> pumpPage(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DaftarTagihanWargaScreen()),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Menampilkan judul halaman dan search bar', (tester) async {
      await pumpPage(tester);
      expect(find.text('Daftar Tagihan'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('Menampilkan ListView tagihan (bisa kosong)', (tester) async {
      await pumpPage(tester);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Menampilkan filter modal saat ikon filter ditekan', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('Filter Status'), findsOneWidget);
      expect(find.text('Terapkan'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });
  });
}
