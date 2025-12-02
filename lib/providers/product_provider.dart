import 'package:flutter/material.dart';

import '../models/marketplace/product_model.dart';
import '../services/marketplace/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllProducts() async {
    print('DEBUG ProductProvider: Starting fetchAllProducts');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.getAllProducts();
      print('DEBUG ProductProvider: Fetched ${_products.length} products');
      if (_products.isNotEmpty) {
        print('DEBUG ProductProvider: First product: ${_products.first.nama}');
      }
    } catch (e) {
      print('ERROR ProductProvider: $e');
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProductsByStore(int storeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.getProductsByStore(storeId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchProducts(String keyword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.searchProducts(keyword);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> filterByGrade(String grade) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _productService.getProductsByGrade(grade);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ProductModel?> createProduct(ProductModel product) async {
    try {
      final newProduct = await _productService.createProduct(product);
      _products.insert(0, newProduct);
      notifyListeners();
      return newProduct;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateProduct(int productId, ProductModel product) async {
    try {
      final updated = await _productService.updateProduct(productId, product);
      int index = _products.indexWhere((p) => p.productId == productId);
      if (index != -1) {
        _products[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStock(int productId, int newStock) async {
    try {
      await _productService.updateStock(productId, newStock);
      int index = _products.indexWhere((p) => p.productId == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(stok: newStock);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      await _productService.deleteProduct(productId);
      _products.removeWhere((p) => p.productId == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  ProductModel? getProductById(int productId) {
    try {
      return _products.firstWhere((p) => p.productId == productId);
    } catch (_) {
      return null;
    }
  }
}
