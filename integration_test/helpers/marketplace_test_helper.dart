import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper functions untuk Marketplace Testing
/// Digunakan di E2E dan Integration tests

class MarketplaceTestHelper {
  /// Login helper untuk berbagai role
  static Future<void> loginAs({
    required WidgetTester tester,
    required String email,
    required String password,
  }) async {
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;
    final loginButton = find.text('Masuk');

    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);
    await tester.pumpAndSettle();

    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Navigate to marketplace menu
  static Future<void> navigateToMarketplace(WidgetTester tester) async {
    final marketplaceMenu = find.text('Marketplace');
    if (marketplaceMenu.evaluate().isNotEmpty) {
      await tester.tap(marketplaceMenu);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  /// Navigate to specific marketplace submenu
  static Future<void> navigateToMarketplaceMenu({
    required WidgetTester tester,
    required String menuName,
  }) async {
    await navigateToMarketplace(tester);

    final submenu = find.text(menuName);
    if (submenu.evaluate().isNotEmpty) {
      await tester.tap(submenu);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  /// Wait for loading to complete
  static Future<void> waitForLoading(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Scroll to find widget
  static Future<void> scrollToFind({
    required WidgetTester tester,
    required Finder scrollable,
    required Finder target,
    double scrollAmount = -300,
  }) async {
    await tester.drag(scrollable, Offset(0, scrollAmount));
    await tester.pumpAndSettle();
  }

  /// Verify snackbar message
  static void verifySnackbarMessage(String message) {
    expect(find.textContaining(message), findsOneWidget);
  }

  /// Fill text form field by label
  static Future<void> fillFormField({
    required WidgetTester tester,
    required String label,
    required String value,
  }) async {
    final field = find.widgetWithText(TextFormField, label);
    if (field.evaluate().isNotEmpty) {
      await tester.enterText(field, value);
      await tester.pumpAndSettle();
    }
  }

  /// Tap button by text
  static Future<void> tapButton({
    required WidgetTester tester,
    required String buttonText,
  }) async {
    final button = find.text(buttonText);
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  /// Verify screen title
  static void verifyScreenTitle(String title) {
    expect(find.text(title), findsWidgets);
  }

  /// Add product to cart (helper for testing)
  static Future<void> addProductToCart(WidgetTester tester) async {
    final productCards = find.byType(Card);
    if (productCards.evaluate().isNotEmpty) {
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final addToCartButton = find.text('Tambah ke Keranjang');
      if (addToCartButton.evaluate().isNotEmpty) {
        await tester.tap(addToCartButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Go back
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
        await tester.pumpAndSettle();
      }
    }
  }

  /// Test credentials
  static const Map<String, Map<String, String>> testUsers = {
    'admin': {'email': 'admin@test.com', 'password': 'Admin123!'},
    'warga': {'email': 'warga@test.com', 'password': 'Warga123!'},
    'seller': {'email': 'seller@test.com', 'password': 'Seller123!'},
  };

  /// Get test user credentials
  static Map<String, String> getTestUser(String role) {
    return testUsers[role] ?? testUsers['warga']!;
  }

  /// Print test step
  static void printTestStep(String message) {
    print('   📝 $message');
  }

  /// Print test success
  static void printTestSuccess(String message) {
    print('   ✅ $message');
  }

  /// Print test warning
  static void printTestWarning(String message) {
    print('   ⚠️  $message');
  }

  /// Print test error
  static void printTestError(String message) {
    print('   ❌ $message');
  }
}

/// Test data constants
class MarketplaceTestData {
  // Store test data
  static const Map<String, dynamic> testStore = {
    'nama': 'Test Store',
    'alamat': 'Jl. Test No. 123',
    'kontak': '081234567890',
    'deskripsi': 'Test store description',
  };

  // Product test data
  static const Map<String, dynamic> testProduct = {
    'nama': 'Test Product',
    'harga': 10000,
    'stok': 100,
    'satuan': 'kg',
    'grade': 'A',
    'kategori': 'Sayuran',
    'deskripsi': 'Test product description',
  };

  // Order test data
  static const Map<String, dynamic> testOrder = {
    'alamat': 'Jl. Pengiriman No. 456',
    'metodePembayaran': 'Transfer Bank',
    'metodeDelivery': 'Diantar',
  };

  // Review test data
  static const Map<String, dynamic> testReview = {
    'rating': 5,
    'comment': 'Produk bagus, kualitas sangat baik!',
  };

  // Filter options
  static const List<String> gradeOptions = ['Grade A', 'Grade B', 'Grade C'];
  static const List<String> orderStatuses = [
    'Pending',
    'Diproses',
    'Selesai',
    'Dibatalkan',
  ];
}

/// Assertion helpers
class MarketplaceAssertions {
  /// Assert dashboard loaded
  static void assertDashboardLoaded() {
    expect(find.textContaining('Dashboard'), findsWidgets);
  }

  /// Assert product list loaded
  static void assertProductListLoaded() {
    expect(find.byType(GridView), findsWidgets);
  }

  /// Assert cart has items
  static void assertCartHasItems() {
    final cards = find.byType(Card);
    expect(cards.evaluate().isNotEmpty, isTrue);
  }

  /// Assert order created successfully
  static void assertOrderCreated() {
    expect(find.textContaining('berhasil'), findsWidgets);
  }

  /// Assert review submitted
  static void assertReviewSubmitted() {
    expect(find.textContaining('terkirim'), findsWidgets);
  }

  /// Assert store verified
  static void assertStoreVerified(String status) {
    expect(find.text(status), findsWidgets);
  }
}
