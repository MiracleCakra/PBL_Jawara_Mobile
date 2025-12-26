import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:SapaWarga_kel_2/models/marketplace/product_model.dart';
import 'package:SapaWarga_kel_2/providers/marketplace/cart_provider.dart';
import 'package:SapaWarga_kel_2/screens/warga/marketplace/belanja/checkoutscreen.dart';

class DummyCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<Map<String, dynamic>> get cartItems => [];

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  int get totalItems => 0;

  @override
  double get totalPrice => 0;

  @override
  Future<void> fetchCartWithProducts(String userId) async {}

  @override
  Future<bool> addToCart(String userId, int productId) async => true;

  @override
  Future<bool> removeFromCart(int cartId, String userId) async => true;

  @override
  Future<bool> clearCart(String userId) async => true;

  @override
  void clearError() {}
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      anonKey: 'dummy-anon-key',
    );
  });

  Widget createWidgetUnderTest({Object? extra}) {
    final router = GoRouter(
      initialLocation: '/checkout',
      initialExtra: extra,
      routes: [
        GoRoute(
          path: '/checkout',
          pageBuilder: (context, state) {
            return MaterialPage(
              child: ChangeNotifierProvider<CartProvider>(
                create: (_) => DummyCartProvider(),
                child: const CheckoutScreen(),
              ),
            );
          },
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }


  testWidgets('CheckoutScreen shows loading indicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Saat initState → loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('CheckoutScreen shows empty cart message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.textContaining('Keranjang kosong'), findsWidgets);
  });

  testWidgets('CheckoutScreen shows buy now product', (
    WidgetTester tester,
  ) async {
    final product = ProductModel(
      productId: 1,
      nama: 'Produk Test',
      harga: 10000,
      stok: 5,
      satuan: 'pcs',
      grade: 'A',
      gambar: null,
    );

    await tester.pumpWidget(
      createWidgetUnderTest(
        extra: {
          'type': 'buy_now',
          'product': product,
          'userId': 'user1',
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Produk Test'), findsWidgets);
    expect(find.textContaining('Metode Pembayaran'), findsWidgets);
  });
}
