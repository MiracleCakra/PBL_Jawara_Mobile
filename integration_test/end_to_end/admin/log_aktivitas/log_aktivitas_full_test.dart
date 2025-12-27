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
       await tester.pumpAndSettle(const Duration(seconds: 2));
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
    final logoutBtn = find.text('Keluar');
    if (tester.any(logoutBtn)) {
        await tester.scrollUntilVisible(logoutBtn, 500, scrollable: find.byType(Scrollable).first);
        await tester.tap(logoutBtn);
        await tester.pumpAndSettle();
        if (tester.any(find.text('Ya, Keluar'))) {
            await tester.tap(find.text('Ya, Keluar'));
            await tester.pumpAndSettle(const Duration(seconds: 3));
        }
    }
  }

  testWidgets('Admin Log Aktivitas Full Single Flow Test', (WidgetTester tester) async {
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
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await performLogin(tester);

    await tester.tap(find.byKey(const Key('kegiatan_tab')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final logButton = find.byKey(const Key('log_aktivitas_button'));
    await tester.scrollUntilVisible(logButton, 500.0, scrollable: find.byType(Scrollable).first);
    await tester.tap(logButton);
    await tester.pump(const Duration(seconds: 5)); // Stream load

    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Log Aktivitas')), findsOneWidget);

    // --- SEARCH ---
    final searchField = find.byKey(const Key('log_search_field'));
    await tester.enterText(searchField, 'Test Search');
    await tester.pump(const Duration(milliseconds: 800)); 
    await tester.pumpAndSettle();
    print('LOG: Search Performed');

    // --- FILTER ---
    final filterButton = find.byKey(const Key('log_filter_button'));
    await tester.tap(filterButton);
    await tester.pumpAndSettle();
    
    expect(find.text('Filter Log Aktivitas'), findsOneWidget);
    
    final resetButton = find.byKey(const Key('filter_reset_button'));
    await tester.tap(resetButton);
    await tester.pumpAndSettle();
    
    expect(find.text('Filter Log Aktivitas'), findsNothing);

    // Back to Menu
    await tester.tap(find.byKey(const Key('log_back_button')));
    await tester.pumpAndSettle();

    await performLogout(tester);
  });
}
