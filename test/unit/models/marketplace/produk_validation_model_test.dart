import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_validation_model.dart';

void main() {
  group('ProductValidation Model Test', () {
    test('should create a ProductValidation object correctly', () {
      final product = ProductValidation(
        id: 'p001',
        productName: 'Tomat Segar',
        sellerName: 'Pak Budi',
        category: 'Sayuran',
        imageUrl: 'https://example.com/tomat.jpg',
        timeUploaded: '10 menit lalu',
        cvResult: 'Segar',
        cvConfidence: 0.92,
        status: 'Pending',
        description: 'Tomat merah segar dari kebun lokal',
      );

      expect(product.id, 'p001');
      expect(product.productName, 'Tomat Segar');
      expect(product.sellerName, 'Pak Budi');
      expect(product.category, 'Sayuran');
      expect(product.imageUrl, 'https://example.com/tomat.jpg');
      expect(product.timeUploaded, '10 menit lalu');
      expect(product.cvResult, 'Segar');
      expect(product.cvConfidence, 0.92);
      expect(product.status, 'Pending');
      expect(product.description, 'Tomat merah segar dari kebun lokal');
    });

    test('copyWith should update only status field', () {
      final original = ProductValidation(
        id: 'p002',
        productName: 'Cabai Rawit',
        sellerName: 'Bu Siti',
        category: 'Sayuran',
        imageUrl: 'https://example.com/cabai.jpg',
        timeUploaded: 'Baru saja',
        cvResult: 'Layak Jual',
        cvConfidence: 0.85,
        status: 'Pending',
        description: 'Cabai rawit pedas segar',
      );

      final updated = original.copyWith(status: 'Approved');

      expect(updated.id, original.id);
      expect(updated.productName, original.productName);
      expect(updated.sellerName, original.sellerName);
      expect(updated.category, original.category);
      expect(updated.imageUrl, original.imageUrl);
      expect(updated.timeUploaded, original.timeUploaded);
      expect(updated.cvResult, original.cvResult);
      expect(updated.cvConfidence, original.cvConfidence);
      expect(updated.description, original.description);

      // Only status changes
      expect(updated.status, 'Approved');
    });

    test('copyWith without parameter should keep original values', () {
      final product = ProductValidation(
        id: 'p003',
        productName: 'Wortel Organik',
        sellerName: 'Pak Hasan',
        category: 'Sayuran',
        imageUrl: 'https://example.com/wortel.jpg',
        timeUploaded: '5 menit lalu',
        cvResult: 'Bagus',
        cvConfidence: 0.95,
        status: 'Pending',
        description: 'Wortel segar dari kebun organik',
      );

      final copied = product.copyWith();

      expect(copied.status, 'Pending'); // tetap sama
      expect(copied.id, product.id);
      expect(copied.productName, product.productName);
    });
  });
}
