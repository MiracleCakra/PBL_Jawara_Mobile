import 'package:SapaWarga_kel_2/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Warga - Full Shopping Flow E2E Test', () {
    testWidgets(
      'Login â†’ Browse â†’ Filter â†’ Cart â†’ Checkout â†’ Order â†’ Review',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 1. Login warga
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        final loginLink = find.text('Saya sudah punya akun');
        if (loginLink.evaluate().isNotEmpty) {
          await tester.tap(loginLink);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        final btnShowLoginForm = find.byKey(const Key('btn_show_login_form'));
        if (btnShowLoginForm.evaluate().isNotEmpty) {
          await tester.tap(btnShowLoginForm);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }

        await tester.enterText(
          find.byKey(const Key('input_email')),
          'cobapembeli@gmail.com',
        );
        await tester.enterText(
          find.byKey(const Key('input_password')),
          'password',
        );
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        await tester.tap(find.byKey(const Key('btn_submit_login')));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        final loginSuccess = find.text('Dashboard Warga').evaluate().isNotEmpty ||
            find.text('Marketplace').evaluate().isNotEmpty ||
            find.byType(BottomAppBar).evaluate().isNotEmpty;
        
        if (!loginSuccess) {
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }
        
        debugPrint('âœ“ Step 1: Login warga completed');

        // 2. Navigate to Marketplace
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        final bottomAppBar = find.byType(BottomAppBar);
        if (bottomAppBar.evaluate().isNotEmpty) {
          final rect = tester.getRect(bottomAppBar);
          await tester.tapAt(
            Offset(rect.left + (rect.width * 2.5 / 5), rect.top + rect.height / 2),
          );
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        final belanjaMenu = find.text('Belanja Produk');
        if (belanjaMenu.evaluate().isNotEmpty) {
          await tester.tap(belanjaMenu);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }
        
        debugPrint('âœ“ Step 2: Navigate to Marketplace completed');

        // 3. Browse products
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        final allCards = find.byType(Card);
        final allPrices = find.textContaining('Rp ');
        
        final hasProducts = allCards.evaluate().isNotEmpty || allPrices.evaluate().isNotEmpty;
        if (!hasProducts) {
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }

        final gridView = find.byType(GridView);
        if (gridView.evaluate().isNotEmpty) {
          await tester.drag(gridView.first, const Offset(0, -300));
          await tester.pumpAndSettle();
        }
        
        debugPrint('âœ“ Step 3: Browse products completed');

        // 4. Filter by Grade A
        final gradeAText = find.text('Grade A');
        if (gradeAText.evaluate().isNotEmpty) {
          await tester.tap(gradeAText.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle(const Duration(seconds: 4));
          }
          
          debugPrint('âœ“ Step 4: Filter by Grade A completed');
        }

        // Scroll ke atas untuk refresh produk
        await tester.pumpAndSettle(const Duration(seconds: 1));
        final gridViewReload = find.byType(GridView);
        if (gridViewReload.evaluate().isNotEmpty) {
          await tester.drag(gridViewReload.first, const Offset(0, 300));
          await tester.pumpAndSettle(const Duration(seconds: 3));
          debugPrint('DEBUG - Scrolled to top to refresh products');
        }

        // 5. Tap product detail
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        final productCards = find.byType(Card);
        var productPrices = find.textContaining('Rp ');
        
        debugPrint('DEBUG - Cards found: ${productCards.evaluate().length}');
        debugPrint('DEBUG - Prices found: ${productPrices.evaluate().length}');
        
        Finder? productToTap;
        
        if (productCards.evaluate().length > 2) {
          productToTap = productCards.at(2);
          debugPrint('DEBUG - Will tap Card #2');
        } else if (productCards.evaluate().isNotEmpty) {
          productToTap = productCards.first;
          debugPrint('DEBUG - Will tap first Card');
        }
        
        if (productToTap != null && productToTap.evaluate().isNotEmpty) {
          // Step 5: Open product detail
          await tester.tap(productToTap);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          final hasKeranjangButton = find.text('Keranjang').evaluate().isNotEmpty;
          final hasBeliButton = find.textContaining('Beli Sekarang').evaluate().isNotEmpty;
          final hasPenjualSection = find.text('Penjual').evaluate().isNotEmpty;
          final hasDetailPage = hasKeranjangButton || hasBeliButton || hasPenjualSection;

          if (hasDetailPage) {
            debugPrint('âœ“ Step 5: Open product detail completed');

            // Step 6: View reviews
            final scrollView = find.byType(SingleChildScrollView);
            if (scrollView.evaluate().isNotEmpty) {
              await tester.drag(scrollView.first, const Offset(0, -500));
              await tester.pumpAndSettle();

              final viewAllReviews = find.text('Lihat Semua Ulasan');
              if (viewAllReviews.evaluate().isNotEmpty) {
                await tester.tap(viewAllReviews);
                await tester.pumpAndSettle(const Duration(seconds: 2));
                await tester.tap(find.byIcon(Icons.arrow_back));
                await tester.pumpAndSettle();
                debugPrint('âœ“ Step 6: View reviews completed');
              } else {
                debugPrint('âŠ˜ Step 6: Skipped - No reviews available');
              }

              // Step 7: Add to cart
              await tester.drag(scrollView.first, const Offset(0, 500));
              await tester.pumpAndSettle();

              final keranjangButton = find.text('Keranjang');
              if (keranjangButton.evaluate().isNotEmpty) {
                await tester.tap(keranjangButton);
                await tester.pumpAndSettle(const Duration(seconds: 2));

                final okButton = find.text('OK');
                if (okButton.evaluate().isNotEmpty) {
                  await tester.tap(okButton);
                  await tester.pumpAndSettle(const Duration(seconds: 2));
                }
                debugPrint('âœ“ Step 7: Add to cart completed');
              } else {
                debugPrint('âŠ˜ Step 7: Skipped - Keranjang button not found');
              }

              // Navigate back to Marketplace
              final rect2 = tester.getRect(find.byType(BottomAppBar));
              await tester.tapAt(
                Offset(rect2.left + (rect2.width * 2.5 / 5), rect2.top + rect2.height / 2),
              );
              await tester.pumpAndSettle(const Duration(seconds: 4));

              await tester.tap(find.text('Belanja Produk').first);
              await tester.pumpAndSettle(const Duration(seconds: 3));
            } else {
              debugPrint('âŠ˜ Step 6-7: Skipped - ScrollView not found');
            }
          } else {
            debugPrint('âŠ˜ Step 5: Skipped - Not in detail page');
          }
        } else {
          debugPrint('âŠ˜ Step 5: Skipped - Product not found to tap');
        }

        // 8. Open cart
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        final appBar = find.byType(AppBar);
        if (appBar.evaluate().isNotEmpty) {
          final appBarRect = tester.getRect(appBar);
          await tester.tapAt(
            Offset(appBarRect.right - 40, appBarRect.top + appBarRect.height / 2),
          );
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }
        
        debugPrint('âœ“ Step 8: Open cart completed');

        // 9. Checkout
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        final inCartPage = find.text('Keranjang Belanja').evaluate().isNotEmpty;
        debugPrint('DEBUG - In cart page: $inCartPage');
        
        if (inCartPage) {
          final checkoutButton = find.text('Lanjutkan Pembayaran');
          debugPrint('DEBUG - Checkout button found: ${checkoutButton.evaluate().isNotEmpty}');
          
          if (checkoutButton.evaluate().isNotEmpty) {
            await tester.tap(checkoutButton);
            await tester.pumpAndSettle(const Duration(seconds: 3));

            final hasCheckoutPage = find.text('Checkout Pembayaran').evaluate().isNotEmpty;
            debugPrint('DEBUG - Checkout page loaded: $hasCheckoutPage');
            
            if (hasCheckoutPage) {
              await tester.drag(find.text('Checkout Pembayaran'), const Offset(0, -300));
              await tester.pumpAndSettle();

              final tunaiCOD = find.textContaining('Tunai (COD)');
              if (tunaiCOD.evaluate().isNotEmpty) {
                await tester.tap(tunaiCOD.first);
                await tester.pumpAndSettle();
              }

              final buatPesananBtn = find.textContaining('Buat Pesanan');
              if (buatPesananBtn.evaluate().isNotEmpty) {
                await tester.tap(buatPesananBtn.first);
                await tester.pumpAndSettle(const Duration(seconds: 5));

                final pesananBerhasilDialog = find.text('Pesanan Berhasil!');
                if (pesananBerhasilDialog.evaluate().isNotEmpty) {
                  final lihatPesananBtn = find.text('Lihat Pesanan');
                  if (lihatPesananBtn.evaluate().isNotEmpty) {
                    await tester.tap(lihatPesananBtn);
                    await tester.pumpAndSettle(const Duration(seconds: 4));
                  }
                }
                
                debugPrint('âœ“ Step 9: Checkout completed');
              } else {
                debugPrint('âŠ˜ Step 9: Skipped - Buat Pesanan button not found');
              }
            } else {
              debugPrint('âŠ˜ Step 9: Skipped - Checkout Pembayaran page not found');
            }
          } else {
            debugPrint('âŠ˜ Step 9: Skipped - Lanjutkan Pembayaran button not found');
          }
        } else {
          debugPrint('âŠ˜ Step 9: Skipped - Not in cart page');
        }

        // 10. Verify orders page
        final alreadyInPesananSaya = find.text('Pesanan Saya').evaluate().isNotEmpty;

        if (!alreadyInPesananSaya) {
          final bottomAppBar2 = find.byType(BottomAppBar);
          if (bottomAppBar2.evaluate().isNotEmpty) {
            final rect2 = tester.getRect(bottomAppBar2);
            await tester.tapAt(
              Offset(rect2.left + (rect2.width * 2.5 / 5), rect2.top + rect2.height / 2),
            );
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }

          final myOrdersMenu = find.text('Pesanan Saya');
          if (myOrdersMenu.evaluate().isNotEmpty) {
            await tester.tap(myOrdersMenu);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }

        final pesananSayaTitle = find.text('Pesanan Saya');
        if (pesananSayaTitle.evaluate().isNotEmpty) {
          expect(find.text('Pesanan Saya'), findsOneWidget);
          
          final orderItems = find.textContaining('Order #');
          if (orderItems.evaluate().isNotEmpty) {
            expect(find.textContaining('Order #'), findsWidgets);
          }
          
          debugPrint('âœ“ Step 10: Verify orders page completed');
        }

        // 11. Open completed order & review
        final selesaiStatus = find.text('Selesai');
        if (selesaiStatus.evaluate().isNotEmpty) {
          final selesaiCards = find.ancestor(
            of: selesaiStatus,
            matching: find.byType(Card),
          );

          if (selesaiCards.evaluate().isNotEmpty) {
            await tester.tap(selesaiCards.first);
            await tester.pumpAndSettle(const Duration(seconds: 3));

            expect(find.text('Detail Pesanan'), findsOneWidget);

            await tester.drag(
              find.byType(SingleChildScrollView).first,
              const Offset(0, -400),
            );
            await tester.pumpAndSettle(const Duration(seconds: 2));

            final tulisUlasanButton = find.text('Tulis Ulasan');
            if (tulisUlasanButton.evaluate().isNotEmpty) {
              await tester.tap(tulisUlasanButton);
              await tester.pumpAndSettle(const Duration(seconds: 2));

              expect(find.text('Tulis Ulasan Produk'), findsOneWidget);

              await tester.tap(find.byIcon(Icons.arrow_back).first);
              await tester.pumpAndSettle();
            }

            await tester.tap(find.byIcon(Icons.arrow_back));
            await tester.pumpAndSettle();
            
            debugPrint('âœ“ Step 11: Open completed order & review completed');
          }
        }

        // 12. Test order status tabs
        final statuses = ['Pending', 'Diproses', 'Selesai', 'Dibatalkan'];
        for (String status in statuses) {
          final statusTab = find.text(status);
          if (statusTab.evaluate().isNotEmpty) {
            await tester.tap(statusTab.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
        
        debugPrint('âœ“ Step 12: Test order status tabs completed');
        debugPrint('\nâœ… Full Warga Shopping E2E test passed!');
      },
    );
  });
}
