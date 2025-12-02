import 'dart:async';
import 'package:jawara_pintar_kel_5/models/kegiatan/aspirasi_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AspirasiService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'aspirasi';

  // Stream to get all aspirations
  Stream<List<AspirasiModel>> getAspirations() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('tanggal', ascending: false)
        .map((maps) => maps.map((map) => AspirasiModel.fromMap(map)).toList());
  }

  // Stream to get aspirations by user ID
  Stream<List<AspirasiModel>> getAspirationsByUserId(String userId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('tanggal', ascending: false)
        .map((maps) => maps.map((map) => AspirasiModel.fromMap(map)).toList());
  }

  // Create a new aspiration
  Future<void> createAspiration(AspirasiModel aspirasi) async {
    try {
      final Map<String, dynamic> data = aspirasi.toMap();
      data.remove('id'); 
      if (data['created_at'] == null) {
        data.remove('created_at'); 
      }
      await _supabase.from(_tableName).insert(data);
    } catch (e) {
      throw Exception('Error creating aspiration: $e');
    }
  }

  // Update an aspiration
  Future<void> updateAspiration(AspirasiModel aspirasi) async {
    try {
      if (aspirasi.id == null) {
        throw Exception('Cannot update aspiration: id is null');
      }
      await _supabase
          .from(_tableName)
          .update(aspirasi.toMap())
          .eq('id', aspirasi.id!);
    } catch (e) {
      throw Exception('Error updating aspiration: $e');
    }
  }

  // Delete an aspiration
  Future<void> deleteAspiration(int id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Error deleting aspiration: $e');
    }
  }
}