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

  testWidgets('Aspirasi Warga CRUD End-to-End Test', (WidgetTester tester) async {
    // Manual Initialization
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

    runApp(const app.MyApp());
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // --- LOGIN ---
    print('LOG: Starting Login...');
    
    if (!tester.any(find.byKey(const Key('kegiatan_tab')))) {
      Finder btnShowForm = find.byKey(const Key('btn_show_login_form'));
      for (int i = 0; i < 30; i++) {
        if (tester.any(btnShowForm) || tester.any(find.text('Login'))) break;
        await tester.pump(const Duration(milliseconds: 500));
      }

      if (!tester.any(btnShowForm)) btnShowForm = find.text('Login').first;
      await tester.tap(btnShowForm);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('input_email')), 'warga1@gmail.com');
      await tester.enterText(find.byKey(const Key('input_password')), 'password');
      await tester.tap(find.byKey(const Key('btn_submit_login')));
      
      for (int i = 0; i < 30; i++) {
        if (tester.any(find.byKey(const Key('kegiatan_tab')))) break;
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    // --- NAVIGATE TO ASPIRASI ---
    print('LOG: Navigating to Aspirasi...');
    await tester.tap(find.byKey(const Key('kegiatan_tab')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('warga_menu_kiriman_saya')));
    await tester.tap(find.byKey(const Key('warga_menu_kiriman_saya')));
    await tester.pumpAndSettle();

    // --- CREATE ---
    print('LOG: Creating Aspirasi...');
    await tester.tap(find.byKey(const Key('fab_tambah_aspirasi')));
    await tester.pumpAndSettle();

    final testJudul = 'Test E2E ${DateTime.now().millisecondsSinceEpoch}';
    final testIsi = 'Isi Aspirasi Test';
    
    await tester.enterText(find.byKey(const Key('input_judul_aspirasi')), testJudul);
    await tester.enterText(find.byKey(const Key('input_isi_aspirasi')), testIsi);
    await tester.tap(find.byKey(const Key('btn_kirim_aspirasi')));
    
    for (int i = 0; i < 20; i++) {
      if (tester.any(find.text('Selesai'))) break;
      await tester.pump(const Duration(milliseconds: 500));
    }
    if (tester.any(find.text('Selesai'))) {
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
    }

    // --- VERIFY CREATE ---
    print('LOG: Verifying Creation...');
    final newItem = find.text(testJudul);
    await tester.scrollUntilVisible(newItem, 500.0, scrollable: find.byType(Scrollable).first);
    expect(newItem, findsOneWidget);

    await tester.tap(newItem);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('detail_aspirasi_judul')), findsOneWidget);
    expect(find.text(testJudul), findsWidgets);

    // --- EDIT ---
    print('LOG: Editing Aspirasi...');
    await tester.tap(find.byKey(const Key('detail_aspirasi_more_options')));
    await tester.pumpAndSettle();
    
    await tester.tap(find.byKey(const Key('option_edit_aspirasi')));
    
    // Improved waiting for Edit Screen
    Finder editField = find.byKey(const Key('edit_judul_aspirasi'));
    bool editScreenLoaded = false;
    for (int i = 0; i < 40; i++) { 
        if (tester.any(editField)) {
            editScreenLoaded = true;
            break;
        }
        await tester.pump(const Duration(milliseconds: 250));
    }
    
    expect(editField, findsOneWidget);

    final editedJudul = '$testJudul (Edited)';
    await tester.enterText(editField, editedJudul);
    await tester.tap(find.byKey(const Key('btn_save_edit_aspirasi')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Handle Success Modal
    if (tester.any(find.text('Selesai'))) {
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
    }

    // Verify Edit in Detail (or List)
    // Note: After edit success, the app might pop back to list or detail. 
    // The previous run logs suggested it popped back to list.
    print('LOG: Verifying Edit...');
    final editedItem = find.text(editedJudul);
    if (tester.any(editedItem)) {
       expect(editedItem, findsOneWidget);
       // Tap to open detail for deletion
       await tester.tap(editedItem);
       await tester.pumpAndSettle();
    } else {
       // Maybe we are still in detail screen? Check key
       if (tester.any(find.byKey(const Key('detail_aspirasi_judul')))) {
          expect(find.text(editedJudul), findsOneWidget);
       } else {
          // If not in list and not in detail, maybe refresh list?
          // But assume we are in list
          await tester.scrollUntilVisible(editedItem, 500.0, scrollable: find.byType(Scrollable).first);
          await tester.tap(editedItem);
          await tester.pumpAndSettle();
       }
    }
    print('LOG: Edit Verified.');

    // --- DELETE ---
    print('LOG: Deleting Aspirasi...');
    await tester.tap(find.byKey(const Key('detail_aspirasi_more_options')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('option_delete_aspirasi')));
    await tester.pumpAndSettle();

    // Confirm Delete
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify Deletion in List
    print('LOG: Verifying Deletion...');
    expect(find.byKey(const Key('fab_tambah_aspirasi')), findsOneWidget); 
    expect(find.text(editedJudul), findsNothing);
    
    print('LOG: ALL TESTS PASSED');
  });
}