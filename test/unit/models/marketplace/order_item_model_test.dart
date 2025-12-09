import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/order_item_model.dart';

void main() {
  group('OrderItemModel Test', () {
    test('fromJson mengubah JSON menjadi model dengan benar', () {
      final json = {
        'id': 1,
        'product_id': 10,
        'qty': 3,
        'order_id': 99,
        'created_at': '2025-03-01T10:00:00.000Z',
      };

      final item = OrderItemModel.fromJson(json);

      expect(item.id, 1);
      expect(item.productId, 10);
      expect(item.qty, 3);
      expect(item.orderId, 99);
      expect(item.createdAt, DateTime.parse('2025-03-01T10:00:00.000Z'));
    });

    test('toJson mengubah model menjadi JSON dengan benar', () {
      final item = OrderItemModel(
        id: 2,
        productId: 20,
        qty: 5,
        orderId: 100,
        createdAt: DateTime.parse('2025-03-02T08:00:00.000Z'),
      );

      final json = item.toJson();

      expect(json['id'], 2);
      expect(json['product_id'], 20);
      expect(json['qty'], 5);
      expect(json['order_id'], 100);
      expect(json['created_at'], '2025-03-02T08:00:00.000Z');
    });

    test('copyWith hanya mengganti field yang diberikan', () {
      final item = OrderItemModel(
        id: 3,
        productId: 33,
        qty: 7,
        orderId: 200,
      );

      final updated = item.copyWith(qty: 10);

      expect(updated.qty, 10);
      expect(updated.id, 3);
      expect(updated.productId, 33);
      expect(updated.orderId, 200);
      expect(updated.createdAt, item.createdAt);
    });
  });
}
