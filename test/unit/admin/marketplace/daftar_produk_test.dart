import 'package:SapaWarga_kel_2/models/marketplace/store_model.dart';
import 'package:SapaWarga_kel_2/screens/admin/marketplace/daftar_produk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      anonKey: 'dummy-anon-key',
    );
  });
  group('DaftarProdukTokoScreen Widget Test', () {
    testWidgets('Menampilkan judul dan nama toko', (WidgetTester tester) async {
      // Arrange
      final store = StoreModel(storeId: 1, nama: 'Toko Sukses');

      await tester.pumpWidget(
        MaterialApp(home: DaftarProdukTokoScreen(store: store)),
      );

      // Assert
      expect(find.text('Daftar Produk'), findsOneWidget);
      expect(find.text('Toko Sukses'), findsOneWidget);
    });

    testWidgets('Menampilkan loading saat memuat produk', (
      WidgetTester tester,
    ) async {
      final store = StoreModel(storeId: 1, nama: 'Toko Sukses');
      await tester.pumpWidget(
        MaterialApp(home: DaftarProdukTokoScreen(store: store)),
      );
      // Loading indicator harus muncul pertama kali
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Menampilkan pesan jika produk kosong', (
      WidgetTester tester,
    ) async {
      final store = StoreModel(storeId: 1, nama: 'Toko Sukses');
      await tester.pumpWidget(
        MaterialApp(home: DaftarProdukTokoScreen(store: store)),
      );
      // Tunggu hingga loading selesai
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Tidak ada produk.'), findsOneWidget);
    });
  });
}
