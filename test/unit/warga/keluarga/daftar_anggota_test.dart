import 'package:SapaWarga_kel_2/screens/warga/keluarga/daftar_anggota.dart';
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
  group('DaftarAnggotaKeluargaPage Widget Test', () {
    Future<void> pumpPage(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DaftarAnggotaKeluargaPage(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Menampilkan judul halaman', (tester) async {
      await pumpPage(tester);

      expect(find.text('Daftar Anggota Keluarga'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Menampilkan search field', (tester) async {
      await pumpPage(tester);

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Menampilkan empty state ketika data kosong', (tester) async {
      await pumpPage(tester);

      expect(
        find.textContaining('Tidak'),
        findsOneWidget,
      );
    });

    testWidgets('Menampilkan FloatingActionButton', (tester) async {
      await pumpPage(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
