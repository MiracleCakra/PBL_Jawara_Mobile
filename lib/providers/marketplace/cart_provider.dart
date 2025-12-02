import 'package:flutter/material.dart';
import '../../services/marketplace/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalItems => _cartItems.length;
  
  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) {
      final product = item['produk'];
      if (product != null) {
        final price = (product['harga'] as num?)?.toDouble() ?? 0.0;
        return sum + price;
      }
      return sum;
    });
  }

  Future<void> fetchCartWithProducts(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cartItems = await _cartService.getCartWithProducts(userId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToCart(String userId, int productId) async {
    try {
      await _cartService.addToCart(userId, productId);
      await fetchCartWithProducts(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromCart(int cartId, String userId) async {
    try {
      await _cartService.removeFromCart(cartId);
      await fetchCartWithProducts(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCart(String userId) async {
    try {
      await _cartService.clearCart(userId);
      _cartItems = [];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
