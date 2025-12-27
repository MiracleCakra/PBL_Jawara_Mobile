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

  // Shared state across tests
  final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final String testJudul = 'Aspirasi Test $timestamp';
  final String editedJudul = '$testJudul (Edited)';

  // --- HELPER FUNCTIONS ---
  Future<void> performLogin(WidgetTester tester) async {
    print('LOG: Starting Login Process...');
    
    if (tester.any(find.byKey(const Key('kegiatan_tab')))) { 
      print('LOG: Already logged in.');
      return;
    }

    if (!tester.any(find.byKey(const Key('btn_show_login_form')))) {
       await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    if (tester.any(find.byKey(const Key('btn_show_login_form')))) {
        await tester.ensureVisible(find.byKey(const Key('btn_show_login_form')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_show_login_form')));
        await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    print('LOG: Filling login form for Warga...');
    await tester.enterText(find.byKey(const Key('input_email')), 'warga1@gmail.com');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byKey(const Key('input_password')), 'password');
    await tester.pump(const Duration(milliseconds: 100));

    print('LOG: Submitting login...');
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
    
    final profilTab = find.byKey(const Key('profil_tab'));
    if (!tester.any(profilTab)) {
        // Try going back in case we are in a detail screen
        await tester.pageBack(); 
        await tester.pumpAndSettle();
    }
    
    await tester.tap(profilTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final logoutButton = find.text('Keluar');
    await tester.scrollUntilVisible(logoutButton, 500.0, scrollable: find.byType(Scrollable).first);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    final confirmLogout = find.text('Ya, Keluar');
    await tester.tap(confirmLogout);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byKey(const Key('btn_show_login_form')), findsOneWidget);
    print('LOG: LOGOUT SUCCESSFUL');
  }

  group('Warga Aspirasi Tests (Non-One-Flow)', () {
    
    setUpAll(() async {
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
    });

    testWidgets('1. Create Aspirasi', (WidgetTester tester) async {
      runApp(const app.MyApp());
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await performLogin(tester);

      print('LOG: Navigating to Aspirasi...');
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.ensureVisible(find.byKey(const Key('warga_menu_kiriman_saya')));
      await tester.tap(find.byKey(const Key('warga_menu_kiriman_saya')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('LOG: Creating Aspirasi...');
      await tester.tap(find.byKey(const Key('fab_tambah_aspirasi')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(find.byKey(const Key('input_judul_aspirasi')), testJudul);
      await tester.enterText(find.byKey(const Key('input_isi_aspirasi')), 'Isi Aspirasi Test $timestamp');
      await tester.tap(find.byKey(const Key('btn_kirim_aspirasi')));
      
      // Wait for success dialog
      bool foundSuccess = false;
      for (int i = 0; i < 20; i++) {
        if (tester.any(find.text('Selesai'))) {
          foundSuccess = true;
          break;
        }
        await tester.pump(const Duration(milliseconds: 500));
      }
      if (foundSuccess) {
        await tester.tap(find.text('Selesai'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      print('LOG: Verifying Creation...');
      final newItem = find.text(testJudul);
      await tester.scrollUntilVisible(newItem, 500.0, scrollable: find.byType(Scrollable).first);
      expect(newItem, findsOneWidget);

      await tester.tap(find.byKey(const Key('back_button_aspirasi_list')));
      await tester.pumpAndSettle();

      await performLogout(tester);
    });

    testWidgets('2. Edit Aspirasi', (WidgetTester tester) async {
      runApp(const app.MyApp());
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await performLogin(tester);

      print('LOG: Navigating to Aspirasi...');
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key('warga_menu_kiriman_saya')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('LOG: Opening Aspirasi Detail for Edit...');
      final item = find.text(testJudul);
      await tester.scrollUntilVisible(item, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(item);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('LOG: Editing Aspirasi...');
      await tester.tap(find.byKey(const Key('detail_aspirasi_more_options')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('option_edit_aspirasi')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(find.byKey(const Key('edit_judul_aspirasi')), editedJudul);
      await tester.tap(find.byKey(const Key('btn_save_edit_aspirasi')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (tester.any(find.text('Selesai'))) {
        await tester.tap(find.text('Selesai'));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      print('LOG: Verifying Edit...');
      // It might pop back to list or detail. per-flow suggests list.
      if (tester.any(find.text(editedJudul))) {
          expect(find.text(editedJudul), findsOneWidget);
      } else {
          // If in detail
          expect(find.byKey(const Key('detail_aspirasi_judul')), findsOneWidget);
          expect(find.text(editedJudul), findsOneWidget);
          await tester.tap(find.byKey(const Key('back_button_aspirasi_detail'))); 
          await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const Key('back_button_aspirasi_list')));
      await tester.pumpAndSettle();

      await performLogout(tester);
    });

    testWidgets('3. Delete Aspirasi', (WidgetTester tester) async {
      runApp(const app.MyApp());
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await performLogin(tester);

      print('LOG: Navigating to Aspirasi...');
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key('warga_menu_kiriman_saya')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('LOG: Opening Aspirasi Detail for Delete...');
      final item = find.text(editedJudul);
      await tester.scrollUntilVisible(item, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(item);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('LOG: Deleting Aspirasi...');
      await tester.tap(find.byKey(const Key('detail_aspirasi_more_options')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('option_delete_aspirasi')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('LOG: Verifying Deletion...');
      expect(find.text(editedJudul), findsNothing);

      await tester.tap(find.byKey(const Key('back_button_aspirasi_list')));
      await tester.pumpAndSettle();

      await performLogout(tester);
    });

  });
}
