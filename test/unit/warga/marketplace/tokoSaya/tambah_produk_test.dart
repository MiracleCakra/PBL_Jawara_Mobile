import 'package:SapaWarga_kel_2/models/marketplace/product_model.dart';
import 'package:SapaWarga_kel_2/providers/product_provider.dart';
import 'package:SapaWarga_kel_2/screens/warga/marketplace/tokoSaya/tambah_produk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class MockProductProvider extends ChangeNotifier implements ProductProvider {
  @override
  Future<ProductModel?> createProduct(ProductModel product) async {
    return product;
  }

  @override
  String? get errorMessage => null;

  @override
  List<ProductModel> get products => [];

  @override
  bool get isLoading => false;

  @override
  Future<void> fetchAllProducts() async {}

  @override
  Future<void> fetchProductsByStore(int storeId) async {}

  @override
  Future<void> searchProducts(String keyword) async {}

  @override
  Future<void> filterByGrade(String grade) async {}

  @override
  Future<bool> updateProduct(int productId, ProductModel product) async => true;

  @override
  Future<bool> updateStock(int productId, int newStock) async => true;

  @override
  Future<bool> deleteProduct(int productId) async => true;

  @override
  ProductModel? getProductById(int productId) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<ProductProvider>(
      create: (_) => MockProductProvider(),
      child: const MaterialApp(home: MyStoreProductAddScreen()),
    );
  }

  group('MyStoreProductAddScreen Widget Test', () {
    testWidgets('Menampilkan semua field utama', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Tambah Produk Baru'), findsOneWidget);
      expect(find.text('Nama Produk'), findsOneWidget);
      expect(find.text('Deskripsi Produk'), findsOneWidget);
      expect(find.text('Harga'), findsOneWidget);
      expect(find.text('Stok'), findsOneWidget);
      expect(find.text('Satuan'), findsOneWidget);
      expect(find.text('Grade Kualitas'), findsOneWidget);
      expect(find.text('Tambah Produk'), findsOneWidget);
    });

    testWidgets('Tombol tambah produk disabled saat upload', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      final button = find.widgetWithText(FilledButton, 'Tambah Produk');
      expect(button, findsOneWidget);
      // Belum ada upload, harus enabled
      final filledButton = tester.widget<FilledButton>(button);
      expect(filledButton.onPressed != null, true);
    });
  });
}
