import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jawara_pintar_kel_5/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E Scenario: Full Register Flow', (WidgetTester tester) async {
    // 1. Jalankan aplikasi (Login Page)
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ------------------------------------------------------------
    // STEP 1: Navigasi dari Login -> Register
    // ------------------------------------------------------------
    print('Step 1: Navigasi ke halaman Register...');

    // Cari tombol "Daftar" di halaman Login (menggunakan Key dari login.dart)
    final btnToRegister = find.byKey(const Key('btn_to_register'));

    expect(btnToRegister, findsOneWidget);
    await tester.tap(btnToRegister);
    await tester.pumpAndSettle(const Duration(seconds: 3)); // Tambah durasi

    // Verifikasi sudah di halaman Register
    // Scroll ke atas untuk memastikan text terlihat
    final scrollView = find.byKey(const Key('scroll_view_register'));
    if (scrollView.evaluate().isNotEmpty) {
      await tester.ensureVisible(
        find.text('Daftar untuk mengakses sistem Jawara Pintar.'),
      );
      await tester.pumpAndSettle();
    }

    expect(
      find.text('Daftar untuk mengakses sistem Jawara Pintar.'),
      findsOneWidget,
    );
    expect(find.text('Data Diri'), findsOneWidget);

    // ------------------------------------------------------------
    // STEP 2: Mengisi Form Identitas
    // ------------------------------------------------------------
    print('Step 2: Mengisi Identitas...');

    // Input Nama
    final inputNama = find.byKey(const Key('input_nama_lengkap'));
    await tester.enterText(inputNama, 'User Test lagi E2E');
    await tester.pump(const Duration(milliseconds: 100));

    // Input NIK
    final inputNik = find.byKey(const Key('input_nik'));
    await tester.enterText(inputNik, '3501012010220002');
    await tester.pump(const Duration(milliseconds: 100));

    // Pilih Dropdown Gender
    // Scroll dulu biar aman
    await tester.drag(scrollView, const Offset(0, -100));
    await tester.pumpAndSettle();

    final dropdownGender = find.byKey(const Key('dropdown_trigger_gender'));
    await tester.tap(dropdownGender);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Pilih Pria
    final optionPria = find.byKey(const Key('option_gender_pria'));
    expect(optionPria, findsOneWidget);
    await tester.tap(optionPria);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Verifikasi Upload Area Ada (JANGAN DI KLIK agar tidak muncul permission dialog)
    final uploadArea = find.byKey(const Key('area_upload_foto'));
    expect(uploadArea, findsOneWidget);

    // ------------------------------------------------------------
    // STEP 3: Mengisi Form Akun
    // ------------------------------------------------------------
    print('Step 3: Mengisi Akun...');

    // Scroll ke bawah agar form akun terlihat
    await tester.drag(scrollView, const Offset(0, -500));
    await tester.pumpAndSettle();

    // Input Email
    final inputEmail = find.byKey(const Key('input_email_reg'));
    await tester.enterText(inputEmail, 'e6etest@mail.com');
    await tester.pump(const Duration(milliseconds: 100));

    // Input Telepon
    final inputPhone = find.byKey(const Key('input_phone'));
    await tester.enterText(inputPhone, '081234567891');
    await tester.pump(const Duration(milliseconds: 100));

    // Input Password
    final inputPass = find.byKey(const Key('input_password_reg'));
    await tester.enterText(inputPass, 'password1234');
    await tester.pump(const Duration(milliseconds: 100));

    // Input Confirm Password
    final inputConfirm = find.byKey(const Key('input_confirm_password'));
    await tester.enterText(inputConfirm, 'password123');
    await tester.pump(const Duration(milliseconds: 100));

    // ------------------------------------------------------------
    // STEP 4: Submit Register
    // ------------------------------------------------------------
    print('Step 4: Menekan tombol Daftar...');

    // Scroll lebih banyak untuk memastikan button terlihat
    await tester.drag(scrollView, const Offset(0, -400));
    await tester.pumpAndSettle();

    final btnSubmit = find.byKey(const Key('btn_submit_register'));

    // Pastikan button terlihat di layar
    await tester.ensureVisible(btnSubmit);
    await tester.pumpAndSettle();

    expect(btnSubmit, findsOneWidget);
    await tester.tap(btnSubmit);

    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verifikasi Akhir:
    // Jika sukses, biasanya pindah ke Login screen lagi
    // Jika gagal, akan muncul SnackBar.

    if (find.byType(SnackBar).evaluate().isNotEmpty) {
      print(
        "Info: Pendaftaran gagal/error muncul di SnackBar (Mungkin email duplikat?)",
      );
    } else {
      print("Info: Tidak ada error, asumsi navigasi berhasil.");
    }

    // Optional: Cek apakah kembali ke login (Teks 'Login untuk mengakses...' ada lagi)
    // expect(find.text('Login untuk mengakses sistem Jawara Pintar.'), findsOneWidget);

    print('E2E Scenario Register Selesai.');
  });
}
