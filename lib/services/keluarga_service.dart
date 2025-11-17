import 'package:jawara_pintar_kel_5/models/keluarga_model.dart' as k_model;
import 'package:supabase_flutter/supabase_flutter.dart';

class KeluargaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch semua keluarga dengan data kepala keluarga
  Future<List<k_model.Keluarga>> getAllKeluarga() async {
    try {
      final response = await _supabase
          .from('keluarga')
          .select('*, warga:kepala_keluarga_id(*)')
          .order('nama_keluarga');

      return List<k_model.Keluarga>.from(
          response.map((json) => k_model.Keluarga.fromJson(json)));
    } catch (e) {
      throw Exception('Error fetching keluarga: $e');
    }
  }

  /// Create keluarga baru
  Future<k_model.Keluarga> createKeluarga(k_model.Keluarga keluarga) async {
    try {
      final response = await _supabase
          .from('keluarga')
          .insert(keluarga.toJson())
          .select('*, warga:kepala_keluarga_id(*)')
          .single();

      return k_model.Keluarga.fromJson(response);
    } catch (e) {
      throw Exception('Error creating keluarga: $e');
    }
  }

  /// Update keluarga
  Future<k_model.Keluarga> updateKeluarga(String id, k_model.Keluarga keluarga) async {
    try {
      final response = await _supabase
          .from('keluarga')
          .update(keluarga.toJson())
          .eq('id', id)
          .select('*, warga:kepala_keluarga_id(*)')
          .single();

      return k_model.Keluarga.fromJson(response);
    } catch (e) {
      throw Exception('Error updating keluarga: $e');
    }
  }

  /// Delete keluarga
  Future<void> deleteKeluarga(String id) async {
    try {
      await _supabase.from('keluarga').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error deleting keluarga: $e');
    }
  }
}
