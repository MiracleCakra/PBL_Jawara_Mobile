import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:SapaWarga_kel_2/main.dart' as app;
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:SapaWarga_kel_2/firebase_options.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final String namaKegiatan = 'Kerja Bakti Tes Full $timestamp';
  final String editedNamaKegiatan = 'Kerja Bakti (edited) $timestamp';

  Future<void> performLogin(WidgetTester tester) async {
    print('LOG: Starting Login Process...');
    
    if (tester.any(find.byKey(const Key('kegiatan_tab')))) {
      return;
    }

    if (!tester.any(find.byKey(const Key('btn_show_login_form')))) {
       await tester.pump(const Duration(seconds: 2));
    }

    if (tester.any(find.byKey(const Key('btn_show_login_form')))) {
        await tester.ensureVisible(find.byKey(const Key('btn_show_login_form')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('btn_show_login_form')));
        await tester.pump(const Duration(seconds: 1));
    }

    await tester.ensureVisible(find.byKey(const Key('input_email')));
    await tester.enterText(find.byKey(const Key('input_email')), 'admin@gmail.com');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byKey(const Key('input_password')), 'password');
    await tester.pump(const Duration(milliseconds: 100));

    await tester.ensureVisible(find.byKey(const Key('btn_submit_login')));
    await tester.tap(find.byKey(const Key('btn_submit_login')));
    
    bool atDashboard = false;
    for (int i = 0; i < 30; i++) {
      if (tester.any(find.byKey(const Key('kegiatan_tab')))) {
        atDashboard = true;
        break;
      }
      await tester.pump(const Duration(seconds: 1));
    }
    if (!atDashboard) fail('Failed to reach dashboard after login');
  }

  Future<void> performLogout(WidgetTester tester) async {
    print('LOG: Performing Logout...');
    final lainnyaTab = find.byKey(const Key('lainnya_tab'));
    if (tester.any(lainnyaTab)) {
        await tester.tap(lainnyaTab);
        await tester.pump(const Duration(seconds: 2));
    }

    final logoutBtn = find.text('Keluar');
    if (tester.any(logoutBtn)) {
        await tester.scrollUntilVisible(logoutBtn, 500, scrollable: find.byType(Scrollable).first);
        await tester.tap(logoutBtn);
        await tester.pump(const Duration(seconds: 2));
        
        if (tester.any(find.text('Ya, Keluar'))) {
            await tester.tap(find.text('Ya, Keluar'));
            await tester.pump(const Duration(seconds: 3));
        }
    }
  }

  testWidgets('Admin Kegiatan Full Single Flow Test', (WidgetTester tester) async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      print('Firebase already initialized');
    }
    await Supabase.initialize(
      url: 'https://vzqzejlragspnqbjxewh.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6cXplamxyYWdzcG5xYmp4ZXdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4NDIzMjYsImV4cCI6MjA3ODQxODMyNn0.JtGaxww3HnmFYQ1bpBgDZrCAX6B_kKt8Th1BGnUDNZM',
    );
    await initializeDateFormatting('id_ID', null);

    app.main();
    await tester.pump(const Duration(seconds: 2));
    
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await performLogin(tester);

    // --- CREATE ---
    await tester.tap(find.byKey(const Key('kegiatan_tab')));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byKey(const Key('daftar_kegiatan_button')));
    await tester.pump(const Duration(seconds: 5)); // Stream load
    await tester.tap(find.byKey(const Key('add_kegiatan_fab')));
    await tester.pump(const Duration(seconds: 2));

    await tester.enterText(find.byKey(const Key('nama_kegiatan_field')), namaKegiatan);
    await tester.tap(find.byKey(const Key('kategori_kegiatan_dropdown')));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Kebersihan dan Keamanan').last);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('tanggal_kegiatan_field')));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Pilih'));
    await tester.pump(const Duration(seconds: 1));

    await tester.enterText(find.byKey(const Key('lokasi_kegiatan_field')), 'Sekitar RT 01');
    await tester.enterText(find.byKey(const Key('pj_kegiatan_field')), 'Admin Test');
    await tester.enterText(find.byKey(const Key('deskripsi_kegiatan_field')), 'Deskripsi $timestamp');

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('upload_dokumentasi')));
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byKey(const Key('simpan_kegiatan_button')));
    await tester.pump(const Duration(seconds: 5)); // Saving

    await tester.tap(find.byKey(const Key('selesai_button')));
    await tester.pump(const Duration(seconds: 5)); // Back to list with refresh

    expect(find.text(namaKegiatan), findsOneWidget);

    // --- VIEW DETAIL ---
    await tester.tap(find.ancestor(
      of: find.text(namaKegiatan),
      matching: find.byType(GestureDetector),
    ));
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Detail Kegiatan'), findsOneWidget);
    
    // --- EDIT ---
    await tester.tap(find.byKey(const Key('kegiatan_more_actions_button')));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('edit_kegiatan_button')));
    await tester.pump(const Duration(seconds: 2));

    await tester.enterText(
        find.byKey(const Key('edit_nama_kegiatan_field')), editedNamaKegiatan);

    await tester.tap(find.byKey(const Key('simpan_edit_kegiatan_button')));
    await tester.pump(const Duration(seconds: 5));

    // After edit success, pop happens in Edit screen back to Detail
    // We are at Detail screen now
    await tester.tap(find.byKey(const Key('back_button_admin_kegiatan_detail')));
    await tester.pump(const Duration(seconds: 2)); // Back to List

    expect(find.text(editedNamaKegiatan), findsOneWidget);

    // --- DELETE ---
    await tester.tap(find.ancestor(
      of: find.text(editedNamaKegiatan),
      matching: find.byType(GestureDetector),
    ));
    await tester.pump(const Duration(seconds: 3));

    await tester.tap(find.byKey(const Key('kegiatan_more_actions_button')));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('delete_kegiatan_button')));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('confirm_delete_kegiatan_button')));
    await tester.pump(const Duration(seconds: 5)); // Delete and pop to list

    expect(find.text(editedNamaKegiatan), findsNothing);

    // --- FINISH ---
    // Back to Menu
    await tester.tap(find.byKey(const Key('back_button_admin_kegiatan_list')));
    await tester.pump(const Duration(seconds: 2));

    await performLogout(tester);
  });
}