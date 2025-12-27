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
  String testTitle = 'Full Flow Broadcast $timestamp';
  String editedTitle = '$testTitle Edited';

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

  testWidgets('Admin Broadcast Full Single Flow Test', (WidgetTester tester) async {
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

    // --- CREATE ---
    await tester.tap(find.byKey(const Key('kegiatan_tab')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final broadcastButton = find.byKey(const Key('daftar_broadcast_button'));
    await tester.scrollUntilVisible(broadcastButton, 500.0, scrollable: find.byType(Scrollable).first);
    await tester.tap(broadcastButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.byKey(const Key('add_broadcast_fab')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.enterText(find.byKey(const Key('judul_broadcast_field')), testTitle);
    await tester.enterText(find.byKey(const Key('isi_broadcast_field')), 'Konten full flow testing $timestamp');
    await tester.tap(find.byKey(const Key('simpan_broadcast_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Berhasil'), findsOneWidget);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    final searchField = find.byKey(const Key('broadcast_search_field')); 
    await tester.enterText(searchField, testTitle);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(Card), matching: find.text(testTitle)), findsOneWidget);

    // --- EDIT ---
    final broadcastItem = find.descendant(of: find.byType(Card), matching: find.text(testTitle));
    await tester.tap(broadcastItem);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byKey(const Key('more_actions_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit_broadcast_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.enterText(find.byKey(const Key('edit_judul_broadcast_field')), editedTitle);
    await tester.tap(find.byKey(const Key('simpan_edit_broadcast_button')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text(editedTitle), findsOneWidget);

    // --- DELETE ---
    await tester.tap(find.byKey(const Key('more_actions_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete_broadcast_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.enterText(searchField, editedTitle);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(Card), matching: find.text(editedTitle)), findsNothing);

    // Back to Menu
    await tester.tap(find.byKey(const Key('back_button_admin_broadcast_list')));
    await tester.pumpAndSettle();

    await performLogout(tester);
  });
}
