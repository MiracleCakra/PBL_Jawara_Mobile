import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/kegiatan_model.dart';
import 'package:SapaWarga_kel_2/services/activity_log_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KegiatanService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'kegiatan';
  final String _bucketName = 'kegiatan_images';
  final ActivityLogService _logService = ActivityLogService();

  Stream<List<KegiatanModel>> getKegiatanStream() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('tanggal', ascending: false)
        .map((data) {
          final List<dynamic> rawList = data as List<dynamic>;
          
          return rawList.map((item) {
            final safeMap = Map<String, dynamic>.from(item as Map);
            return KegiatanModel.fromMap(safeMap);
          }).toList();
        });
  }

  /// Fetch semua kegiatan
  Future<List<KegiatanModel>> getKegiatan() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*, kegiatan_img(*)')
          .order('tanggal', ascending: false);
      return List<KegiatanModel>.from(
          response.map((json) => KegiatanModel.fromMap(json)));
    } catch (e) {
      throw Exception('Error fetching kegiatan: $e');
    }
  }

  /// Fetch kegiatan by ID
  Future<KegiatanModel> getKegiatanById(int id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('*, kegiatan_img(*)')
          .eq('id', id)
          .single();
      return KegiatanModel.fromMap(response);
    } catch (e) {
      throw Exception('Error fetching kegiatan by id: $e');
    }
  }

  Future<KegiatanModel> createKegiatan(KegiatanModel kegiatan) async {
    try {
      final Map<String, dynamic> insertData = kegiatan.toMap()
        ..remove('id')
        ..remove('created_at');

      final response = await _supabase
          .from(_tableName)
          .insert(insertData)
          .select()
          .single();

      // Log
      await _logService.createLog(
        judul: 'Menambah Kegiatan: ${kegiatan.judul}',
        type: 'Kegiatan',
      );

      return KegiatanModel.fromMap(response);
    } catch (e) {
      throw Exception('Error creating kegiatan: $e');
    }
  }

  /// Update kegiatan
  Future<KegiatanModel> updateKegiatan(int id, KegiatanModel kegiatan) async {
    try {
      // Omitting id and created_at because they should not be updated
      final Map<String, dynamic> updateData = kegiatan.toMap()
        ..remove('id')
        ..remove('created_at');

      final response = await _supabase
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      // Log
      await _logService.createLog(
        judul: 'Mengubah Kegiatan: ${kegiatan.judul}',
        type: 'Kegiatan',
      );

      return KegiatanModel.fromMap(response);
    } catch (e) {
      throw Exception('Error updating kegiatan: $e');
    }
  }

  /// Delete kegiatan
  Future<void> deleteKegiatan(int id) async {
    try {
      final data = await _supabase.from(_tableName).select('judul').eq('id', id).single();
      final String judul = data['judul'] ?? 'Tanpa Judul';

      // 1. Hapus gambar terkait di tabel kegiatan_img terlebih dahulu (Manual Cascade)
      await _supabase.from('kegiatan_img').delete().eq('id_kegiatan', id);

      // 2. Hapus data kegiatan utama
      await _supabase.from(_tableName).delete().eq('id', id);
      
      // Log
      await _logService.createLog(
        judul: 'Menghapus Kegiatan: $judul',
        type: 'Kegiatan',
      );
    } catch (e) {
      throw Exception('Error deleting kegiatan: $e');
    }
  }

  Future<String> uploadKegiatanImage({
    File? file,
    Uint8List? bytes,
    required String fileName,
  }) async {
    try {
      final String path = 'dokumentasi/$fileName';

      if (kIsWeb) {
        if (bytes == null) throw Exception("Bytes kosong untuk upload Web");
        await _supabase.storage.from(_bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'), // Sesuaikan tipe konten
        );
      } else {
        if (file == null) throw Exception("File kosong untuk upload Mobile");
        await _supabase.storage.from(_bucketName).upload(
          path,
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
      }

      final String publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload gambar: $e');
    }
  }

  Future<void> uploadMultipleImages({
    required int idKegiatan,
    List<File>? files,
    List<Uint8List>? bytesList,
    List<String>? fileNames,
  }) async {
    try {
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          final fileName = fileNames?[i] ?? 'img_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final url = await uploadKegiatanImage(file: files[i], fileName: fileName);
          
          await _supabase.from('kegiatan_img').insert({
            'id_kegiatan': idKegiatan,
            'img': url,
          });
        }
      } else if (bytesList != null) {
        for (int i = 0; i < bytesList.length; i++) {
          final fileName = fileNames?[i] ?? 'img_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final url = await uploadKegiatanImage(bytes: bytesList[i], fileName: fileName);
          
          await _supabase.from('kegiatan_img').insert({
            'id_kegiatan': idKegiatan,
            'img': url,
          });
        }
      }
    } catch (e) {
      throw Exception('Gagal upload multiple images: $e');
    }
  }
}
