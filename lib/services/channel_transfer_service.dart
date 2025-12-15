import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb & Uint8List
import 'package:SapaWarga_kel_2/services/activity_log_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:SapaWarga_kel_2/models/keuangan/channel_transfer_model.dart';

class ChannelTransferService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'channel_transfer';
  final String _bucketName = 'qristransfer_images';
  final ActivityLogService _logService = ActivityLogService();

  Stream<List<ChannelTransferModel>> getChannelsStream() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => ChannelTransferModel.fromMap(map)).toList());
  }

  Future<List<ChannelTransferModel>> getChannels() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      return List<ChannelTransferModel>.from(
          response.map((json) => ChannelTransferModel.fromMap(json)));
    } catch (e) {
      throw Exception('Gagal mengambil data channel: $e');
    }
  }

  Future<ChannelTransferModel> getChannelById(int id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      return ChannelTransferModel.fromMap(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail channel: $e');
    }
  }

  Future<String> uploadQrImage({
    File? file,
    Uint8List? bytes,
    required String fileName,
  }) async {
    try {
      final String path = 'qris/$fileName';
      final FileOptions fileOptions = const FileOptions(
        contentType: 'image/jpeg',
        upsert: true,
      );

      if (bytes != null) {
        // Upload Web
        await _supabase.storage.from(_bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: fileOptions,
        );
      } else if (file != null) {
        // Upload Mobile
        await _supabase.storage.from(_bucketName).upload(
          path,
          file,
          fileOptions: fileOptions,
        );
      } else {
        throw Exception("File gambar tidak valid (Bytes & File kosong)");
      }

      // Return Public URL
      return _supabase.storage.from(_bucketName).getPublicUrl(path);
    } catch (e) {
      throw Exception('Gagal upload QRIS: $e');
    }
  }
  
  Future<void> createChannel(ChannelTransferModel channel) async {
    try {
      final data = channel.toMap()
        ..remove('id')
        ..remove('created_at');

      await _supabase.from(_tableName).insert(data);

      // Log
      await _logService.createLog(
        judul: 'Menambah Channel: ${channel.nama}',
        type: 'Channel Transfer',
      );
    } catch (e) {
      throw Exception('Gagal membuat channel: $e');
    }
  }

  Future<void> updateChannel(int id, ChannelTransferModel channel) async {
    try {
      final data = channel.toMap()
        ..remove('id')
        ..remove('created_at');

      await _supabase.from(_tableName).update(data).eq('id', id);

      // Log
      await _logService.createLog(
        judul: 'Mengubah Channel: ${channel.nama}',
        type: 'Channel Transfer',
      );
    } catch (e) {
      throw Exception('Gagal update channel: $e');
    }
  }

  Future<void> deleteChannel(int id) async {
    try {
      final data = await _supabase.from(_tableName).select('nama_bank').eq('id', id).single();
      final String namaBank = data['nama_bank'] ?? 'Tanpa Nama';

      await _supabase.from(_tableName).delete().eq('id', id);

      // Log
      await _logService.createLog(
        judul: 'Menghapus Channel: $namaBank',
        type: 'Channel Transfer',
      );
    } catch (e) {
      throw Exception('Gagal menghapus channel: $e');
    }
  }
}