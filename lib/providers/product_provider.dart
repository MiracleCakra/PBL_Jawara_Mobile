import 'package:flutter/material.dart';
import '../models/marketplace/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final List<ProductModel> _products = ProductModel.getSampleProducts();

  List<ProductModel> get products => _products;

  void updateProduct(ProductModel updatedProduct) {
    int index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
