import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/models/marketplace/marketplace_model.dart';

void main() {
  group('ActiveProductItem Test', () {
    test('Constructor memberikan nilai default yang benar', () {
      final item = ActiveProductItem(
        id: '1',
        productName: 'Produk A',
        sellerName: 'Toko B',
        category: 'Sayur',
        imageUrl: 'http://example.com/img.png',
      );

      expect(item.status, 'Pending');
      expect(item.timeUploaded, 'Baru saja');
      expect(item.cvResult, 'Tidak ada hasil CV');
      expect(item.cvConfidence, 0.0);
      expect(item.description.isNotEmpty, true);
      expect(item.stock, 50);
      expect(item.price, 15000.0);
    });

    test('copyWith hanya mengubah field yang diberikan', () {
      final item = ActiveProductItem(
        id: '1',
        productName: 'Produk A',
        sellerName: 'Toko B',
        category: 'Sayur',
        imageUrl: 'http://example.com/img.png',
      );

      final updated = item.copyWith(status: 'Approved');

      expect(updated.status, 'Approved');
      expect(updated.id, item.id);
      expect(updated.productName, item.productName);
      expect(updated.sellerName, item.sellerName);
    });
  });

  group('Debouncer Test', () {
    test('Debouncer menjalankan action setelah delay', () async {
      int counter = 0;
      final debouncer = Debouncer(milliseconds: 200);

      debouncer.run(() {
        counter++;
      });

      // Belum jalan sebelum delay
      expect(counter, 0);

      await Future.delayed(const Duration(milliseconds: 250));

      // Baru jalan setelah delay
      expect(counter, 1);
    });

    test('Debouncer hanya menjalankan action terakhir (cancel previous)', () async {
      int counter = 0;
      final debouncer = Debouncer(milliseconds: 200);

      debouncer.run(() => counter++); // 1st
      debouncer.run(() => counter++); // 2nd overrides
      debouncer.run(() => counter++); // 3rd overrides

      expect(counter, 0); // sebelum delay

      await Future.delayed(const Duration(milliseconds: 250));

      expect(counter, 1); // hanya action terakhir yang dijalankan
    });
  });
}
