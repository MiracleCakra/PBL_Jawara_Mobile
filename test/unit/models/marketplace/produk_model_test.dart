import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/models/marketplace/product_model.dart';

void main() {
  group('ProductModel Test', () {
    test('fromJson should parse correctly', () {
      final json = {
        'product_id': 10,
        'nama': 'Sayur Kangkung',
        'deskripsi': 'Sayur segar dari kebun warga',
        'harga': 5000,
        'stok': 20,
        'gambar': 'https://example.com/kangkung.jpg',
        'grade': 'A',
        'satuan': 'ikat',
        'store_id': 3,
        'created_at': '2025-01-01T08:00:00.000Z',
      };

      final product = ProductModel.fromJson(json);

      expect(product.productId, 10);
      expect(product.nama, 'Sayur Kangkung');
      expect(product.deskripsi, 'Sayur segar dari kebun warga');
      expect(product.harga, 5000);
      expect(product.stok, 20);
      expect(product.gambar, 'https://example.com/kangkung.jpg');
      expect(product.grade, 'A');
      expect(product.satuan, 'ikat');
      expect(product.storeId, 3);
      expect(product.createdAt, DateTime.parse('2025-01-01T08:00:00.000Z'));
    });

    test('toJson should convert correctly', () {
      final product = ProductModel(
        productId: 10,
        nama: 'Telur Ayam Kampung',
        deskripsi: 'Telur segar kualitas premium',
        harga: 2500,
        stok: 50,
        gambar: 'https://example.com/telur.jpg',
        grade: 'A',
        satuan: 'pcs',
        storeId: 5,
        createdAt: DateTime.parse('2025-01-02T07:00:00.000Z'),
      );

      final json = product.toJson();

      expect(json['product_id'], 10);
      expect(json['nama'], 'Telur Ayam Kampung');
      expect(json['deskripsi'], 'Telur segar kualitas premium');
      expect(json['harga'], 2500);
      expect(json['stok'], 50);
      expect(json['gambar'], 'https://example.com/telur.jpg');
      expect(json['grade'], 'A');
      expect(json['satuan'], 'pcs');
      expect(json['store_id'], 5);
      expect(json['created_at'], '2025-01-02T07:00:00.000Z');
    });

    test('copyWith should update only provided fields', () {
      final product = ProductModel(
        productId: 10,
        nama: 'Cabai Merah',
        harga: 15000,
        stok: 10,
      );

      final updated = product.copyWith(
        harga: 18000,
        stok: 8,
      );

      expect(updated.productId, 10);
      expect(updated.nama, 'Cabai Merah');
      expect(updated.harga, 18000);
      expect(updated.stok, 8);
    });
  });
}
