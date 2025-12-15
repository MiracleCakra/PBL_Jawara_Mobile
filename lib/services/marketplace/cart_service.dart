import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:SapaWarga_kel_2/models/marketplace/cart_model.dart';

class CartService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CartModel>> getCartByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('cart')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<CartModel>.from(
          response.map((json) => CartModel.fromJson(json)));
    } catch (e) {
      throw Exception('Error fetching cart: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCartWithProducts(String userId) async {
    try {
      final response = await _supabase
          .from('cart')
          .select('*, produk(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching cart with products: $e');
    }
  }

  Future<CartModel> addToCart(String userId, int productId) async {
    try {
      final existing = await _supabase
          .from('cart')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        // If product already in cart, increment qty
        final currentQty = existing['qty'] as int? ?? 1;
        final updatedResponse = await _supabase
            .from('cart')
            .update({'qty': currentQty + 1})
            .eq('id', existing['id'])
            .select()
            .single();
        return CartModel.fromJson(updatedResponse);
      }

      final response = await _supabase
          .from('cart')
          .insert({
            'user_id': userId,
            'product_id': productId,
            'qty': 1,
          })
          .select()
          .single();
      
      return CartModel.fromJson(response);
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  Future<void> removeFromCart(int cartId) async {
    try {
      await _supabase
          .from('cart')
          .delete()
          .eq('id', cartId);
    } catch (e) {
      throw Exception('Error removing from cart: $e');
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      await _supabase
          .from('cart')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Error clearing cart: $e');
    }
  }

  Future<void> updateCartTimestamp(int cartId) async {
    try {
      await _supabase
          .from('cart')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', cartId);
    } catch (e) {
      throw Exception('Error updating cart: $e');
    }
  }
}
