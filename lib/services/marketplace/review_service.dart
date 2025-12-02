import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/ReviewModel.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ReviewModel>> getReviewsByProduct(int productId) async {
    try {
      final response = await _supabase
          .from('review')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      
      return List<ReviewModel>.from(
          response.map((json) => ReviewModel.fromJson(json)));
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    try {
      final response = await _supabase
          .from('review')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<ReviewModel>.from(
          response.map((json) => ReviewModel.fromJson(json)));
    } catch (e) {
      throw Exception('Error fetching user reviews: $e');
    }
  }

  Future<double> getAverageRating(int productId) async {
    try {
      final response = await _supabase
          .from('review')
          .select('rating')
          .eq('product_id', productId);
      
      if (response.isEmpty) return 0.0;
      
      final List<int> ratings = (response as List)
          .map((e) => e['rating'] as int)
          .toList();
      
      final sum = ratings.fold<int>(0, (a, b) => a + b);
      return sum / ratings.length;
    } catch (e) {
      throw Exception('Error calculating average rating: $e');
    }
  }

  Future<ReviewModel> createReview(ReviewModel review) async {
    try {
      final response = await _supabase
          .from('review')
          .insert(review.toJson())
          .select()
          .single();
      
      return ReviewModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating review: $e');
    }
  }

  Future<ReviewModel> updateReview(int reviewId, ReviewModel review) async {
    try {
      final response = await _supabase
          .from('review')
          .update(review.toJson())
          .eq('review_id', reviewId)
          .select()
          .single();
      
      return ReviewModel.fromJson(response);
    } catch (e) {
      throw Exception('Error updating review: $e');
    }
  }

  Future<void> addSellerReply(int reviewId, String reply) async {
    try {
      await _supabase
          .from('review')
          .update({'review_reply': reply})
          .eq('review_id', reviewId);
    } catch (e) {
      throw Exception('Error adding seller reply: $e');
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      await _supabase
          .from('review')
          .delete()
          .eq('review_id', reviewId);
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getReviewsWithProductInfo(int productId) async {
    try {
      final response = await _supabase
          .from('review')
          .select('*, produk(*)')
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching reviews with product info: $e');
    }
  }

  // Get reviews with user info (warga nama)
  Future<List<Map<String, dynamic>>> getReviewsWithUserInfo(int productId) async {
    try {
      final response = await _supabase
          .from('review')
          .select('*, warga(nama)')
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching reviews with user info: $e');
    }
  }

  // Check if user already reviewed a product
  Future<ReviewModel?> getUserReviewForProduct(String userId, int productId) async {
    try {
      final response = await _supabase
          .from('review')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();
      
      if (response == null) return null;
      return ReviewModel.fromJson(response);
    } catch (e) {
      throw Exception('Error checking user review: $e');
    }
  }

  // Get reviews for store owner (all products from their store)
  Future<List<Map<String, dynamic>>> getReviewsByStore(int storeId) async {
    try {
      final response = await _supabase
          .from('review')
          .select('*, produk!inner(store_id, nama), warga(nama)')
          .eq('produk.store_id', storeId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching store reviews: $e');
    }
  }

  // Update review reply and updated_at
  Future<void> updateReviewReply(int reviewId, String reply) async {
    try {
      await _supabase
          .from('review')
          .update({
            'review_reply': reply,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('review_id', reviewId);
    } catch (e) {
      throw Exception('Error updating review reply: $e');
    }
  }
}
