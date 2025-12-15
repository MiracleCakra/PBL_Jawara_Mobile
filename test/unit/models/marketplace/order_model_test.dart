import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/models/marketplace/order_model.dart';

void main() {
  group('OrderModel Test', () {
    test('fromJson should parse correctly', () {
      final json = {
        'order_id': 1,
        'user_id': 'user123',
        'total_price': 50000,
        'order_status': 'pending',
        'alamat': 'Jl. Mawar 10',
        'total_qty': 3,
        'created_at': '2025-01-01T10:00:00.000Z',
        'updated_at': '2025-01-01T11:00:00.000Z',
      };

      final order = OrderModel.fromJson(json);

      expect(order.orderId, 1);
      expect(order.userId, 'user123');
      expect(order.totalPrice, 50000);
      expect(order.orderStatus, 'pending');
      expect(order.alamat, 'Jl. Mawar 10');
      expect(order.totalQty, 3);
      expect(order.createdAt, DateTime.parse('2025-01-01T10:00:00.000Z'));
      expect(order.updatedAt, DateTime.parse('2025-01-01T11:00:00.000Z'));
    });

    test('toJson should convert correctly', () {
      final order = OrderModel(
        orderId: 1,
        userId: 'user123',
        totalPrice: 50000,
        orderStatus: 'processing',
        alamat: 'Jl. Kenanga 5',
        totalQty: 2,
        createdAt: DateTime.parse('2025-01-02T09:00:00.000Z'),
        updatedAt: DateTime.parse('2025-01-02T10:00:00.000Z'),
      );

      final json = order.toJson();

      expect(json['order_id'], 1);
      expect(json['user_id'], 'user123');
      expect(json['total_price'], 50000);
      expect(json['order_status'], 'processing');
      expect(json['alamat'], 'Jl. Kenanga 5');
      expect(json['total_qty'], 2);
      expect(json['created_at'], '2025-01-02T09:00:00.000Z');
      expect(json['updated_at'], '2025-01-02T10:00:00.000Z');
    });

    test('copyWith should create updated object', () {
      final order = OrderModel(
        orderId: 1,
        userId: 'user123',
        totalPrice: 50000,
      );

      final updated = order.copyWith(totalPrice: 75000);

      expect(updated.orderId, 1);
      expect(updated.userId, 'user123');
      expect(updated.totalPrice, 75000);
    });

    test('displayStatus returns correct value', () {
      final order = OrderModel(orderStatus: 'shipped');
      expect(order.displayStatus, 'shipped');

      final empty = OrderModel();
      expect(empty.displayStatus, 'Unknown');
    });
  });
}
