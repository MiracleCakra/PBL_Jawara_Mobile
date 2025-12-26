import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:SapaWarga_kel_2/screens/admin/kegiatanMenu/broadcast/tambah_broadcast.dart';

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

  group('Widget Test Tambah Broadcast', () {
    testWidgets('Menampilkan elemen utama form', (tester) async {
      tester.binding.window.physicalSizeTestValue =
          const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: TambahBroadcastScreen(),
        ),
      );

      // AppBar
      expect(find.text('Buat Broadcast Baru'), findsOneWidget);

      // Field form
      expect(find.byKey(const Key('judul_broadcast_field')),
          findsOneWidget);
      expect(find.byKey(const Key('isi_broadcast_field')),
          findsOneWidget);

      // Tombol
      expect(find.text('Batal'), findsOneWidget);
      expect(find.byKey(const Key('simpan_broadcast_button')),
          findsOneWidget);

      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });

    testWidgets('Validasi muncul jika form kosong', (tester) async {
      tester.binding.window.physicalSizeTestValue =
          const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: TambahBroadcastScreen(),
        ),
      );

      final simpanButton =
          find.byKey(const Key('simpan_broadcast_button'));

      // WAJIB: pastikan tombol terlihat
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      // Validasi form
      expect(find.text('Judul Broadcast wajib diisi.'),
          findsOneWidget);
      expect(find.text('Isi Broadcast wajib diisi.'),
          findsOneWidget);

      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });

    testWidgets('Tombol batal menutup halaman', (tester) async {
      tester.binding.window.physicalSizeTestValue =
          const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => const TambahBroadcastScreen(),
            ),
          ),
        ),
      );

      final batalButton = find.text('Batal');

      // WAJIB: scroll ke tombol
      await tester.ensureVisible(batalButton);
      await tester.tap(batalButton);
      await tester.pumpAndSettle();

      // Halaman sudah tertutup
      expect(find.text('Buat Broadcast Baru'), findsNothing);

      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });
    });
  });
}
