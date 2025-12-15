import 'dart:async';
import 'package:SapaWarga_kel_2/models/kegiatan/aspirasi_model.dart';
import 'package:SapaWarga_kel_2/services/activity_log_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AspirasiService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'aspirasi';
  final ActivityLogService _logService = ActivityLogService();

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

      // Log
      await _logService.createLog(
        judul: 'Menambah Aspirasi: ${aspirasi.judul}',
        type: 'Aspirasi',
      );
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

      // Log
      await _logService.createLog(
        judul: 'Mengubah Aspirasi: ${aspirasi.judul}',
        type: 'Aspirasi',
      );
    } catch (e) {
      throw Exception('Error updating aspiration: $e');
    }
  }

  // Delete an aspiration
  Future<void> deleteAspiration(int id) async {
    try {
      final data = await _supabase.from(_tableName).select('judul').eq('id', id).single();
      final String judul = data['judul'] ?? 'Tanpa Judul';

      await _supabase.from(_tableName).delete().eq('id', id);

      // Log
      await _logService.createLog(
        judul: 'Menghapus Aspirasi: $judul',
        type: 'Aspirasi',
      );
    } catch (e) {
      throw Exception('Error deleting aspiration: $e');
    }
  }
}