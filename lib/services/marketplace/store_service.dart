import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/store_model.dart';

class StoreService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<StoreModel?> getStoreById(int storeId) async {
    try {
      final response = await _supabase
          .from('store')
          .select()
          .eq('store_id', storeId)
          .maybeSingle();
      
      if (response == null) return null;
      return StoreModel.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching store: $e');
    }
  }

  Future<StoreModel?> getStoreByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('store')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) return null;
      return StoreModel.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching store: $e');
    }
  }

  Future<StoreModel> createStore(StoreModel store) async {
    try {
      final response = await _supabase
          .from('store')
          .insert(store.toJson())
          .select()
          .single();
      
      return StoreModel.fromJson(response);
    } catch (e) {
      throw Exception('Error creating store: $e');
    }
  }

  Future<StoreModel> updateStore(int storeId, StoreModel store) async {
    try {
      final response = await _supabase
          .from('store')
          .update(store.toJson())
          .eq('store_id', storeId)
          .select()
          .single();
      
      return StoreModel.fromJson(response);
    } catch (e) {
      throw Exception('Error updating store: $e');
    }
  }

  Future<void> updateVerificationStatus(
    int storeId,
    String status, {
    String? alasan,
  }) async {
    try {
      await _supabase
          .from('store')
          .update({
            'verifikasi': status,
            if (alasan != null) 'alasan': alasan,
          })
          .eq('store_id', storeId);
    } catch (e) {
      throw Exception('Error updating verification status: $e');
    }
  }

  Future<void> deleteStore(int storeId) async {
    try {
      await _supabase
          .from('store')
          .delete()
          .eq('store_id', storeId);
    } catch (e) {
      throw Exception('Error deleting store: $e');
    }
  }

  Future<List<StoreModel>> getAllStores() async {
    try {
      final response = await _supabase
          .from('store')
          .select()
          .order('created_at', ascending: false);
      
      return List<StoreModel>.from(
          response.map((json) => StoreModel.fromJson(json)));
    } catch (e) {
      throw Exception('Error fetching stores: $e');
    }
  }

  Future<List<StoreModel>> getPendingStores() async {
    try {
      final response = await _supabase
          .from('store')
          .select()
          .eq('verifikasi', 'pending')
          .order('created_at', ascending: false);
      
      return List<StoreModel>.from(
          response.map((json) => StoreModel.fromJson(json)));
    } catch (e) {
      throw Exception('Error fetching pending stores: $e');
    }
  }
}
