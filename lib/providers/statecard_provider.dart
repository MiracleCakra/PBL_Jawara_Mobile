import 'package:flutter/material.dart';
import '../models/marketplace/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<ProductModel> _items = [];

  List<ProductModel> get items => _items;

  void addToCart(ProductModel product) {
    _items.add(product);
    notifyListeners();
  }

  void removeFromCart(ProductModel product) {
    _items.remove(product);
    notifyListeners();
  }

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.harga!);

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
