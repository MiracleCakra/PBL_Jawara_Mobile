import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:SapaWarga_kel_2/screens/admin/kegiatanMenu/broadcast/detail_broadcast_screen.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/broadcast_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  testWidgets('Detail Broadcast menampilkan data utama', (tester) async {
    final dummy = BroadcastModel(
      id: 1,
      judul: 'Pengumuman Penting',
      pengirim: 'Pak RT',
      tanggal: DateTime(2025, 1, 1),
      kategori: 'Umum',
      konten: 'Besok kerja bakti',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DetailBroadcastScreen(broadcastModel: dummy),
      ),
    );

    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Memastikan semua elemen utama muncul
    expect(find.text('Detail Broadcast'), findsOneWidget);
    expect(find.text('Pengumuman Penting'), findsOneWidget);
    expect(find.text('Besok kerja bakti'), findsOneWidget);
    expect(find.byKey(const Key('more_actions_button')), findsOneWidget);

    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
