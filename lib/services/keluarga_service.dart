import 'package:jawara_pintar_kel_5/models/keluarga/keluarga_model.dart' as k_model;
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

  /// Fetch keluarga berdasarkan email warga
  Future<k_model.Keluarga?> getKeluargaByEmail(String email) async {
    try {
      // 1. Cari warga berdasarkan email untuk dapat keluarga_id
      final wargaResponse = await _supabase
          .from('warga')
          .select('keluarga_id')
          .eq('email', email)
          .maybeSingle();

      if (wargaResponse == null || wargaResponse['keluarga_id'] == null) {
        return null;
      }

      final String keluargaId = wargaResponse['keluarga_id'];

      // 2. Ambil detail keluarga berdasarkan ID
      final response = await _supabase
          .from('keluarga')
          .select('*, warga:kepala_keluarga_id(*), rumah:alamat_rumah(alamat)')
          .eq('id', keluargaId)
          .single();

      return k_model.Keluarga.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching keluarga by email: $e');
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

  /// Menambahkan relasi warga ke keluarga (tabel keluarga_warga)
  Future<void> addAnggotaKeluargaRelation(String keluargaId, String wargaId, String peran) async {
    try {
      await _supabase.from('keluarga_warga').insert({
        'keluarga_id': keluargaId,
        'warga_id': wargaId,
        'peran': peran,
      });
    } catch (e) {
      throw Exception('Error adding anggota keluarga relation: $e');
    }
  }

  /// Update relasi warga ke keluarga (tabel keluarga_warga)
  Future<void> updateAnggotaKeluargaRelation(String wargaId, String peran) async {
    try {
      await _supabase
          .from('keluarga_warga')
          .update({'peran': peran})
          .eq('warga_id', wargaId);
    } catch (e) {
      throw Exception('Error updating anggota keluarga relation: $e');
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
