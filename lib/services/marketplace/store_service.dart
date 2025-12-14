import 'package:jawara_pintar_kel_5/models/marketplace/store_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          .update({'verifikasi': status, if (alasan != null) 'alasan': alasan})
          .eq('store_id', storeId);
    } catch (e) {
      throw Exception('Error updating verification status: $e');
    }
  }

  Future<void> deleteStore(int storeId) async {
    try {
      await _supabase.from('store').delete().eq('store_id', storeId);
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
        response.map((json) => StoreModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error fetching stores: $e');
    }
  }

  Future<List<StoreModel>> getPendingStores() async {
    try {
      final response = await _supabase
          .from('store')
          .select()
          .eq('verifikasi', 'Pending')
          .order('created_at', ascending: false);

      return List<StoreModel>.from(
        response.map((json) => StoreModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error fetching pending stores: $e');
    }
  }

  Future<List<StoreModel>> getStoresByStatus(String status) async {
    try {
      final response = await _supabase
          .from('store')
          .select()
          .eq('verifikasi', status)
          .order('created_at', ascending: false);

      return List<StoreModel>.from(
        response.map((json) => StoreModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error fetching stores by status: $e');
    }
  }

  Future<List<StoreModel>> searchStores({String? query, String? status}) async {
    try {
      var request = _supabase.from('store').select();

      // Filter by status if provided and not 'Semua'
      if (status != null && status != 'Semua') {
        request = request.eq('verifikasi', status);
      }

      // Search by name or owner if query provided
      if (query != null && query.isNotEmpty) {
        request = request.or('nama.ilike.%$query%,kontak.ilike.%$query%');
      }

      final response = await request.order('created_at', ascending: false);

      return List<StoreModel>.from(
        response.map((json) => StoreModel.fromJson(json)),
      );
    } catch (e) {
      throw Exception('Error searching stores: $e');
    }
  }

  Future<Map<String, dynamic>?> getWargaByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('warga')
          .select('nama, email')
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Error fetching warga: $e');
    }
  }

  /// Nonaktifkan toko oleh admin dengan alasan
  Future<void> deactivateStoreByAdmin(int storeId, String alasan) async {
    try {
      await _supabase
          .from('store')
          .update({
            'verifikasi': 'Nonaktif',
            'deactivated_by': 'admin',
            'alasan': alasan,
          })
          .eq('store_id', storeId);
    } catch (e) {
      throw Exception('Error deactivating store: $e');
    }
  }

  /// Nonaktifkan toko oleh pemilik sendiri
  Future<void> deactivateStoreByOwner(int storeId) async {
    try {
      await _supabase
          .from('store')
          .update({
            'verifikasi': 'Nonaktif',
            'deactivated_by': 'owner',
            'alasan': null,
          })
          .eq('store_id', storeId);
    } catch (e) {
      throw Exception('Error deactivating store: $e');
    }
  }

  /// Aktifkan kembali toko (untuk owner yang nonaktif sendiri)
  Future<void> reactivateStore(int storeId) async {
    try {
      await _supabase
          .from('store')
          .update({
            'verifikasi': 'Diterima',
            'deactivated_by': null,
            'alasan': null,
          })
          .eq('store_id', storeId);
    } catch (e) {
      throw Exception('Error reactivating store: $e');
    }
  }
}
