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
      await _supabase
          .from('produk')
          .update({'stok': newStock})
          .eq('product_id', productId);
    } catch (e) {
      throw Exception('Error updating stock: $e');
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await _supabase.from('produk').delete().eq('product_id', productId);
    } catch (e) {
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
}
