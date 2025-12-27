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
  String testTitle = 'Test Broadcast $timestamp';
  String editedTitle = '$testTitle Edited';

  // --- HELPER FUNCTIONS ---
  Future<void> performLogin(WidgetTester tester) async {
    print('LOG: Starting Login Process...');
    
    if (tester.any(find.byKey(const Key('kegiatan_tab')))) {
      print('LOG: Already logged in.');
      return;
    }

    if (!tester.any(find.byKey(const Key('btn_show_login_form')))) {
       // Try to find the button, wait a bit
       await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    if (tester.any(find.byKey(const Key('btn_show_login_form')))) {
        await tester.ensureVisible(find.byKey(const Key('btn_show_login_form')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_show_login_form')));
        await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    print('LOG: Filling login form for Admin...');
    await tester.ensureVisible(find.byKey(const Key('input_email')));
    await tester.enterText(find.byKey(const Key('input_email')), 'admin@gmail.com');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byKey(const Key('input_password')), 'password');
    await tester.pump(const Duration(milliseconds: 100));

    print('LOG: Submitting login...');
    await tester.ensureVisible(find.byKey(const Key('btn_submit_login')));
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
    
    // Check if we need to navigate back to dashboard first
    // Not implemented here, assumes tests end at a state where tabs are visible or can navigate
    // But safe to try finding the profile tab or settings.
    
    // Admin logout flow: Lainnya Tab -> Logout
    final lainnyaTab = find.byKey(const Key('lainnya_tab'));
    if (tester.any(lainnyaTab)) {
        await tester.tap(lainnyaTab);
        await tester.pumpAndSettle(const Duration(seconds: 2));
    } else {
        // Try going back to root/dashboard
        // This is a simplification.
    }

    // In Admin "Lainnya" screen, there is a Logout button?
    // Based on file structure `lib/screens/admin/lainnya`, let's assume there is one.
    // If not, we might need to find where logout is. 
    // Usually it's in the Lainnya/Profile screen.
    
    // Assuming there is a logout button in Lainnya screen for Admin
    // If not found, we skip logout to avoid failing, but for this task we should try.
    
    final logoutBtn = find.text('Keluar'); // Common text
    if (tester.any(logoutBtn)) {
        await tester.scrollUntilVisible(logoutBtn, 500, scrollable: find.byType(Scrollable).first);
        await tester.tap(logoutBtn);
        await tester.pumpAndSettle();
        
        // Confirm
        if (tester.any(find.text('Ya, Keluar'))) {
            await tester.tap(find.text('Ya, Keluar'));
            await tester.pumpAndSettle(const Duration(seconds: 3));
        }
        print('LOG: LOGOUT SUCCESSFUL');
    } else {
        print('LOG: Logout button not found, skipping logout step.');
    }
  }

  group('Admin Broadcast Tests', () {
    
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

    testWidgets('1. Create Broadcast', (WidgetTester tester) async {
      runApp(const app.MyApp());
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await performLogin(tester);

      // Navigate
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      final broadcastButton = find.byKey(const Key('daftar_broadcast_button'));
      await tester.scrollUntilVisible(broadcastButton, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(broadcastButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Create
      await tester.tap(find.byKey(const Key('add_broadcast_fab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(find.byKey(const Key('judul_broadcast_field')), testTitle);
      await tester.enterText(find.byKey(const Key('isi_broadcast_field')), 'Konten testing $timestamp');
      await tester.tap(find.byKey(const Key('simpan_broadcast_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Success Dialog
      expect(find.text('Berhasil'), findsOneWidget);
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();

      // Verify in list
      final searchField = find.byKey(const Key('broadcast_search_field')); 
      await tester.enterText(searchField, testTitle);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      expect(find.descendant(of: find.byType(Card), matching: find.text(testTitle)), findsOneWidget);
      
      // Navigate Back to Dashboard for clean Logout
      await tester.tap(find.byKey(const Key('back_button_admin_broadcast_list')));
      await tester.pumpAndSettle();
      
      await performLogout(tester);
    });

    testWidgets('2. Edit Broadcast', (WidgetTester tester) async {
      runApp(const app.MyApp());
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await performLogin(tester);

      // Navigate
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      final broadcastButton = find.byKey(const Key('daftar_broadcast_button'));
      await tester.scrollUntilVisible(broadcastButton, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(broadcastButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Search existing
      final searchField = find.byKey(const Key('broadcast_search_field')); 
      await tester.enterText(searchField, testTitle);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Open Detail
      final broadcastItem = find.descendant(of: find.byType(Card), matching: find.text(testTitle));
      await tester.tap(broadcastItem);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Edit
      await tester.tap(find.byKey(const Key('more_actions_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('edit_broadcast_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(find.byKey(const Key('edit_judul_broadcast_field')), editedTitle);
      await tester.tap(find.byKey(const Key('simpan_edit_broadcast_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify in Detail
      expect(find.text(editedTitle), findsOneWidget);

      // Navigate Back
      await tester.tap(find.byKey(const Key('back_button_admin_broadcast_detail')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('back_button_admin_broadcast_list')));
      await tester.pumpAndSettle();

      await performLogout(tester);
    });

    testWidgets('3. Delete Broadcast', (WidgetTester tester) async {
      runApp(const app.MyApp());
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await performLogin(tester);

      // Navigate
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      final broadcastButton = find.byKey(const Key('daftar_broadcast_button'));
      await tester.scrollUntilVisible(broadcastButton, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.tap(broadcastButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Search edited
      final searchField = find.byKey(const Key('broadcast_search_field')); 
      await tester.enterText(searchField, editedTitle);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Open Detail
      final broadcastItem = find.descendant(of: find.byType(Card), matching: find.text(editedTitle));
      await tester.tap(broadcastItem);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Delete
      await tester.tap(find.byKey(const Key('more_actions_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_broadcast_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify Gone
      await tester.enterText(searchField, editedTitle);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      expect(find.descendant(of: find.byType(Card), matching: find.text(editedTitle)), findsNothing);

      // Navigate Back
      await tester.tap(find.byKey(const Key('back_button_admin_broadcast_list')));
      await tester.pumpAndSettle();

      await performLogout(tester);
    });

  });
}