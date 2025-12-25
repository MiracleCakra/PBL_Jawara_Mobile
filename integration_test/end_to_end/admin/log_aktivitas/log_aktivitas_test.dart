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

  testWidgets('Admin Log Aktivitas End-to-End Test', (WidgetTester tester) async {
    // Manual Initialization (Copied from aspirasi_crud_test.dart)
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

    // Initial Wait
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // --- LOGIN AS ADMIN ---
    print('LOG: Starting Login Process...');
    
    if (tester.any(find.byKey(const Key('kegiatan_tab')))) {
      print('LOG: Already logged in.');
    } else {
      // Step 1: Tap "Login" to show form
      print('LOG: Looking for show login form button...');
      
      Finder btnShowForm = find.byKey(const Key('btn_show_login_form'));
      bool found = false;
      for (int i = 0; i < 30; i++) {
        if (tester.any(btnShowForm) || tester.any(find.text('Login'))) { 
          found = true; 
          break; 
        }
        await tester.pump(const Duration(seconds: 1));
      }

      if (!found) {
        print('LOG ERROR: Could not find Login entry button!');
        // Dump widgets for debugging if needed
      }

      if (!tester.any(btnShowForm)) btnShowForm = find.text('Login').first;
      
      await tester.tap(btnShowForm);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 2: Fill form
      print('LOG: Filling login form...');
      final emailField = find.byKey(const Key('input_email'));
      final passwordField = find.byKey(const Key('input_password'));
      final submitButton = find.byKey(const Key('btn_submit_login'));

      await tester.enterText(emailField, 'admin@gmail.com');
      await tester.pump(const Duration(milliseconds: 100));
      
      await tester.enterText(passwordField, 'password');
      await tester.pump(const Duration(milliseconds: 100));

      // Step 3: Submit
      print('LOG: Submitting login...');
      await tester.tap(submitButton);
      
      // Wait for dashboard
      bool atDashboard = false;
      for (int i = 0; i < 30; i++) {
        if (tester.any(find.byKey(const Key('kegiatan_tab')))) {
          atDashboard = true;
          break;
        }
        await tester.pump(const Duration(seconds: 1));
      }
      expect(atDashboard, true, reason: 'Failed to reach dashboard after login');
    }

    // --- NAVIGATE TO KEGIATAN TAB ---
    print('LOG: Navigating to Kegiatan Tab...');
    final kegiatanTab = find.byKey(const Key('kegiatan_tab'));
    await tester.tap(kegiatanTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // --- NAVIGATE TO LOG AKTIVITAS ---
    print('LOG: Opening Log Aktivitas...');
    final logButton = find.byKey(const Key('log_aktivitas_button'));
    
    await tester.scrollUntilVisible(
      logButton,
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    
    await tester.tap(logButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // --- VERIFY SCREEN ---
    expect(find.descendant(
      of: find.byType(AppBar),
      matching: find.text('Log Aktivitas'),
    ), findsOneWidget);
    print('LOG: SUCCESS - Log Aktivitas Screen Open');

    // --- TEST SEARCH ---
    final searchField = find.byKey(const Key('log_search_field'));
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Test Search');
    await tester.pump(const Duration(milliseconds: 800)); 
    await tester.pumpAndSettle();
    print('LOG: SUCCESS - Search Performed');

    // --- TEST FILTER ---
    final filterButton = find.byKey(const Key('log_filter_button'));
    await tester.tap(filterButton);
    await tester.pumpAndSettle();
    
    expect(find.text('Filter Log Aktivitas'), findsOneWidget);
    print('LOG: SUCCESS - Filter Modal Opened');
    
    final resetButton = find.byKey(const Key('filter_reset_button'));
    await tester.tap(resetButton);
    await tester.pumpAndSettle();
    
    expect(find.text('Filter Log Aktivitas'), findsNothing);
    print('LOG: SUCCESS - Filter Modal Closed');
    
    print('LOG: ALL TESTS PASSED SUCCESSFULLY');
  });
}
