import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:SapaWarga_kel_2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Admin Kegiatan E2E Test', () {
    testWidgets('Admin can create, view, edit, and delete a kegiatan', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check if already logged in
      if (tester.any(find.byKey(const Key('kegiatan_tab')))) {
        return;
      }

      // Step 2: Find and tap the button to show the login form.
      final btnShowForm = find.byKey(const Key('btn_show_login_form'));
      expect(btnShowForm, findsOneWidget);
      await tester.tap(btnShowForm);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Step 3: Find the form fields.
      final emailField = find.byKey(const Key('input_email'));
      final passwordField = find.byKey(const Key('input_password'));
      final submitButton = find.byKey(const Key('btn_submit_login'));

      // Verify form elements are visible
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(submitButton, findsOneWidget);

      // Step 4: Enter credentials.
      await tester.enterText(emailField, 'admin@gmail.com');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(passwordField, 'password');
      await tester.pump(const Duration(milliseconds: 100));

      // Step 5: Tap the submit button and wait for navigation.
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify that the login button is no longer on the screen,
      // indicating a successful navigation.
      expect(submitButton, findsNothing);
      
      // --- PART 1: CREATE KEGIATAN ---
      await tester.ensureVisible(find.byKey(const Key('kegiatan_tab')));
      await tester.tap(find.byKey(const Key('kegiatan_tab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.ensureVisible(find.byKey(const Key('daftar_kegiatan_button')));
      await tester.tap(find.byKey(const Key('daftar_kegiatan_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.ensureVisible(find.byKey(const Key('add_kegiatan_fab')));
      await tester.tap(find.byKey(const Key('add_kegiatan_fab')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Fill form
      final namaKegiatan =
          'Kerja Bakti Tes E2E ${DateTime.now().millisecondsSinceEpoch}';
      final deskripsiKegiatan = 'Membersihkan lingkungan sekitar RT.';

      await tester.ensureVisible(find.byKey(const Key('nama_kegiatan_field')));
      await tester.enterText(
          find.byKey(const Key('nama_kegiatan_field')), namaKegiatan);

      // Select Kategori
      await tester.ensureVisible(find.byKey(const Key('kategori_kegiatan_dropdown')));
      await tester.tap(find.byKey(const Key('kategori_kegiatan_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kebersihan dan Keamanan').last);
      await tester.pumpAndSettle();

      // Select Tanggal
      await tester.ensureVisible(find.byKey(const Key('tanggal_kegiatan_field')));
      await tester.tap(find.byKey(const Key('tanggal_kegiatan_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('lokasi_kegiatan_field')));
      await tester.enterText(find.byKey(const Key('lokasi_kegiatan_field')), 'Sekitar RT 01');

      await tester.ensureVisible(find.byKey(const Key('pj_kegiatan_field')));
      await tester.enterText(
          find.byKey(const Key('pj_kegiatan_field')), 'Admin Test');

      await tester
          .ensureVisible(find.byKey(const Key('deskripsi_kegiatan_field')));
      await tester.enterText(
          find.byKey(const Key('deskripsi_kegiatan_field')), deskripsiKegiatan);

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('upload_dokumentasi')));
      await tester.tap(find.byKey(const Key('upload_dokumentasi')));
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Save
      await tester
          .ensureVisible(find.byKey(const Key('simpan_kegiatan_button')));
      await tester.tap(find.byKey(const Key('simpan_kegiatan_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Handle success dialog
      await tester.ensureVisible(find.byKey(const Key('selesai_button')));
      await tester.tap(find.byKey(const Key('selesai_button')));
      await tester.pump(const Duration(seconds: 5));

      // Verify
      await tester.pump(const Duration(seconds: 10));
      expect(find.text(namaKegiatan), findsOneWidget);

      // --- PART 2: VIEW KEGIATAN DETAIL ---
      await tester.ensureVisible(find.text(namaKegiatan));
      await tester.tap(find.ancestor(
        of: find.text(namaKegiatan),
        matching: find.byType(GestureDetector),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Detail Kegiatan'), findsOneWidget);
      expect(find.byKey(const Key('detail_nama_kegiatan')), findsOneWidget);

      // --- PART 3: EDIT KEGIATAN ---
      await tester.ensureVisible(find.byKey(const Key('kegiatan_more_actions_button')));
      await tester.tap(find.byKey(const Key('kegiatan_more_actions_button')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('edit_kegiatan_button')));
      await tester.tap(find.byKey(const Key('edit_kegiatan_button')));
      await tester.pumpAndSettle();

      final editedNamaKegiatan =
          'Kerja Bakti (edited) ${DateTime.now().millisecondsSinceEpoch}';
      await tester
          .ensureVisible(find.byKey(const Key('edit_nama_kegiatan_field')));
      await tester.enterText(
          find.byKey(const Key('edit_nama_kegiatan_field')), editedNamaKegiatan);

      await tester
          .ensureVisible(find.byKey(const Key('simpan_edit_kegiatan_button')));
      await tester.tap(find.byKey(const Key('simpan_edit_kegiatan_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // After edit, it pops back to the list screen with a refresh flag
      await tester.ensureVisible(find.byKey(const Key('back_button')));
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();
      
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Kegiatan')), findsOneWidget);

      // --- PART 4: DELETE KEGIATAN ---
      await tester.ensureVisible(find.text(editedNamaKegiatan));
      await tester.tap(find.ancestor(
        of: find.text(editedNamaKegiatan),
        matching: find.byType(GestureDetector),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.ensureVisible(find.byKey(const Key('kegiatan_more_actions_button')));
      await tester.tap(find.byKey(const Key('kegiatan_more_actions_button')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('delete_kegiatan_button')));
      await tester.tap(find.byKey(const Key('delete_kegiatan_button')));
      await tester.pumpAndSettle();

      await tester
          .ensureVisible(find.byKey(const Key('confirm_delete_kegiatan_button')));
      await tester
          .tap(find.byKey(const Key('confirm_delete_kegiatan_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.descendant(of: find.byType(AppBar), matching: find.text('Kegiatan')), findsOneWidget);
      expect(find.text(editedNamaKegiatan), findsNothing);
    });
  });
}