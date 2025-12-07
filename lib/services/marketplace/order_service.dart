import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/order_model.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/order_item_model.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<OrderModel>> getOrdersByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('order')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<OrderModel>.from(
        response.map((json) => OrderModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<OrderModel?> getOrderById(int orderId) async {
    try {
      final response = await _supabase
          .from('order')
          .select()
          .eq('order_id', orderId)
          .maybeSingle();

      if (response == null) return null;
      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  Future<List<OrderItemModel>> getOrderItems(int orderId) async {
    try {
      final response = await _supabase
          .from('order_item')
          .select()
          .eq('order_id', orderId);

      return List<OrderItemModel>.from(
        response.map((json) => OrderItemModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error fetching order items: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOrderWithItems(int orderId) async {
    try {
      final response = await _supabase
          .from('order_item')
          .select('*, produk(*)')
          .eq('order_id', orderId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching order with items: $e');
    }
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response = await _supabase
          .from('order')
          .insert(order.toJson())
          .select()
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  Future<OrderItemModel> createOrderItem(OrderItemModel orderItem) async {
    try {
      final response = await _supabase
          .from('order_item')
          .insert(orderItem.toJson())
          .select()
          .single();

      return OrderItemModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating order item: $e');
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final response = await _supabase
          .from('order')
          .update({'order_status': newStatus})
          .eq('order_id', orderId)
          .select();

      print('Update status response: $response');
    } catch (e) {
      print('Error detail: $e');
      throw Exception('Error updating order status: $e');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    try {
      await _supabase.from('order').delete().eq('order_id', orderId);
    } catch (e) {
      throw Exception('Error deleting order: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getOrdersByStore(int storeId) async {
    try {
      final response = await _supabase
          .from('order_item')
          .select('*, produk!inner(store_id), order!inner(*)')
          .eq('produk.store_id', storeId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching store orders: $e');
    }
  }

  /// Reduce product stock after purchase
  Future<void> reduceProductStock(int productId, int quantity) async {
    try {
      // Get current stock
      final productResponse = await _supabase
          .from('produk')
          .select('stok')
          .eq('product_id', productId)
          .maybeSingle();

      if (productResponse == null) {
        throw Exception('Product not found');
      }

      final currentStock = productResponse['stok'] as int? ?? 0;
      final newStock = currentStock - quantity;

      // Ensure stock doesn't go below 0
      if (newStock < 0) {
        throw Exception('Insufficient stock');
      }

      // Update stock in database
      await _supabase
          .from('produk')
          .update({'stok': newStock})
          .eq('product_id', productId);

      print('Stock reduced for product $productId: $currentStock -> $newStock');
    } catch (e) {
      throw Exception('Error reducing stock: $e');
    }
  }
}
