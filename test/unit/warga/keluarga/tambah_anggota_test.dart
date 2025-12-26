import 'package:SapaWarga_kel_2/screens/warga/keluarga/tambah_anggota.dart';
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

  group('TambahAnggotaKeluargaPage Widget Test', () {
    testWidgets('AppBar and initial loading indicator are displayed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: TambahAnggotaKeluargaPage()),
      );
      // AppBar title
      expect(find.text('Tambah Anggota Keluarga'), findsOneWidget);
      // Loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Form fields and dropdowns are present after loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: TambahAnggotaKeluargaPage()),
      );
      // Simulasi selesai loading
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Section judul
      expect(find.text('Pilih Anggota'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      // Cari DropdownButton apapun tipenya
      expect(
        find.byWidgetPredicate((widget) => widget is DropdownButton),
        findsWidgets,
      );
    });
  });
}
