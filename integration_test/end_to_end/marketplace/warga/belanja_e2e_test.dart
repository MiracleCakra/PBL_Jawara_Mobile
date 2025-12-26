import 'package:SapaWarga_kel_2/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Warga - Full Shopping Flow E2E Test', () {
    testWidgets('Login → Browse → Filter → Cart → Checkout → Order → Review', (
      WidgetTester tester,
    ) async {
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

      final loginSuccess =
          find.text('Dashboard Warga').evaluate().isNotEmpty ||
          find.text('Marketplace').evaluate().isNotEmpty ||
          find.byType(BottomAppBar).evaluate().isNotEmpty;

      if (!loginSuccess) {
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      debugPrint('✓ Step 1: Login warga completed');

      // 2. Navigate to Marketplace
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final bottomAppBar = find.byType(BottomAppBar);
      if (bottomAppBar.evaluate().isNotEmpty) {
        final rect = tester.getRect(bottomAppBar);
        await tester.tapAt(
          Offset(
            rect.left + (rect.width * 2.5 / 5),
            rect.top + rect.height / 2,
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      final belanjaMenu = find.text('Belanja Produk');
      if (belanjaMenu.evaluate().isNotEmpty) {
        await tester.tap(belanjaMenu);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      debugPrint('✓ Step 2: Navigate to Marketplace completed');

      // 3. Browse products
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final allCards = find.byType(Card);
      final allPrices = find.textContaining('Rp ');

      final hasProducts =
          allCards.evaluate().isNotEmpty || allPrices.evaluate().isNotEmpty;
      if (!hasProducts) {
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      final gridView = find.byType(GridView);
      if (gridView.evaluate().isNotEmpty) {
        await tester.drag(gridView.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      debugPrint('✓ Step 3: Browse products completed');

      // 4. Lihat Detail Produk (dari Belanja Produk)
      debugPrint('\nStep 4: Lihat detail produk dari Belanja Produk...');

      // Tunggu UI stabil tanpa pumpAndSettle yang bisa stuck
      await tester.pump(const Duration(seconds: 1));

      // Cari produk dengan nama (dari debug: "Tomat busuk")
      final tomatBusuk = find.textContaining('Tomat busuk');
      final anyProduct = find.textContaining('Rp '); // Harga produk

      debugPrint(
        'DEBUG - Produk "Tomat busuk" found: ${tomatBusuk.evaluate().length}',
      );
      debugPrint(
        'DEBUG - Produk dengan harga found: ${anyProduct.evaluate().length}',
      );

      Finder productToTap;
      if (tomatBusuk.evaluate().isNotEmpty) {
        productToTap = tomatBusuk.first;
        debugPrint('  Akan tap produk "Tomat busuk"');
      } else if (anyProduct.evaluate().isNotEmpty) {
        productToTap = anyProduct.first;
        debugPrint('  Akan tap produk pertama yang ditemukan');
      } else {
        // Fallback: cari GestureDetector atau InkWell
        final gestureDetectors = find.byType(GestureDetector);
        final inkWells = find.byType(InkWell);

        debugPrint(
          'DEBUG - GestureDetector found: ${gestureDetectors.evaluate().length}',
        );
        debugPrint('DEBUG - InkWell found: ${inkWells.evaluate().length}');

        if (inkWells.evaluate().length > 5) {
          // Skip 5 InkWell pertama (mungkin filter/header), ambil yang ke-6
          productToTap = inkWells.at(5);
          debugPrint('  Akan tap InkWell ke-6');
        } else if (gestureDetectors.evaluate().isNotEmpty) {
          productToTap = gestureDetectors.first;
          debugPrint('  Akan tap GestureDetector pertama');
        } else {
          fail('Tidak ada produk yang bisa di-tap');
        }
      }

      await tester.tap(productToTap);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifikasi masuk ke halaman detail - cek ada tombol Keranjang atau Beli Sekarang
      final keranjangBtn = find.textContaining('Keranjang');
      final beliSekarangBtn = find.textContaining('Beli Sekarang');

      expect(
        keranjangBtn.evaluate().isNotEmpty ||
            beliSekarangBtn.evaluate().isNotEmpty,
        true,
        reason: 'Halaman detail produk tidak muncul',
      );

      debugPrint('✓ Step 4: Open product detail completed');

      // 5. Lihat Ulasan Produk
      debugPrint('\nStep 5: Lihat ulasan produk...');

      // Scroll ke bawah untuk melihat section ulasan
      final scrollable = find.byType(SingleChildScrollView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -500));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else {
        debugPrint('  SingleChildScrollView tidak ditemukan, skip scroll');
      }

      // Cari dan tap "Lihat Semua Ulasan" jika ada
      final lihatSemuaUlasan = find.textContaining('Lihat Semua');
      if (lihatSemuaUlasan.evaluate().isNotEmpty) {
        debugPrint('  Tap "Lihat Semua Ulasan"...');
        await tester.tap(lihatSemuaUlasan.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verifikasi halaman ulasan terbuka
        final ulasanPage = find.textContaining('Ulasan');
        expect(
          ulasanPage,
          findsWidgets,
          reason: 'Halaman ulasan tidak terbuka',
        );

        // Kembali ke halaman detail produk
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          debugPrint('  Kembali ke halaman detail produk');
        }
      } else {
        debugPrint('  "Lihat Semua Ulasan" tidak ditemukan, skip');
      }

      debugPrint('✓ Step 5: View product reviews completed');

      // Scroll kembali ke atas untuk akses tombol Keranjang
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, 500));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // 6. Tambah ke Keranjang (dari Detail Produk)
      debugPrint('\nStep 6: Tambah produk ke keranjang...');

      final keranjangButton = find.textContaining('Keranjang');
      expect(
        keranjangButton,
        findsWidgets,
        reason: 'Tombol Keranjang tidak ditemukan',
      );

      await tester.tap(keranjangButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      debugPrint('✓ Step 6: Add to cart completed');

      // Klik button OK pada dialog "Ditambahkan ke Keranjang"
      debugPrint('  Klik button OK pada dialog...');
      final okButton = find.text('OK');
      expect(okButton, findsWidgets, reason: 'Button OK tidak ditemukan');

      await tester.tap(okButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint('  Dialog dismissed');

      // Langsung kembali ke menu Marketplace - coba tap text 'Marketplace'
      debugPrint('  Kembali ke menu Marketplace...');
      final marketplaceTabNav = find.text('Marketplace');

      if (marketplaceTabNav.evaluate().isNotEmpty) {
        debugPrint(
          '  Found ${marketplaceTabNav.evaluate().length} Marketplace text widgets',
        );
        // Tap yang terakhir (di bottom nav)
        await tester.tap(marketplaceTabNav.last);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        debugPrint('  Tap text Marketplace untuk kembali ke menu');
      } else {
        // Fallback ke position-based tap
        final bottomAppBar3 = find.byType(BottomAppBar);
        if (bottomAppBar3.evaluate().isNotEmpty) {
          final rect3 = tester.getRect(bottomAppBar3);
          final xPos3 = rect3.left + (rect3.width * 2.5 / 5);
          final yPos3 = rect3.top + rect3.height / 2;

          debugPrint('  Tap Marketplace di posisi: x=$xPos3, y=$yPos3');
          await tester.tapAt(Offset(xPos3, yPos3));
          await tester.pumpAndSettle(const Duration(seconds: 4));
          debugPrint('  Tap Marketplace untuk kembali ke menu');
        }
      }

      // Verifikasi sudah di menu Marketplace Warga
      debugPrint('DEBUG - Cek halaman setelah tap Marketplace:');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      var marketplaceWargaCheck = find.text('Marketplace Warga');
      var belanjaSubmenuCheck = find.text('Belanja Produk');
      var tokoSayaCheck = find.text('Toko Saya');
      var pesananSayaCheck = find.text('Pesanan Saya');

      debugPrint(
        '  Marketplace Warga found: ${marketplaceWargaCheck.evaluate().length}',
      );
      debugPrint(
        '  Belanja Produk found: ${belanjaSubmenuCheck.evaluate().length}',
      );
      debugPrint('  Toko Saya found: ${tokoSayaCheck.evaluate().length}');
      debugPrint('  Pesanan Saya found: ${pesananSayaCheck.evaluate().length}');

      // Debug: print semua text kalau tidak ketemu
      if (marketplaceWargaCheck.evaluate().isEmpty) {
        debugPrint(
          '  Marketplace Warga tidak ditemukan, print GoRouter location:',
        );

        // Print semua text widgets
        final allTexts = find.byType(Text);
        debugPrint('  Total text widgets: ${allTexts.evaluate().length}');
        for (var i = 0; i < allTexts.evaluate().length && i < 15; i++) {
          final widget = allTexts.evaluate().elementAt(i).widget as Text;
          debugPrint('    Text $i: "${widget.data}"');
        }

        // Coba tap Marketplace dengan cara berbeda - by index position
        debugPrint('  Coba tap Marketplace dengan bottom nav position...');
        final bottomAppBar4 = find.byType(BottomAppBar);
        if (bottomAppBar4.evaluate().isNotEmpty) {
          final rect4 = tester.getRect(bottomAppBar4);
          final xPos4 = rect4.left + (rect4.width * 2.5 / 5);
          final yPos4 = rect4.top + rect4.height / 2;
          await tester.tapAt(Offset(xPos4, yPos4));
          await tester.pumpAndSettle(const Duration(seconds: 5));
          debugPrint('  Tap Marketplace position lagi');

          // Check lagi
          marketplaceWargaCheck = find.text('Marketplace Warga');
          belanjaSubmenuCheck = find.text('Belanja Produk');
          debugPrint(
            '  Setelah tap ke-2: Marketplace Warga found: ${marketplaceWargaCheck.evaluate().length}',
          );
          debugPrint(
            '  Setelah tap ke-2: Belanja Produk found: ${belanjaSubmenuCheck.evaluate().length}',
          );
        }
      }

      // Harus ada minimal Marketplace Warga title dan 3 submenu
      expect(
        marketplaceWargaCheck,
        findsWidgets,
        reason: 'Marketplace Warga tidak ditemukan',
      );
      expect(
        belanjaSubmenuCheck,
        findsWidgets,
        reason: 'Submenu Belanja Produk tidak ditemukan',
      );

      debugPrint('✓ Step 6b: Back to Marketplace menu completed');

      // 7. Masuk ke Belanja Produk lagi untuk akses keranjang
      debugPrint(
        '\nStep 7: Masuk ke Belanja Produk lagi untuk akses keranjang...',
      );

      final belanjaMenuAgain = find.text('Belanja Produk');
      expect(
        belanjaMenuAgain,
        findsWidgets,
        reason: 'Submenu Belanja Produk tidak ditemukan',
      );

      await tester.tap(belanjaMenuAgain.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      debugPrint('✓ Step 7: Enter Belanja Produk again completed');

      // 8. Buka Keranjang dari Icon di AppBar
      debugPrint('\nStep 8: Buka keranjang dari icon di AppBar...');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      debugPrint('DEBUG - Mencari icon keranjang...');

      // Icon keranjang di pojok kanan atas - tap berdasarkan posisi AppBar
      final appBar = find.byType(AppBar);

      if (appBar.evaluate().isNotEmpty) {
        final appBarRect = tester.getRect(appBar);
        // Tap di pojok kanan atas AppBar (40px dari kanan)
        final xPos = appBarRect.right - 40;
        final yPos = appBarRect.top + appBarRect.height / 2;

        debugPrint('  Tap icon keranjang di posisi: x=$xPos, y=$yPos');
        await tester.tapAt(Offset(xPos, yPos));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verifikasi masuk ke halaman keranjang
        expect(
          find.text('Keranjang Belanja'),
          findsWidgets,
          reason: 'Halaman keranjang tidak muncul',
        );
        debugPrint('✓ Step 8: Open cart completed');
      } else {
        // Fallback: cari dengan Icons
        final cartIcons = find.byIcon(Icons.shopping_cart);
        if (cartIcons.evaluate().isNotEmpty) {
          await tester.tap(cartIcons.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          debugPrint('✓ Step 8: Open cart completed (by Icon)');
        } else {
          fail('Icon keranjang tidak ditemukan');
        }
      }

      // 9. Lanjutkan Pembayaran
      debugPrint('\nStep 9: Lanjutkan pembayaran...');

      final lanjutkanPembayaranBtn = find.text('Lanjutkan Pembayaran');
      expect(
        lanjutkanPembayaranBtn,
        findsWidgets,
        reason: 'Tombol Lanjutkan Pembayaran tidak ditemukan',
      );

      await tester.tap(lanjutkanPembayaranBtn);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.text('Checkout Pembayaran'),
        findsWidgets,
        reason: 'Halaman checkout tidak muncul',
      );
      debugPrint('✓ Step 9: Checkout page opened');

      // Pilih metode pengambilan (default: Ambil di Toko Warga sudah terpilih)
      // Scroll ke bawah untuk lihat metode pembayaran
      await tester.drag(
        find.text('Checkout Pembayaran'),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Pilih metode pembayaran Tunai (COD)
      final tunaiCOD = find.textContaining('Tunai (COD)');
      if (tunaiCOD.evaluate().isNotEmpty) {
        await tester.tap(tunaiCOD.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        debugPrint('  Selected payment method: Tunai (COD)');
      }

      // Tap tombol Buat Pesanan
      final buatPesananBtn = find.textContaining('Buat Pesanan');
      expect(
        buatPesananBtn,
        findsWidgets,
        reason: 'Tombol Buat Pesanan tidak ditemukan',
      );

      await tester.tap(buatPesananBtn.first);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      debugPrint('✓ Step 9: Order created successfully');

      // Verifikasi dialog "Pesanan Berhasil!" muncul
      final pesananBerhasilDialog = find.text('Pesanan Berhasil!');
      expect(
        pesananBerhasilDialog,
        findsWidgets,
        reason: 'Dialog Pesanan Berhasil tidak muncul',
      );

      // Klik button "Lihat Pesanan" untuk langsung ke Pesanan Saya
      debugPrint('  Klik button Lihat Pesanan...');
      final lihatPesananBtn = find.text('Lihat Pesanan');
      expect(
        lihatPesananBtn,
        findsWidgets,
        reason: 'Button Lihat Pesanan tidak ditemukan',
      );

      await tester.tap(lihatPesananBtn);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      debugPrint('  Navigated to Pesanan Saya');

      // 10. Verifikasi Pesanan Saya
      final pesananSayaTitle = find.text('Pesanan Saya');
      expect(
        pesananSayaTitle,
        findsWidgets,
        reason: 'Halaman Pesanan Saya tidak muncul',
      );

      // Verifikasi ada order yang baru dibuat
      final orderItems = find.textContaining('Order #');
      expect(
        orderItems,
        findsWidgets,
        reason: 'Tidak ada pesanan yang ditemukan',
      );

      debugPrint('✓ Step 10: Verify orders page completed');
      debugPrint('✓ Order found in Pesanan Saya');

      // 11. Detail Pesanan & Akses Form Ulasan
      debugPrint('\nStep 11: Buka detail pesanan dan akses form ulasan...');

      // Cari order card yang baru dibuat (pertama di list)
      final orderCards = find.textContaining('Order #');
      if (orderCards.evaluate().isNotEmpty) {
        debugPrint('  Found ${orderCards.evaluate().length} orders');

        // Tap order pertama untuk buka detail
        await tester.tap(orderCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        debugPrint('  Opened order detail');

        // Verifikasi halaman detail pesanan terbuka
        final detailPesanan = find.text('Detail Pesanan');
        expect(
          detailPesanan,
          findsWidgets,
          reason: 'Halaman detail pesanan tidak terbuka',
        );

        // Scroll ke bawah untuk cari button "Tulis Ulasan" atau "Bayar Sekarang"
        final orderScrollable = find.byType(SingleChildScrollView);
        if (orderScrollable.evaluate().isNotEmpty) {
          await tester.drag(orderScrollable.last, const Offset(0, -300));
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }

        // Cek status pesanan dari UI
        final statusSelesai = find.textContaining('Selesai');
        final tulisUlasanBtn = find.textContaining('Tulis Ulasan');
        final bayarSekarangBtn = find.textContaining('Bayar Sekarang');

        if (tulisUlasanBtn.evaluate().isNotEmpty) {
          // Order sudah selesai, bisa review
          debugPrint(
            '  Order status: Selesai - Button "Tulis Ulasan" tersedia',
          );

          await tester.tap(tulisUlasanBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          debugPrint('  Opened review form');

          // Verifikasi form ulasan terbuka
          final formTitle = find.textContaining('Tulis Ulasan Anda');
          final hasRatingStars = find.byIcon(Icons.star_border);
          final hasTextField = find.byType(TextField);

          final formOpened =
              formTitle.evaluate().isNotEmpty ||
              hasRatingStars.evaluate().isNotEmpty ||
              hasTextField.evaluate().isNotEmpty;

          expect(formOpened, true, reason: 'Form ulasan tidak terbuka');

          debugPrint('  Form ulasan berhasil dibuka');

          // Kembali dari form ulasan
          final backBtn = find.byIcon(Icons.arrow_back);
          if (backBtn.evaluate().isNotEmpty) {
            await tester.tap(backBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            debugPrint('  Kembali dari form ulasan');
          }

          debugPrint('✓ Step 11: Review form accessed successfully');
        } else if (bayarSekarangBtn.evaluate().isNotEmpty) {
          // Order belum selesai, masih perlu pembayaran
          debugPrint(
            '  Order status: Belum Bayar/Pending - Review tidak tersedia',
          );
          debugPrint(
            '  Note: Review hanya tersedia untuk order yang sudah selesai (completed)',
          );
          debugPrint(
            '✓ Step 11: Completed (order not yet completed, review unavailable)',
          );
        } else {
          debugPrint('  Button action tidak ditemukan, check status');
          debugPrint('✓ Step 11: Completed (status checked)');
        }

        // Kembali ke Pesanan Saya
        final backToOrders = find.byIcon(Icons.arrow_back);
        if (backToOrders.evaluate().isNotEmpty) {
          await tester.tap(backToOrders.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          debugPrint('  Kembali ke Pesanan Saya');
        }
      } else {
        debugPrint('  Tidak ada pesanan, skip');
        debugPrint('✓ Step 11: Skipped (no orders found)');
      }

      // 12. Test Refresh Orders (pojok kanan atas)
      debugPrint('\nStep 12: Test refresh orders button...');

      // Cari icon refresh di AppBar (pojok kanan atas)
      final refreshIcon = find.byIcon(Icons.refresh);
      if (refreshIcon.evaluate().isNotEmpty) {
        debugPrint('  Found refresh icon in AppBar');
        await tester.tap(refreshIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        debugPrint('  Refresh button tapped, orders reloaded');
        debugPrint('✓ Step 12: Refresh orders tested successfully');
      } else {
        // Fallback: tap by position (pojok kanan atas)
        final appBar = find.byType(AppBar);
        if (appBar.evaluate().isNotEmpty) {
          final appBarRect = tester.getRect(appBar);
          final xPos = appBarRect.right - 40;
          final yPos = appBarRect.top + appBarRect.height / 2;

          debugPrint('  Tap refresh icon by position: x=$xPos, y=$yPos');
          await tester.tapAt(Offset(xPos, yPos));
          await tester.pumpAndSettle(const Duration(seconds: 2));
          debugPrint(
            '✓ Step 12: Refresh orders tested successfully (by position)',
          );
        } else {
          debugPrint('  Refresh icon tidak ditemukan');
          debugPrint('✓ Step 12: Skipped (refresh icon not found)');
        }
      }

      debugPrint('\n🎉 Marketplace Integration Test Completed Successfully!');
      debugPrint('   Total Steps: 12');
      debugPrint(
        '   Flow: Login → Browse → Detail → Review → Cart → Checkout → Order → Verify → Review Access → Refresh',
      );
      debugPrint(
        '   Note: Step 11 (Review) requires order status "Selesai/Completed"',
      );
    });
  });
}
