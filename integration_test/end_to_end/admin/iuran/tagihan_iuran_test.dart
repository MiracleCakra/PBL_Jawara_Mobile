import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:SapaWarga_kel_2/main.dart' as app;
import 'package:SapaWarga_kel_2/models/keuangan/iuran_model.dart';
import 'package:SapaWarga_kel_2/router.dart' as app_router;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> goToTagihanIuranScreen(WidgetTester tester) async {
    app_router.router.go('/admin/pemasukan/tagih-iuran');
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  Future<void> ensureLoggedIn(WidgetTester tester) async {
    // Force to login screen, then login only if form visible.
    app_router.router.go('/login');
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final btnShowForm = find.byKey(const Key('btn_show_login_form'));
    if (btnShowForm.evaluate().isNotEmpty) {
      final emailField = find.byKey(const Key('input_email'));
      final passwordField = find.byKey(const Key('input_password'));
      final submitButton = find.byKey(const Key('btn_submit_login'));

      await tester.tap(btnShowForm);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.enterText(emailField, 'admin@gmail.com');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(passwordField, 'password');
      await tester.pump(const Duration(milliseconds: 50));

      debugPrint('Action: login as admin');
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 4));
    } else {
      // If already logged in, make sure Supabase session exists.
      debugPrint('Info: login form not found, assuming already logged in');
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        debugPrint('Warning: no session, forcing sign out then retry login');
        await Supabase.instance.client.auth.signOut();
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await ensureLoggedIn(tester);
      }
    }
  }

  testWidgets('E2E Test: Tagihan Iuran', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await ensureLoggedIn(tester);

    await goToTagihanIuranScreen(tester);
    debugPrint('Action: go to tagihan iuran screen');

    await tester.pumpAndSettle(const Duration(seconds: 5));

    // --- Dropdown: pilih item pertama ---
    final dropdown = find.byWidgetPredicate(
      (w) => w is DropdownButtonFormField<IuranOption>,
    );
    expect(dropdown, findsOneWidget);

    await tester.tap(dropdown);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    debugPrint('Action: select iuran type');

    final items = find.byType(DropdownMenuItem<IuranOption>);
    expect(items, findsWidgets);

    final firstItem = items.first;
    await tester.ensureVisible(firstItem);
    await tester.tap(firstItem);
    await tester.pumpAndSettle();
    debugPrint('Action: select first iuran option');

    // --- Date picker: InkWell yang punya icon kalender ---
    final dateInkWell = find.ancestor(
      of: find.byIcon(Icons.calendar_today_outlined),
      matching: find.byType(InkWell),
    );
    expect(dateInkWell, findsOneWidget);

    await tester.tap(dateInkWell);
    await tester.pumpAndSettle();
    debugPrint('Action: select date');

    // Konfirmasi date picker (tanpa ganti tanggal pun oke)
    final confirmButtons = [
      find.text('OK'),
      find.text('Simpan'),
      find.text('Done'),
    ];

    Finder? confirm;
    for (final f in confirmButtons) {
      if (f.evaluate().isNotEmpty) {
        confirm = f;
        break;
      }
    }
    if (confirm != null) {
      await tester.tap(confirm);
      await tester.pumpAndSettle();
    }

    // --- Tap tombol Tagih Iuran (JANGAN .at(1)) ---
    final tagihButton = find.widgetWithText(ElevatedButton, 'Tagih Iuran');
    expect(tagihButton, findsOneWidget);

    await tester.tap(tagihButton);
    await tester.pumpAndSettle();
    debugPrint('Action: tap tagih button');

    expect(
      find.text('Iuran berhasil ditagihkan untuk Semua Keluarga'),
      findsOneWidget,
    );
  });
}
