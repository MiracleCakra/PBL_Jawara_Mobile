import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:SapaWarga_kel_2/main.dart' as app;

void main() {
  // 1. Inisialisasi Driver E2E
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E Scenario: Full Login Flow', (WidgetTester tester) async {
    // ----------------------------------------------------------------
    // STEP 1: Jalankan Aplikasi
    // ----------------------------------------------------------------
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verifikasi Halaman Awal (UI sudah berubah dari "Jawara Pintar" jadi "Sapa Warga")
    expect(find.textContaining('Sapa'), findsWidgets);
    expect(find.textContaining('Warga'), findsWidgets);

    // menggunakan KEY yang sudah ditambahkan di login.dart
    final btnShowForm = find.byKey(const Key('btn_show_login_form'));
    final btnDaftar = find.byKey(const Key('btn_to_register'));

    expect(btnShowForm, findsOneWidget);
    expect(btnDaftar, findsOneWidget);

    // ----------------------------------------------------------------
    // STEP 2: Buka Form Login
    // ----------------------------------------------------------------
    print('Action: Mengetuk tombol buka form login...');
    await tester.tap(btnShowForm);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Cari elemen-elemen di dalam form menggunakan KEY
    final emailField = find.byKey(const Key('input_email'));
    final passwordField = find.byKey(const Key('input_password'));
    final submitButton = find.byKey(const Key('btn_submit_login'));

    // Verifikasi elemen form muncul
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(submitButton, findsOneWidget);

    // ----------------------------------------------------------------
    // STEP 3: Coba Login Kosong (Validasi Error)
    // ----------------------------------------------------------------
    print('Action: Submit login kosong...');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Verifikasi pesan error muncul
    expect(find.text('Email & Password tidak boleh kosong'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ----------------------------------------------------------------
    // STEP 4: Input Kredensial
    // ----------------------------------------------------------------
    print('Action: Mengisi email dan password...');

    // Isi Email
    await tester.enterText(emailField, 'admin@gmail.com');
    await tester.pump(const Duration(milliseconds: 100));

    // Isi Password
    await tester.enterText(passwordField, 'password');
    await tester.pump(const Duration(milliseconds: 100));

    // ----------------------------------------------------------------
    // STEP 5: Submit Login Sukses
    // ----------------------------------------------------------------
    print('Action: Submit login valid...');
    await tester.tap(submitButton);

    await tester.pumpAndSettle(const Duration(seconds: 4));

    // ----------------------------------------------------------------
    // STEP 6: Verifikasi Navigasi Berhasil
    // ----------------------------------------------------------------
    // Verifikasi sudah di halaman Home
    // memastikan tombol login tadi SUDAH TIDAK ADA lagi di layar.
    expect(submitButton, findsNothing);

    print('E2E Test Selesai: Login Berhasil!');
  });
}
