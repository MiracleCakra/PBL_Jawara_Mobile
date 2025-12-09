import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/store_model.dart';

void main() {
  group('StoreModel Test', () {
    test('fromJson should parse JSON correctly', () {
      final json = {
        'store_id': 1,
        'nama': 'Toko Sayur Sehat',
        'deskripsi': 'Menjual sayuran segar setiap hari',
        'alamat': 'Jl. Mawar No. 12',
        'logo': 'https://example.com/logo.png',
        'user_id': 'user123',
        'kontak': '08123456789',
        'verifikasi': 'approved',
        'alasan': 'Valid',
        'created_at': '2025-01-10T08:00:00Z',
      };

      final store = StoreModel.fromJson(json);

      expect(store.storeId, 1);
      expect(store.nama, 'Toko Sayur Sehat');
      expect(store.deskripsi, 'Menjual sayuran segar setiap hari');
      expect(store.alamat, 'Jl. Mawar No. 12');
      expect(store.logo, 'https://example.com/logo.png');
      expect(store.userId, 'user123');
      expect(store.kontak, '08123456789');
      expect(store.verifikasi, 'approved');
      expect(store.alasan, 'Valid');
      expect(store.createdAt, DateTime.parse('2025-01-10T08:00:00Z'));
    });

    test('toJson should convert model to JSON correctly', () {
      final store = StoreModel(
        storeId: 1,
        nama: 'Toko Sayur Sehat',
        deskripsi: 'Menjual sayuran segar setiap hari',
        alamat: 'Jl. Mawar No. 12',
        logo: 'https://example.com/logo.png',
        userId: 'user123',
        kontak: '08123456789',
        verifikasi: 'approved',
        alasan: 'Valid',
        createdAt: DateTime.parse('2025-01-10T08:00:00Z'),
      );

      final json = store.toJson();

      expect(json['store_id'], 1);
      expect(json['nama'], 'Toko Sayur Sehat');
      expect(json['deskripsi'], 'Menjual sayuran segar setiap hari');
      expect(json['alamat'], 'Jl. Mawar No. 12');
      expect(json['logo'], 'https://example.com/logo.png');
      expect(json['user_id'], 'user123');
      expect(json['kontak'], '08123456789');
      expect(json['verifikasi'], 'approved');
      expect(json['alasan'], 'Valid');
      expect(json['created_at'], '2025-01-10T08:00:00.000Z');
    });

    test('copyWith should update only provided fields', () {
      final original = StoreModel(
        storeId: 1,
        nama: 'Toko Hijau',
        deskripsi: 'Sayur segar',
        alamat: 'Jl. Kenanga 5',
        logo: 'logo1.png',
        userId: 'user001',
        kontak: '0812345',
        verifikasi: 'pending',
        alasan: null,
        createdAt: DateTime.parse('2025-01-10T08:00:00Z'),
      );

      final updated = original.copyWith(
        nama: 'Toko Hijau Baru',
        verifikasi: 'approved',
      );

      expect(updated.nama, 'Toko Hijau Baru');
      expect(updated.verifikasi, 'approved');

      // Field lainnya harus tetap sama
      expect(updated.storeId, original.storeId);
      expect(updated.deskripsi, original.deskripsi);
      expect(updated.alamat, original.alamat);
      expect(updated.logo, original.logo);
      expect(updated.userId, original.userId);
      expect(updated.kontak, original.kontak);
      expect(updated.createdAt, original.createdAt);
    });

    test('copyWith without arguments should keep original data', () {
      final original = StoreModel(
        storeId: 1,
        nama: 'Toko A',
        deskripsi: 'Deskripsi',
        alamat: 'Alamat',
        logo: 'logo.png',
        userId: 'user123',
        kontak: '0812',
        verifikasi: 'pending',
        alasan: null,
        createdAt: DateTime.parse('2025-01-10T08:00:00Z'),
      );

      final copied = original.copyWith();

      expect(copied.storeId, original.storeId);
      expect(copied.nama, original.nama);
      expect(copied.deskripsi, original.deskripsi);
      expect(copied.alamat, original.alamat);
      expect(copied.logo, original.logo);
      expect(copied.userId, original.userId);
      expect(copied.kontak, original.kontak);
      expect(copied.verifikasi, original.verifikasi);
      expect(copied.createdAt, original.createdAt);
    });
  });
}
