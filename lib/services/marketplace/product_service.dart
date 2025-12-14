import 'dart:io';

import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload image to Supabase Storage and return public URL
  Future<String?> uploadProductImage(File imageFile, int storeId) async {
    try {
      print('🔄 Starting image upload for store $storeId');

      final fileName =
          '${storeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$fileName'; // Simpan langsung di root bucket products

      print('📁 File name: $fileName');
      print('📂 Upload path: $path');

      // Upload to Supabase Storage bucket 'products'
      final uploadResponse = await _supabase.storage
          .from('products')
          .upload(path, imageFile);

      print('✅ Upload success: $uploadResponse');

      // Get public URL
      final publicUrl = _supabase.storage.from('products').getPublicUrl(path);

      print('🔗 Public URL: $publicUrl');

      return publicUrl;
    } catch (e, stackTrace) {
      print('❌ Error uploading image: $e');
      print('📋 Stack trace: $stackTrace');

      // Check specific error types
      if (e.toString().contains('404')) {
        print(
          '⚠️ Bucket "products" tidak ditemukan. Buat bucket di Supabase Storage!',
        );
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        print('⚠️ Permission denied. Setup Storage Policies di Supabase!');
      } else if (e.toString().contains('409')) {
        print('⚠️ File sudah ada. Gunakan nama file yang berbeda.');
      }

      return null;
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .order('created_at', ascending: false);

      return List<ProductModel>.from(
        response.map((json) => ProductModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<ProductModel?> getProductById(int productId) async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .eq('product_id', productId)
          .maybeSingle();

      if (response == null) return null;
      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  Future<List<ProductModel>> getProductsByStore(int storeId) async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .eq('store_id', storeId)
          .gt('stok', 0)
          .order('created_at', ascending: false);

      return List<ProductModel>.from(
        response.map((json) => ProductModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error fetching store products: $e');
    }
  }

  Future<List<ProductModel>> searchProducts(String keyword) async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .ilike('nama', '%$keyword%')
          .order('created_at', ascending: false);

      return List<ProductModel>.from(
        response.map((json) => ProductModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  Future<List<ProductModel>> getProductsByGrade(String grade) async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .eq('grade', grade)
          .order('created_at', ascending: false);

      return List<ProductModel>.from(
        response.map((json) => ProductModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error fetching products by grade: $e');
    }
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _supabase
          .from('produk')
          .insert(product.toJson())
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating product: $e');
    }
  }

  Future<ProductModel> updateProduct(
    int productId,
    ProductModel product,
  ) async {
    try {
      final response = await _supabase
          .from('produk')
          .update(product.toJson())
          .eq('product_id', productId)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  Future<void> updateStock(int productId, int newStock) async {
    try {
      if (newStock <= 0) {
        // Check if product has orders before deleting
        final orderItems = await _supabase
            .from('order_item')
            .select('id')
            .eq('product_id', productId)
            .limit(1);

        if (orderItems.isEmpty) {
          // No orders, delete the product
          await deleteProduct(productId);
        } else {
          // Has orders, just set stock to 0
          await _supabase
              .from('produk')
              .update({'stok': 0})
              .eq('product_id', productId);
        }
      } else {
        await _supabase
            .from('produk')
            .update({'stok': newStock})
            .eq('product_id', productId);
      }
    } catch (e) {
      throw Exception('Error updating stock: $e');
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      // Check if product has orders
      final orderItems = await _supabase
          .from('order_item')
          .select('id')
          .eq('product_id', productId)
          .limit(1);

      if (orderItems.isNotEmpty) {
        // Product has orders, just set stock to 0
        await _supabase
            .from('produk')
            .update({'stok': 0})
            .eq('product_id', productId);
        throw Exception('Produk memiliki riwayat pesanan, stok diatur ke 0');
      } else {
        // No orders, safe to delete
        await _supabase.from('produk').delete().eq('product_id', productId);
      }
    } catch (e) {
      if (e.toString().contains('Produk memiliki riwayat pesanan')) {
        rethrow;
      }
      throw Exception('Error deleting product: $e');
    }
  }

  Future<List<ProductModel>> getLowStockProducts(int storeId) async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .eq('store_id', storeId)
          .lt('stok', 5)
          .order('stok', ascending: true);

      return List<ProductModel>.from(
        response.map((json) => ProductModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error fetching low stock products: $e');
    }
  }

  Future<List<ProductModel>> getPopularProducts({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return List<ProductModel>.from(
        response.map((json) => ProductModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error fetching popular products: $e');
    }
  }

  // ==================== ADMIN MANAGEMENT METHODS ====================

  /// Get all products by store (for admin monitoring)
  Future<List<ProductModel>> getProductsByStoreForAdmin(int storeId) async {
    try {
      final response = await _supabase
          .from('produk')
          .select()
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      return List<ProductModel>.from(
        response.map((json) => ProductModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error fetching products for admin: $e');
    }
  }

  /// Delete product by admin (for inappropriate products)
  Future<void> deleteProductByAdmin(int productId) async {
    try {
      // Admin can force delete without checking order history
      await _supabase.from('produk').delete().eq('product_id', productId);

      print('✅ Product $productId deleted by admin');
    } catch (e) {
      throw Exception('Error deleting product by admin: $e');
    }
  }

  /// Get product statistics for a store
  Future<Map<String, dynamic>> getStoreProductStats(int storeId) async {
    try {
      final products = await getProductsByStoreForAdmin(storeId);

      final totalProducts = products.length;
      final activeProducts = products.where((p) => (p.stok ?? 0) > 0).length;
      final lowStockProducts = products
          .where((p) => (p.stok ?? 0) > 0 && (p.stok ?? 0) < 5)
          .length;
      final outOfStockProducts = products
          .where((p) => (p.stok ?? 0) == 0)
          .length;

      return {
        'total': totalProducts,
        'active': activeProducts,
        'lowStock': lowStockProducts,
        'outOfStock': outOfStockProducts,
      };
    } catch (e) {
      throw Exception('Error getting product stats: $e');
    }
  }
}
