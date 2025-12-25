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

  testWidgets('Warga Kegiatan End-to-End Test', (WidgetTester tester) async {
    // --- SETUP ---
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

    // --- LOGIN AS WARGA ---
    print('LOG: Starting Login Process...');
    
    if (tester.any(find.text('Hai, Warga'))) { 
      print('LOG: Already logged in.');
    } else {
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

      if (!tester.any(btnShowForm)) btnShowForm = find.text('Login').first;
      
      await tester.tap(btnShowForm);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      print('LOG: Filling login form for Warga...');
      final emailField = find.byKey(const Key('input_email'));
      final passwordField = find.byKey(const Key('input_password'));
      final submitButton = find.byKey(const Key('btn_submit_login'));

      await tester.enterText(emailField, 'warga1@gmail.com');
      await tester.pump(const Duration(milliseconds: 100));
      
      await tester.enterText(passwordField, 'password');
      await tester.pump(const Duration(milliseconds: 100));

      print('LOG: Submitting login...');
      await tester.tap(submitButton);
      
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

    // --- NAVIGATE TO KEGIATAN MENU ---
    print('LOG: Navigating to Kegiatan Menu...');
    final kegiatanMenuButton = find.byKey(const Key('kegiatan_tab'));
    await tester.tap(kegiatanMenuButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Kegiatan Warga'), findsOneWidget);

    // ========================================================================
    // SCENARIO: KEGIATAN (Lomba)
    // ========================================================================
    print('LOG: Starting Kegiatan Test (Search "Lomba")...');
    
    final daftarKegiatanBtn = find.byKey(const Key('warga_menu_daftar_kegiatan'));
    await tester.tap(daftarKegiatanBtn);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify Title
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Kegiatan')), findsOneWidget);

    // Search
    final kegiatanSearch = find.byKey(const Key('warga_kegiatan_search'));
    await tester.enterText(kegiatanSearch, 'Lomba');
    await tester.pump(const Duration(seconds: 2)); 
    await tester.pumpAndSettle();

    // Find Item
    final lombaItem = find.descendant(of: find.byType(Card), matching: find.textContaining('Lomba')).first;
    expect(lombaItem, findsOneWidget);
    
    print('LOG: Found Kegiatan "Lomba". Opening Detail...');
    await tester.tap(lombaItem);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify Detail
    expect(find.text('Detail Kegiatan'), findsOneWidget);
    
    final detailTitle = find.byKey(const Key('warga_kegiatan_detail_title'));
    expect(detailTitle, findsOneWidget);
    
    // Go Back
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    
    print('LOG: WARGA KEGIATAN TEST PASSED SUCCESSFULLY');
  });
}
