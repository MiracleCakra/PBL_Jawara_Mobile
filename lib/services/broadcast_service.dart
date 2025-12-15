import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/broadcast_model.dart';
import 'package:SapaWarga_kel_2/services/activity_log_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BroadcastService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'broadcast';
  final String _bucketName = 'broadcast_documents';
  final ActivityLogService _logService = ActivityLogService();

  Stream<List<BroadcastModel>> getBroadcastsStream() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('tanggal', ascending: false)
        .map((maps) => maps.map((map) => BroadcastModel.fromMap(map)).toList());
  }

  /// Fetch semua broadcast
  Future<List<BroadcastModel>> getBroadcasts() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('tanggal', ascending: false);
      return List<BroadcastModel>.from(
        response.map((json) => BroadcastModel.fromMap(json)),
      );
    } catch (e) {
      throw Exception('Error fetching broadcasts: $e');
    }
  }

  /// Fetch broadcast by ID
  Future<BroadcastModel> getBroadcastById(int id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      return BroadcastModel.fromMap(response);
    } catch (e) {
      throw Exception('Error fetching broadcast by id: $e');
    }
  }

  Future<String> uploadFile({
    File? file,
    Uint8List? bytes,
    required String fileName,
    required String folderName,
    String? contentType,
  }) async {
    try {
      final String path = '$folderName/$fileName';
      final FileOptions fileOptions = FileOptions(
        contentType: contentType,
        upsert: true,
      );
      if (bytes != null) {
        await _supabase.storage.from(_bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: fileOptions,
        );
      } else if (file != null) {
        await _supabase.storage.from(_bucketName).upload(
          path,
          file,
          fileOptions: fileOptions,
        );
      } else {
        // Kalau dua-duanya kosong
        throw Exception("Gagal: Data file tidak ditemukan (Bytes & File null)");
      }

      return _supabase.storage.from(_bucketName).getPublicUrl(path);
    } catch (e) {
      throw Exception('Gagal upload file ($fileName): $e');
    }
  }

  Future<BroadcastModel> createBroadcast(BroadcastModel broadcast) async {
    try {
      final Map<String, dynamic> insertData = broadcast.toMap()
        ..remove('id')
        ..remove('created_at');

      if (insertData.containsKey('lampiranDokumenUrl')) {
         insertData['lampiranDokumen'] = insertData['lampiranDokumenUrl'];
         insertData.remove('lampiranDokumenUrl');
      }

      final response = await _supabase
          .from(_tableName)
          .insert(insertData)
          .select()
          .single();

      // Log
      await _logService.createLog(
        judul: 'Menambah Broadcast: ${broadcast.judul}',
        type: 'Broadcast',
      );

      return BroadcastModel.fromMap(response);
    } catch (e) {
      throw Exception('Error creating broadcast: $e');
    }
  }

  /// Update broadcast
  Future<BroadcastModel> updateBroadcast(
    int id,
    BroadcastModel broadcast,
  ) async {
    try {
      // Omitting id and created_at because they should not be updated
      final Map<String, dynamic> updateData = broadcast.toMap()
        ..remove('id')
        ..remove('created_at');

      if (updateData.containsKey('lampiranDokumenUrl')) {
        updateData['lampiranDokumen'] = updateData['lampiranDokumenUrl'];
        updateData.remove('lampiranDokumenUrl');
      }

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      // Log
      await _logService.createLog(
        judul: 'Mengubah Broadcast: ${broadcast.judul}',
        type: 'Broadcast',
      );

      return BroadcastModel.fromMap(response);
    } catch (e) {
      throw Exception('Error updating broadcast: $e');
    }
  }

  /// Delete broadcast
  Future<void> deleteBroadcast(int id) async {
    try {
      // Fetch title first
      final data = await _supabase.from(_tableName).select('judul').eq('id', id).single();
      final String judul = data['judul'] ?? 'Tanpa Judul';

      await _supabase.from(_tableName).delete().eq('id', id);
      
      // Log
      await _logService.createLog(
        judul: 'Menghapus Broadcast: $judul',
        type: 'Broadcast',
      );
    } catch (e) {
      throw Exception('Error deleting broadcast: $e');
    }
  }
}
