import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/cart_model.dart';

void main() {
  group('CartModel Test', () {
    test('fromJson mengubah JSON menjadi CartModel dengan benar', () {
      final json = {
        'id': 1,
        'user_id': 'user123',
        'product_id': 10,
        'qty': 3,
        'created_at': '2025-01-01T10:00:00.000Z',
        'updated_at': '2025-01-02T12:00:00.000Z',
      };

      final cart = CartModel.fromJson(json);

      expect(cart.id, 1);
      expect(cart.userId, 'user123');
      expect(cart.productId, 10);
      expect(cart.qty, 3);
      expect(cart.createdAt, DateTime.parse('2025-01-01T10:00:00.000Z'));
      expect(cart.updatedAt, DateTime.parse('2025-01-02T12:00:00.000Z'));
    });

    test('toJson mengubah CartModel menjadi JSON dengan benar', () {
      final cart = CartModel(
        id: 2,
        userId: 'u456',
        productId: 20,
        qty: 5,
        createdAt: DateTime.parse('2025-02-01T09:00:00.000Z'),
        updatedAt: DateTime.parse('2025-02-02T11:00:00.000Z'),
      );

      final json = cart.toJson();

      expect(json['id'], 2);
      expect(json['user_id'], 'u456');
      expect(json['product_id'], 20);
      expect(json['qty'], 5);
      expect(json['created_at'], '2025-02-01T09:00:00.000Z');
      expect(json['updated_at'], '2025-02-02T11:00:00.000Z');
    });

    test('copyWith mengembalikan nilai baru jika diberikan parameter', () {
      final cart = CartModel(
        id: 3,
        userId: 'abc',
        productId: 99,
        qty: 1,
      );

      final updated = cart.copyWith(qty: 10);

      expect(updated.id, 3);
      expect(updated.userId, 'abc');
      expect(updated.productId, 99);
      expect(updated.qty, 10);
    });
  });
}
