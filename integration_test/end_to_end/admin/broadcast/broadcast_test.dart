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

  testWidgets('Admin Broadcast CRUD End-to-End Test', (WidgetTester tester) async {
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
        // Fallback for "Login" text button if key not found immediately
        if (tester.any(find.text('Login'))) {
             btnShowForm = find.text('Login').first;
        } else {
             fail('LOG ERROR: Could not find Login entry button!');
        }
      } else if (!tester.any(btnShowForm)) {
         btnShowForm = find.text('Login').first;
      }
      
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

    // --- NAVIGATE TO BROADCAST ---
    print('LOG: Opening Broadcast Menu...');
    final broadcastButton = find.byKey(const Key('daftar_broadcast_button'));
    
    await tester.scrollUntilVisible(
      broadcastButton,
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    
    await tester.tap(broadcastButton);
    await tester.pumpAndSettle(const Duration(seconds: 3)); // Wait for list to load

    expect(find.text('Broadcast'), findsOneWidget);
    print('LOG: SUCCESS - Broadcast Screen Open');

    // --- CREATE BROADCAST ---
    print('LOG: Creating New Broadcast...');
    final fab = find.byKey(const Key('add_broadcast_fab'));
    await tester.tap(fab);
    await tester.pump(const Duration(seconds: 2)); 

    expect(find.text('Buat Broadcast Baru'), findsOneWidget);

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String testTitle = 'Test Broadcast $timestamp';
    final String testContent = 'Ini adalah konten broadcast testing untuk $timestamp';

    final judulField = find.byKey(const Key('judul_broadcast_field'));
    final isiField = find.byKey(const Key('isi_broadcast_field'));
    final simpanButton = find.byKey(const Key('simpan_broadcast_button'));

    await tester.enterText(judulField, testTitle);
    await tester.enterText(isiField, testContent);
    await tester.pump(const Duration(milliseconds: 500));
    
    // Tap Simpan
    await tester.tap(simpanButton);
    await tester.pump(const Duration(seconds: 5)); // Wait for save and success dialog

    // Check for success dialog "Berhasil"
    expect(find.text('Berhasil'), findsOneWidget);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    print('LOG: SUCCESS - Broadcast Created');

    // --- VERIFY LIST ---
    print('LOG: Verifying List...');
    
    // Search for the created broadcast
    final searchField = find.byKey(const Key('broadcast_search_field')); 
    await tester.enterText(searchField, testTitle);
    await tester.pump(const Duration(seconds: 2)); // Wait for filter
    await tester.pumpAndSettle();

    // Find the item in the list (inside a Card), ignoring the text in the search field
    final broadcastItem = find.descendant(of: find.byType(Card), matching: find.text(testTitle));
    expect(broadcastItem, findsOneWidget);
    print('LOG: SUCCESS - Created Broadcast Found in List');

    // --- OPEN DETAIL & EDIT ---
    print('LOG: Opening Detail and Editing...');
    await tester.tap(broadcastItem);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Detail Broadcast'), findsOneWidget);
    
    // Tap More Actions
    await tester.tap(find.byKey(const Key('more_actions_button')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Tap Edit
    await tester.tap(find.byKey(const Key('edit_broadcast_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Edit Broadcast'), findsOneWidget);

    // Change Title
    final String editedTitle = '$testTitle Edited';
    await tester.enterText(find.byKey(const Key('edit_judul_broadcast_field')), editedTitle);
    await tester.pump(const Duration(milliseconds: 500));

    // Save Edit
    await tester.tap(find.byKey(const Key('simpan_edit_broadcast_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5)); // Wait for save

    // Expect success snackbar/return to detail
    expect(find.text(editedTitle), findsOneWidget); // Verify title in Detail Screen
    print('LOG: SUCCESS - Broadcast Edited');

    // --- DELETE BROADCAST ---
    print('LOG: Deleting Broadcast...');
    
    // Tap More Actions again
    await tester.tap(find.byKey(const Key('more_actions_button')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Tap Delete
    await tester.tap(find.byKey(const Key('delete_broadcast_button')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Confirm Delete
    await tester.tap(find.text('Hapus')); // Dialog button
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Should be back to list
    expect(find.text('Broadcast'), findsOneWidget);
    
    // Verify it is gone (by searching again)
    await tester.enterText(searchField, editedTitle);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Ensure it's not in the list (Card)
    expect(find.descendant(of: find.byType(Card), matching: find.text(editedTitle)), findsNothing);
    // Optionally check for empty state message if your app shows one
    // expect(find.text('Tidak ada Broadcast yang ditemukan.'), findsOneWidget);
    
    print('LOG: SUCCESS - Broadcast Deleted');

    print('LOG: ALL TESTS PASSED SUCCESSFULLY');
  });
}
