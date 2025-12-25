import 'package:SapaWarga_kel_2/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// E2E Test untuk Admin Marketplace
///
/// Test comprehensive yang mencakup seluruh admin workflow:
/// Login â†’ Dashboard â†’ Validasi Toko â†’ Validasi Produk â†’ Search & Filter â†’ Manajemen
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin - Full Marketplace Management Flow', () {
    testWidgets(
      'Login â†’ Dashboard â†’ Validasi Toko â†’ Validasi Produk â†’ Search & Manajemen',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        print('\nðŸš€ ========== FULL ADMIN MARKETPLACE E2E TEST ==========\n');

        // ==================== 1. LOGIN SEBAGAI ADMIN ====================
        print('ðŸ“ Step 1: Login sebagai admin');

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
          'admin@gmail.com',
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
            find.text('Dashboard Admin').evaluate().isNotEmpty ||
            find.text('Marketplace').evaluate().isNotEmpty;
        expect(loginSuccess, true, reason: 'Login gagal');
        print('  âœ… Login admin berhasil\n');

        // ==================== 2. NAVIGATE TO MARKETPLACE ====================
        print('ðŸ“ Step 2: Navigate ke Marketplace Admin');

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Tap bottom navigation (position-based)
        final bottomAppBar = find.byType(BottomAppBar);
        if (bottomAppBar.evaluate().isNotEmpty) {
          final rect = tester.getRect(bottomAppBar);
          final xPos = rect.left + (rect.width * 2.5 / 5); // Index 2
          final yPos = rect.top + rect.height / 2;

          await tester.tapAt(Offset(xPos, yPos));
        } else {
          await tester.tap(find.text('Marketplace'));
        }

        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Verifikasi masuk ke marketplace
        final inMarketplace =
            find.text('Dashboard Marketplace').evaluate().isNotEmpty ||
            find.text('Validasi Akun Toko').evaluate().isNotEmpty;
        expect(inMarketplace, true, reason: 'Gagal masuk ke Marketplace');
        print('  âœ… Masuk ke Marketplace Admin\n');

        // ==================== 3. VERIFY DASHBOARD & STATISTICS ====================
        print('ðŸ“ Step 3: Verify Dashboard & Statistics');

        expect(find.text('Dashboard Marketplace'), findsOneWidget);
        print('  âœ“ Dashboard title found');

        // Verify menu buttons
        expect(find.text('Validasi Akun Toko'), findsWidgets);
        expect(find.text('Validasi Produk'), findsWidgets);
        print('  âœ“ Menu validasi tersedia');

        // Check statistics cards
        if (find.byIcon(Icons.store_mall_directory).evaluate().isNotEmpty) {
          print('  âœ“ Statistics cards ditampilkan');
        }

        // Check year filter if available
        final yearDropdown = find.byType(DropdownButton<int>);
        if (yearDropdown.evaluate().isNotEmpty) {
          print('  âœ“ Filter periode tersedia');
        }

        print('  âœ… Dashboard verified\n');

        // ==================== 4. TEST VALIDASI AKUN TOKO ====================
        print('ðŸ“ Step 4: Test Validasi Akun Toko');

        // Tap quick button "Validasi Akun Toko"
        final validasiTokoTexts = find.text('Validasi Akun Toko');
        if (validasiTokoTexts.evaluate().length >= 2) {
          await tester.tap(validasiTokoTexts.at(1)); // Menu button
        } else {
          await tester.tap(validasiTokoTexts.first);
        }
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 4)); // Wait for provider
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('Validasi Akun Toko Warga'), findsOneWidget);
        print('  âœ“ Masuk ke halaman Validasi Akun Toko');

        // Test search functionality
        final searchField = find.byType(TextField);
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField.first, 'Toko');
          await tester.pumpAndSettle(const Duration(seconds: 2));
          print('  âœ“ Search functionality tested');
        }

        // Check pending stores
        final pendingChip = find.text('Pending');
        if (pendingChip.evaluate().isNotEmpty) {
          print('  âœ“ Found pending stores for validation');

          // Tap first store
          await tester.tap(find.byType(Card).first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(find.text('Detail Validasi Toko'), findsOneWidget);
          print('  âœ“ Detail toko dapat diakses');

          // Check action buttons
          if (find.text('Terima').evaluate().isNotEmpty) {
            print('  âœ“ Opsi approve tersedia');
          }
          if (find.text('Tolak').evaluate().isNotEmpty) {
            print('  âœ“ Opsi reject tersedia');
          }

          // Back to list
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton.first);
            await tester.pumpAndSettle();
          }
        } else {
          print('  âš ï¸  Tidak ada toko pending');
        }

        // Back to dashboard
        final backToDashboard = find.byIcon(Icons.arrow_back);
        if (backToDashboard.evaluate().isNotEmpty) {
          await tester.tap(backToDashboard.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // Verify kembali ke dashboard atau navigate ulang ke marketplace
        await tester.pumpAndSettle(const Duration(seconds: 1));
        if (find.text('Dashboard Marketplace').evaluate().isEmpty) {
          print('  âš ï¸  Not at dashboard, navigating back to marketplace...');
          // Navigate ke marketplace lagi
          final bottomAppBar2 = find.byType(BottomAppBar);
          if (bottomAppBar2.evaluate().isNotEmpty) {
            final rect = tester.getRect(bottomAppBar2);
            final xPos = rect.left + (rect.width * 2.5 / 5);
            final yPos = rect.top + rect.height / 2;
            await tester.tapAt(Offset(xPos, yPos));
            await tester.pumpAndSettle(const Duration(seconds: 3));
          }
        }
        print('  âœ… Test validasi toko selesai\n');

        // ==================== 5. TEST VALIDASI PRODUK ====================
        print('ðŸ“ Step 5: Test Validasi Produk');

        // Verify di dashboard dulu
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.text('Dashboard Marketplace'), findsOneWidget);

        // Tap quick button "Validasi Produk"
        final validasiProdukTexts = find.text('Validasi Produk');
        if (validasiProdukTexts.evaluate().length >= 2) {
          await tester.tap(validasiProdukTexts.at(1)); // Menu button
        } else if (validasiProdukTexts.evaluate().isNotEmpty) {
          await tester.tap(validasiProdukTexts.first);
        }
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 4)); // Wait for provider
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('Daftar Toko Aktif'), findsOneWidget);
        print('  âœ“ Masuk ke Daftar Toko Aktif');

        // Check active stores
        final storeCards = find.byType(Card);
        if (storeCards.evaluate().length > 1) {
          print('  âœ“ Found ${storeCards.evaluate().length - 1} active stores');

          // Tap first store to see products
          await tester.tap(storeCards.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await tester.pump(const Duration(seconds: 3)); // Wait for products
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(find.text('Daftar Produk'), findsOneWidget);
          print('  âœ“ Masuk ke Daftar Produk');

          // Check products
          final productCards = find.byType(Card);
          if (productCards.evaluate().length > 1) {
            print('  âœ“ Found ${productCards.evaluate().length - 1} products');

            // Tap first product for detail
            await tester.tap(productCards.first);
            await tester.pumpAndSettle(const Duration(seconds: 3));

            expect(find.text('Detail Validasi Produk'), findsOneWidget);
            print('  âœ“ Detail produk dapat diakses');

            // Check menu options
            final menuButton = find.byIcon(Icons.more_vert);
            if (menuButton.evaluate().isNotEmpty) {
              await tester.tap(menuButton);
              await tester.pumpAndSettle(const Duration(seconds: 2));

              if (find.text('Hapus Produk').evaluate().isNotEmpty) {
                print('  âœ“ Opsi hapus produk tersedia');
              }

              // Close bottom sheet
              await tester.tapAt(const Offset(10, 10));
              await tester.pumpAndSettle();
            }

            // Back to product list
            final backToProducts = find.byIcon(Icons.arrow_back);
            if (backToProducts.evaluate().isNotEmpty) {
              await tester.tap(backToProducts.first);
              await tester.pumpAndSettle();
            }
          } else {
            print('  âš ï¸  Tidak ada produk di toko');
          }

          // Check store management options
          final storeMenuButton = find.byIcon(Icons.more_vert);
          if (storeMenuButton.evaluate().isNotEmpty) {
            await tester.tap(storeMenuButton);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            if (find.text('Nonaktifkan Toko').evaluate().isNotEmpty) {
              print('  âœ“ Opsi nonaktifkan toko tersedia');
            }

            // Close bottom sheet
            await tester.tapAt(const Offset(10, 10));
            await tester.pumpAndSettle();
          }

          // Back to active stores list
          final backToStores = find.byIcon(Icons.arrow_back);
          if (backToStores.evaluate().isNotEmpty) {
            await tester.tap(backToStores.first);
            await tester.pumpAndSettle();
          }
        } else {
          print('  âš ï¸  Tidak ada toko aktif');
        }

        // Back to dashboard
        final backFromValidasiProduk = find.byIcon(Icons.arrow_back);
        if (backFromValidasiProduk.evaluate().isNotEmpty) {
          await tester.tap(backFromValidasiProduk.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // Verify kembali ke dashboard atau navigate ulang
        await tester.pumpAndSettle(const Duration(seconds: 1));
        if (find.text('Dashboard Marketplace').evaluate().isEmpty) {
          print('  âš ï¸  Not at dashboard, navigating back to marketplace...');
          final bottomAppBar3 = find.byType(BottomAppBar);
          if (bottomAppBar3.evaluate().isNotEmpty) {
            final rect = tester.getRect(bottomAppBar3);
            final xPos = rect.left + (rect.width * 2.5 / 5);
            final yPos = rect.top + rect.height / 2;
            await tester.tapAt(Offset(xPos, yPos));
            await tester.pumpAndSettle(const Duration(seconds: 3));
          }
        }
        print('  âœ… Test validasi produk selesai\n');

        // ==================== 6. TEST SEARCH & FILTER ====================
        print('ðŸ“ Step 6: Test Search & Filter Functionality');

        // Verify di dashboard dulu
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.text('Dashboard Marketplace'), findsOneWidget);

        // Go back to Validasi Akun Toko for filter test
        final validasiTokoBtn = find.text('Validasi Akun Toko');
        if (validasiTokoBtn.evaluate().length >= 2) {
          await tester.tap(validasiTokoBtn.at(1));
        } else if (validasiTokoBtn.evaluate().isNotEmpty) {
          await tester.tap(validasiTokoBtn.first);
        }
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Test filter button
        final filterButton = find.byIcon(Icons.filter_list);
        if (filterButton.evaluate().isNotEmpty) {
          await tester.tap(filterButton);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          print('  âœ“ Filter bottom sheet opened');

          // Close filter
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();
        }

        // Back to dashboard
        final backFromSearchFilter = find.byIcon(Icons.arrow_back);
        if (backFromSearchFilter.evaluate().isNotEmpty) {
          await tester.tap(backFromSearchFilter.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        // Verify kembali ke dashboard atau navigate ulang
        await tester.pumpAndSettle(const Duration(seconds: 1));
        if (find.text('Dashboard Marketplace').evaluate().isEmpty) {
          print('  âš ï¸  Not at dashboard, navigating back to marketplace...');
          final bottomAppBar4 = find.byType(BottomAppBar);
          if (bottomAppBar4.evaluate().isNotEmpty) {
            final rect = tester.getRect(bottomAppBar4);
            final xPos = rect.left + (rect.width * 2.5 / 5);
            final yPos = rect.top + rect.height / 2;
            await tester.tapAt(Offset(xPos, yPos));
            await tester.pumpAndSettle(const Duration(seconds: 3));
          }
        }
        print('  âœ… Search & filter tested\n');

        // ==================== 7. TEST MANAJEMEN TOKO ====================
        print('ðŸ“ Step 7: Test Manajemen Toko (Deactivate)');

        // Verify di dashboard dulu
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.text('Dashboard Marketplace'), findsOneWidget);

        // Go to Validasi Akun Toko
        final validasiBtn = find.text('Validasi Akun Toko');
        if (validasiBtn.evaluate().length >= 2) {
          await tester.tap(validasiBtn.at(1));
        } else if (validasiBtn.evaluate().isNotEmpty) {
          await tester.tap(validasiBtn.first);
        }
        await tester.pumpAndSettle(const Duration(seconds: 4));

        // Check for active stores
        final diterimaChip = find.text('Diterima');
        if (diterimaChip.evaluate().isNotEmpty) {
          print('  âœ“ Found active stores');

          // Tap first active store
          await tester.tap(find.byType(Card).first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          await tester.pump(const Duration(seconds: 3));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(find.text('Detail Validasi Toko'), findsOneWidget);

          // Check deactivate option
          final menuBtn = find.byIcon(Icons.more_vert);
          if (menuBtn.evaluate().isNotEmpty) {
            await tester.tap(menuBtn);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            if (find.text('Nonaktifkan Toko').evaluate().isNotEmpty) {
              print('  âœ“ Opsi nonaktifkan toko tersedia');
            }
          }
        } else {
          print('  âš ï¸  Tidak ada toko aktif untuk test');
        }

        print('  âœ… Test manajemen toko selesai\n');

        print(
          'âœ… ========== FULL ADMIN MARKETPLACE E2E TEST PASSED ==========\n',
        );
      },
    );
  });
}

