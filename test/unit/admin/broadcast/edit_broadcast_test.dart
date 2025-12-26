import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:SapaWarga_kel_2/screens/admin/kegiatanMenu/broadcast/edit_broadcast_screen.dart';
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

  testWidgets('Edit Broadcast menampilkan form', (tester) async {
    final dummy = BroadcastModel(
      id: 1,
      judul: 'Judul Lama',
      pengirim: 'Admin',
      tanggal: DateTime.now(),
      kategori: 'Info',
      konten: 'Isi lama',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EditBroadcastScreen(broadcast: dummy),
      ),
    );

    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Memastikan semua field & tombol muncul
    expect(find.text('Edit Broadcast'), findsOneWidget);
    expect(find.byKey(const Key('edit_judul_broadcast_field')), findsOneWidget);
    expect(find.byKey(const Key('edit_isi_broadcast_field')), findsOneWidget);
    expect(find.byKey(const Key('simpan_edit_broadcast_button')), findsOneWidget);

    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  });
}
