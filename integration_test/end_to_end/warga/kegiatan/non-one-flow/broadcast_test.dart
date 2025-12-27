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

  // --- HELPER FUNCTIONS ---
  Future<void> performLogin(WidgetTester tester) async {
    print('LOG: Starting Login Process...');
    
    // Check if already logged in (look for home unique widget)
    if (tester.any(find.byKey(const Key('kegiatan_tab')))) { 
      print('LOG: Already logged in.');
      return;
    }

    // Try to find login button
    if (tester.any(find.byKey(const Key('btn_show_login_form')))) {
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
    
    // Wait for dashboard
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
    
    // Navigate to Profil Tab
    final profilTab = find.byKey(const Key('profil_tab'));
    if (!tester.any(profilTab)) {
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new)); 
        await tester.pumpAndSettle();
    }
    
    await tester.tap(profilTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Scroll to Logout
    final logoutButton = find.text('Keluar');
    await tester.scrollUntilVisible(logoutButton, 500.0, scrollable: find.byType(Scrollable).first);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // Confirm Logout
    final confirmLogout = find.text('Ya, Keluar');
    await tester.tap(confirmLogout);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byKey(const Key('btn_show_login_form')), findsOneWidget);
    print('LOG: LOGOUT SUCCESSFUL');
  }

  group('Warga Broadcast Tests', () {
    
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

    testWidgets('1. Search Broadcast', (WidgetTester tester) async {
      runApp(const app.MyApp());
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await performLogin(tester);

      // --- ACTION ---
      print('LOG: Navigating to Kegiatan Menu...');
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('LOG: Opening Daftar Broadcast...');
      await tester.tap(find.byKey(const Key('warga_menu_daftar_broadcast')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('LOG: Searching for "Warga Hilang"...');
      await tester.enterText(find.byKey(const Key('warga_broadcast_search')), 'Warga Hilang');
      await tester.pump(const Duration(seconds: 2)); 
      await tester.pumpAndSettle();

      // Verify
      expect(find.descendant(of: find.byType(Card), matching: find.textContaining('Warga Hilang')).first, findsOneWidget);
      print('LOG: SUCCESS - Search Result Found');

      // Go back to dashboard before logout
      await tester.tap(find.byKey(const Key('back_button_broadcast_list')));
      await tester.pumpAndSettle();

      await performLogout(tester);
    });

    testWidgets('2. View Detail Broadcast', (WidgetTester tester) async {
      runApp(const app.MyApp());
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await performLogin(tester);

      // --- ACTION ---
      print('LOG: Navigating to Kegiatan Menu...');
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('LOG: Opening Daftar Broadcast...');
      await tester.tap(find.byKey(const Key('warga_menu_daftar_broadcast')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('LOG: Searching for "Warga Hilang"...');
      await tester.enterText(find.byKey(const Key('warga_broadcast_search')), 'Warga Hilang');
      await tester.pump(const Duration(seconds: 2)); 
      await tester.pumpAndSettle();

      print('LOG: Opening Detail...');
      final item = find.descendant(of: find.byType(Card), matching: find.textContaining('Warga Hilang')).first;
      await tester.tap(item);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify
      expect(find.text('Detail Broadcast'), findsOneWidget);
      expect(find.byKey(const Key('warga_broadcast_detail_title')), findsOneWidget);
      print('LOG: SUCCESS - Detail Opened');

      // Go back to List
      await tester.tap(find.byKey(const Key('back_button_broadcast_detail')));
      await tester.pumpAndSettle();
      
      // Go back to Menu
      await tester.tap(find.byKey(const Key('back_button_broadcast_list')));
      await tester.pumpAndSettle();

      await performLogout(tester);
    });

    testWidgets('3. Filter Broadcast', (WidgetTester tester) async {
      runApp(const app.MyApp());
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await performLogin(tester);

      print('LOG: Navigating to Kegiatan Menu...');
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('LOG: Opening Daftar Broadcast...');
      await tester.tap(find.byKey(const Key('warga_menu_daftar_broadcast')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      print('LOG: Opening Filter...');
      await tester.tap(find.byKey(const Key('warga_broadcast_filter_button')));
      await tester.pumpAndSettle();

      expect(find.text('Filter Broadcast'), findsOneWidget);

      print('LOG: Resetting Filter...');
      await tester.tap(find.byKey(const Key('filter_reset_button')));
      await tester.pumpAndSettle();

      expect(find.text('Filter Broadcast'), findsNothing);
      print('LOG: SUCCESS - Filter Tested');

      await tester.tap(find.byKey(const Key('back_button_broadcast_list')));
      await tester.pumpAndSettle();

      await performLogout(tester);
    });

  });
}
