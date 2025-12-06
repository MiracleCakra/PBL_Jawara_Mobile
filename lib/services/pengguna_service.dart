import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PenggunaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<List<Warga>> streamAllUsers() {
    return _supabase
        .from('warga')
        .stream(primaryKey: ['id'])
        .order('nama', ascending: true)
        .map((data) => data.map((json) => Warga.fromJson(json)).toList());
  }

  Stream<Warga> streamUserById(String id) {
    return _supabase
        .from('warga')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .limit(1)
        .map((data) => Warga.fromJson(data.first));
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase.from('warga').update(updates).eq('id', id);
    } catch (e) {
      throw Exception('Gagal memperbarui pengguna: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _supabase.from('warga').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus pengguna: $e');
    }
  }
}