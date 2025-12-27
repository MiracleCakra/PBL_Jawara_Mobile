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

  Future<void> performLogin(WidgetTester tester) async {
    print('LOG: Starting Login Process...');
    if (tester.any(find.byKey(const Key('kegiatan_tab')))) return;

    if (!tester.any(find.byKey(const Key('btn_show_login_form')))) {
       await tester.pump(const Duration(seconds: 2));
    }
    if (tester.any(find.byKey(const Key('btn_show_login_form')))) {
        await tester.ensureVisible(find.byKey(const Key('btn_show_login_form')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('btn_show_login_form')));
        await tester.pumpAndSettle(const Duration(seconds: 1));
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
        await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    final logoutBtn = find.byKey(const Key('logout_button'));
    if (tester.any(logoutBtn)) {
        await tester.scrollUntilVisible(logoutBtn, 500, scrollable: find.byType(Scrollable).first);
        await tester.tap(logoutBtn);
        await tester.pump();
        if (tester.any(find.text('Ya, Keluar'))) {
            await tester.tap(find.text('Ya, Keluar'));
            await tester.pumpAndSettle(const Duration(seconds: 3));
        }
    }
  }

  group('Admin Aspirasi Tests', () {
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

    testWidgets('1. Search Aspirasi', (WidgetTester tester) async {
      app.main();
      await tester.pump(const Duration(seconds: 2));
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await performLogin(tester);

      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pump(const Duration(seconds: 2));
      
      final pesanButton = find.byKey(const Key('pesan_warga_button'));
      await tester.scrollUntilVisible(pesanButton, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(pesanButton);
      await tester.pump(const Duration(seconds: 5));

      final searchField = find.byKey(const Key('pesan_warga_search_field'));
      await tester.enterText(searchField, 'Test');
      await tester.pump(const Duration(seconds: 2));
      print('LOG: Search Performed.');

      await tester.tap(find.byKey(const Key('pesan_warga_back_button')));
      await tester.pump(const Duration(seconds: 2));

      await performLogout(tester);
    });

    testWidgets('2. Filter Aspirasi', (WidgetTester tester) async {
      app.main();
      await tester.pump(const Duration(seconds: 2));
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await performLogin(tester);

      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pump(const Duration(seconds: 2));
      
      final pesanButton = find.byKey(const Key('pesan_warga_button'));
      await tester.scrollUntilVisible(pesanButton, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(pesanButton);
      await tester.pump(const Duration(seconds: 5));

      print('LOG: Opening Filter...');
      await tester.tap(find.byKey(const Key('pesan_warga_filter_button')));
      await tester.pumpAndSettle();
      
      expect(find.text('Status Pesan Warga'), findsOneWidget);
      
      print('LOG: Selecting "Semua" in Filter Dropdown...');
      await tester.tap(find.byKey(const Key('dropdown_filter_status_pesan')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Semua').last);
      await tester.pumpAndSettle();

      print('LOG: Tapping Terapkan...');
      await tester.tap(find.byKey(const Key('filter_apply_button')));
      await tester.pumpAndSettle();
      
      expect(find.text('Status Pesan Warga'), findsNothing);
      print('LOG: Filter Tested with "Semua".');

      await tester.tap(find.byKey(const Key('pesan_warga_back_button')));
      await tester.pump(const Duration(seconds: 2));

      await performLogout(tester);
    });
  });
}
