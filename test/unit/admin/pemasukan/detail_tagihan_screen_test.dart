import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/screens/admin/pemasukan/detail_tagihan_screen.dart';
import 'package:SapaWarga_kel_2/models/keuangan/tagihan_model.dart';
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

  // Dummy data Tagihan
  final dummyTagihan = TagihanModel(
    kodeTagihan: 'TAG-001',
    statusKeluarga: 'Aktif',
    iuran: 'Iuran Kebersihan',
    periode: DateTime(2025, 1, 1),
    nominal: 50000,
    status: 'Pending',
    namaKeluarga: 'Budi Santoso',
    alamat: 'Jl. Mawar No. 10',
    buktiPembayaran: null,
    catatanWarga: 'Sudah transfer',
  );

  group('DetailTagihanScreen Widget Test', () {
    testWidgets('Menampilkan judul dan data utama tagihan',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          DetailTagihanScreen(tagihan: dummyTagihan),
        ),
      );

      await tester.pump();

      expect(
        find.text('Verifikasi Pembayaran Iuran'),
        findsOneWidget,
      );
      expect(find.text('TAG-001'), findsOneWidget);
      expect(find.text('Iuran Kebersihan'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('Tombol opsi muncul saat status Pending',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          DetailTagihanScreen(tagihan: dummyTagihan),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('Bottom sheet verifikasi muncul saat tombol opsi ditekan',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          DetailTagihanScreen(tagihan: dummyTagihan),
        ),
      );

      await tester.pump();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Verifikasi Pembayaran'), findsOneWidget);
      expect(find.text('Setujui'), findsOneWidget);
      expect(find.text('Tolak'), findsOneWidget);
    });
  });
}
