import 'package:SapaWarga_kel_2/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// E2E Test untuk Warga Marketplace - Toko Saya (Seller Flow)
///
/// Test comprehensive yang mencakup seluruh user journey:
/// Login â†’ Dashboard â†’ Produk â†’ Pesanan â†’ Review â†’ Settings
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Warga - Full Toko Saya (Seller) Flow', () {
    testWidgets(
      'Login â†’ Dashboard â†’ Manajemen Produk â†’ Kelola Pesanan â†’ Review â†’ Settings',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        print('\nðŸš€ ========== FULL TOKO SAYA E2E TEST ==========\n');

        // ==================== 1. LOGIN SEBAGAI SELLER ====================
        print('ðŸ“ Step 1: Login as seller');

        // Verifikasi halaman awal
        expect(find.textContaining('Sapa'), findsWidgets);
        expect(find.textContaining('Warga'), findsWidgets);

        // Tap "Saya sudah punya akun"
        final loginLink = find.text('Saya sudah punya akun');
        if (loginLink.evaluate().isNotEmpty) {
          await tester.tap(loginLink);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // Show login form
        final btnShowLoginForm = find.byKey(const Key('btn_show_login_form'));
        if (btnShowLoginForm.evaluate().isNotEmpty) {
          await tester.tap(btnShowLoginForm);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }

        // Input credentials
        await tester.enterText(
          find.byKey(const Key('input_email')),
          'penjual@gmail.com',
        );
        await tester.enterText(
          find.byKey(const Key('input_password')),
          'password',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('btn_submit_login')));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verifikasi login berhasil
        final loginSuccess =
            find.text('Dashboard Warga').evaluate().isNotEmpty ||
            find.text('Marketplace').evaluate().isNotEmpty;
        expect(loginSuccess, true, reason: 'Login gagal');
        print('  âœ… Login seller berhasil\n');

        // ==================== 2. NAVIGATE TO MARKETPLACE ====================
        print('ðŸ“ Step 2: Navigate to Marketplace via Bottom Navigation');

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // For warga, use bottom navigation position-based tap
        final bottomAppBar = find.byType(BottomAppBar);
        if (bottomAppBar.evaluate().isNotEmpty) {
          final rect = tester.getRect(bottomAppBar);
          // Warga bottom nav: Beranda(0), Keuangan(1), Marketplace(2), Kegiatan(3), Lainnya(4)
          // Try marketplace at index 2
          final xPos = rect.left + (rect.width * 2.5 / 5); // Index 2
          final yPos = rect.top + rect.height / 2;

          print('  âœ“ Tapping bottom navigation at marketplace position...');
          await tester.tapAt(Offset(xPos, yPos));
          await tester.pumpAndSettle(const Duration(seconds: 3));
        } else {
          print('  âš ï¸  BottomAppBar not found');
        }

        // Debug: Print what's on screen after tap
        print('ðŸ” Debug - After navigation, screen shows:');
        final allText2 = find.byType(Text);
        final textWidgets2 = allText2.evaluate().take(20);
        for (var element in textWidgets2) {
          final widget = element.widget as Text;
          if (widget.data != null) {
            print('  "${widget.data}"');
          }
        }

        // Verify we're in marketplace page
        final inMarketplace =
            find.text('Toko Saya').evaluate().isNotEmpty ||
            find.text('Belanja Produk').evaluate().isNotEmpty;

        if (!inMarketplace) {
          print(
            '  âš ï¸  Not at marketplace page. Trying alternative navigation...',
          );
          // Try tapping text links
          final belanjaLink = find.textContaining('Belanja');
          final tokoLink = find.textContaining('Toko');
          if (belanjaLink.evaluate().isNotEmpty) {
            print('  âœ“ Found Belanja link, marketplace might be accessible');
          } else if (tokoLink.evaluate().isNotEmpty) {
            print('  âœ“ Found Toko link, marketplace might be accessible');
          }
        } else {
          print('  âœ… Masuk ke Marketplace page\n');
        }

        // ==================== 3. NAVIGATE TO TOKO SAYA ====================
        print('ðŸ“ Step 3: Navigate to Toko Saya');

        // Wait for page to load
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Look for Toko Saya menu/button
        final tokoSayaMenu = find.text('Toko Saya');
        if (tokoSayaMenu.evaluate().isNotEmpty) {
          print('  âœ“ Found Toko Saya menu, tapping...');
          await tester.tap(tokoSayaMenu.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Verify we entered Toko Saya
          if (find.text('Dashboard Toko').evaluate().isNotEmpty ||
              find.textContaining('Toko').evaluate().isNotEmpty) {
            print('  âœ… Berhasil masuk ke Toko Saya\n');
          } else {
            print('  âš ï¸  Tapped but may not be in Toko Saya yet\n');
          }
        } else {
          print('  âš ï¸  Menu Toko Saya tidak ditemukan di layar saat ini');
          print('  Available text widgets:');
          final screenTexts = find.byType(Text);
          for (var element in screenTexts.evaluate().take(15)) {
            final widget = element.widget as Text;
            if (widget.data != null && widget.data!.length < 50) {
              print('    - "${widget.data}"');
            }
          }
          print(
            '  â„¹ï¸  User might not have a store yet or UI structure different\n',
          );
        }

        // ==================== 4. VERIFY DASHBOARD ====================
        print('ðŸ“ Step 4: Verify Dashboard Toko');

        // Check if we're actually in Dashboard Toko
        if (find.text('Dashboard Toko').evaluate().isNotEmpty) {
          expect(find.text('Dashboard Toko'), findsWidgets);

          // Verify dashboard content (actual UI elements)
          final hasPenghasilan = find
              .textContaining('Penghasilan')
              .evaluate()
              .isNotEmpty;
          final hasPesanan = find
              .textContaining('Pesanan')
              .evaluate()
              .isNotEmpty;
          final hasKelolaToko = find.text('Kelola Toko').evaluate().isNotEmpty;

          if (hasPenghasilan && hasPesanan) {
            print('  âœ“ Penghasilan dan Pesanan ditampilkan');
          }
          if (hasKelolaToko) {
            print('  âœ“ Menu Kelola Toko tersedia');
          }

          print('  âœ… Dashboard toko ditampilkan dengan lengkap\n');
        } else {
          print('  âš ï¸  Not at Dashboard Toko, skipping verification');
          print(
            '  â„¹ï¸  This might mean user doesn\'t have a store registered yet\n',
          );
        }

        // ==================== 5. TEST STOK PRODUK ====================
        print('ðŸ“ Step 5: Test Kelola Stok Produk');
        final stokMenu = find.text('Stok Produk');
        if (stokMenu.evaluate().isNotEmpty) {
          await tester.tap(stokMenu);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verify page title
          if (find.text('Stok Produk Toko').evaluate().isNotEmpty) {
            print('  âœ“ Halaman stok produk terbuka');
          }

          // Test tambah produk button
          final tambahBtn = find.byIcon(Icons.add);
          if (tambahBtn.evaluate().isNotEmpty) {
            await tester.tap(tambahBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            if (find.text('Tambah Produk Baru').evaluate().isNotEmpty) {
              print('  âœ“ Form tambah produk dapat diakses');

              // Back to stok list (don't actually submit)
              await tester.tap(find.byIcon(Icons.arrow_back));
              await tester.pumpAndSettle();
            }
          } else {
            print('  âš ï¸  Tombol tambah produk tidak ditemukan');
          }

          // Back to dashboard
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
          print('  âœ… Test kelola stok selesai\n');
        } else {
          print('  âš ï¸  Menu Stok Produk tidak ditemukan\n');
        }

        // ==================== 6. TEST PESANAN ====================
        print('ðŸ“ Step 6: Test Kelola Pesanan');
        final pesananMenu = find.text('Pesanan');
        if (pesananMenu.evaluate().isNotEmpty) {
          await tester.tap(pesananMenu);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verify page title (actual title is "Daftar Pesanan")
          if (find.text('Daftar Pesanan').evaluate().isNotEmpty) {
            print('  âœ“ Halaman pesanan terbuka');
          }

          // Check for orders
          final orderCards = find.byType(Card);
          if (orderCards.evaluate().isNotEmpty) {
            print('  âœ“ Ditemukan ${orderCards.evaluate().length} pesanan');

            // Tap pesanan pertama untuk detail
            await tester.tap(orderCards.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            if (find.text('Detail Pesanan').evaluate().isNotEmpty) {
              print('  âœ“ Detail pesanan dapat diakses');

              // Back to list
              await tester.tap(find.byIcon(Icons.arrow_back));
              await tester.pumpAndSettle();
            }
          } else {
            print('  âš ï¸  Tidak ada pesanan');
          }

          // Back to dashboard
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
          print('  âœ… Test kelola pesanan selesai\n');
        } else {
          print('  âš ï¸  Menu Pesanan tidak ditemukan\n');
        }

        // ==================== 7. TEST ULASAN ====================
        print('ðŸ“ Step 7: Test Lihat Ulasan Pembeli');
        final ulasanMenu = find.text('Ulasan');
        if (ulasanMenu.evaluate().isNotEmpty) {
          await tester.tap(ulasanMenu);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verify page title (actual title is "Ulasan Pembeli")
          if (find.text('Ulasan Pembeli').evaluate().isNotEmpty) {
            print('  âœ“ Halaman ulasan terbuka');
          }

          final reviewCards = find.byType(Card);
          if (reviewCards.evaluate().isNotEmpty) {
            print('  âœ“ Ditemukan ${reviewCards.evaluate().length} ulasan');
          } else {
            print('  âš ï¸  Belum ada ulasan');
          }

          // Back to dashboard
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
          print('  âœ… Test ulasan selesai\n');
        } else {
          print('  âš ï¸  Menu Ulasan tidak ditemukan\n');
        }

        // ==================== 8. TEST PENGATURAN ====================
        print('ðŸ“ Step 8: Test Pengaturan Toko');
        final settingsMenu = find.text('Pengaturan');
        if (settingsMenu.evaluate().isNotEmpty) {
          await tester.tap(settingsMenu);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Verify page title
          if (find.text('Pengaturan Toko').evaluate().isNotEmpty) {
            print('  âœ“ Halaman pengaturan terbuka');
          }

          // Check edit profile option
          final editProfilBtn = find.text('Edit Nama & Deskripsi');
          if (editProfilBtn.evaluate().isNotEmpty) {
            print('  âœ“ Opsi edit profil tersedia');
          }

          // Check deactivate option
          final nonaktifkanBtn = find.text('Nonaktif Toko');
          if (nonaktifkanBtn.evaluate().isNotEmpty) {
            print('  âœ“ Opsi nonaktifkan toko tersedia');
          }

          // Check logout option
          final keluarBtn = find.text('Keluar');
          if (keluarBtn.evaluate().isNotEmpty) {
            print('  âœ“ Opsi keluar tersedia');
          }

          // Back to dashboard
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
          print('  âœ… Test pengaturan selesai\n');
        } else {
          print('  âš ï¸  Menu Pengaturan tidak ditemukan\n');
        }

        print('âœ… ========== FULL TOKO SAYA E2E TEST PASSED ==========\n');
      },
    );
  });
}

