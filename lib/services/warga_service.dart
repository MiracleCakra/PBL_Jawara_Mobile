import 'dart:io';
import 'dart:typed_data';
import 'package:SapaWarga_kel_2/models/keluarga/warga_model.dart';
import 'package:SapaWarga_kel_2/services/activity_log_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WargaService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ActivityLogService _logService = ActivityLogService();
  
  Future<String> uploadFotoProfil({
    File? file,
    Uint8List? bytes,
    required String fileName,
    String? contentType,
  }) async {
    try {
      const String bucketName = 'pfp';
      final String path = 'foto_profil/$fileName';
      final FileOptions fileOptions = FileOptions(
        contentType: contentType,
        upsert: true,
      );

      if (bytes != null) {
        await _supabase.storage.from(bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: fileOptions,
        );
      } else if (file != null) {
        await _supabase.storage.from(bucketName).upload(
          path,
          file,
          fileOptions: fileOptions,
        );
      } else {
        throw Exception("Gagal: Data file tidak ditemukan (Bytes & File null)");
      }

      return _supabase.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      throw Exception('Gagal upload foto profil ($fileName): $e');
    }
  }

  Future<String> uploadFotoKtp({
    File? file,
    Uint8List? bytes,
    required String fileName,
    String? contentType,
  }) async {
    try {
      const String bucketName = 'pfp';
      final String path = 'foto_ktp/$fileName';
      final FileOptions fileOptions = FileOptions(
        contentType: contentType,
        upsert: true,
      );

      if (bytes != null) {
        await _supabase.storage.from(bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: fileOptions,
        );
      } else if (file != null) {
        await _supabase.storage.from(bucketName).upload(
          path,
          file,
          fileOptions: fileOptions,
        );
      } else {
        throw Exception("Gagal: Data file tidak ditemukan (Bytes & File null)");
      }

      return _supabase.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      throw Exception('Gagal upload foto KTP ($fileName): $e');
    }
  }

  /// Fetch warga berdasarkan Email
  Future<Warga?> getWargaByEmail(String email) async {
    try {
      final response = await _supabase
          .from('warga')
          .select('''
            id, nama, tanggal_lahir, tempat_lahir, telepon, gender, 
            gol_darah, pendidikan_terakhir, pekerjaan, status_penduduk, keluarga_id, agama, foto_ktp, foto_profil, email, role, status_hidup_wafat,
            keluarga:keluarga_id(id, nama_keluarga, kepala_keluarga_id, alamat_rumah, status_kepemilikan, status_keluarga, rumah:alamat_rumah(alamat)),
            anggota_keluarga:keluarga_warga(peran)
          ''')
          .eq('email', email)
          .maybeSingle();

      if (response == null) return null;
      return Warga.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching warga by email: $e');
    }
  }

  /// Fetch semua warga dengan data keluarga
  Future<List<Warga>> getAllWarga() async {
    try {
      final response = await _supabase
          .from('warga')
          .select('''
            id, nama, tanggal_lahir, tempat_lahir, telepon, gender, 
            gol_darah, pendidikan_terakhir, pekerjaan, status_penduduk, keluarga_id, agama, foto_ktp, foto_profil, email, role, status_hidup_wafat,
            keluarga:keluarga_id(id, nama_keluarga, kepala_keluarga_id, alamat_rumah, status_kepemilikan, status_keluarga, rumah:alamat_rumah(alamat)),
            anggota_keluarga:keluarga_warga(peran)
          ''')
          .order('nama');

      return List<Warga>.from(
          response.map((json) => Warga.fromJson(json)));
    } catch (e) {
      throw Exception('Error fetching warga: $e');
    }
  }

  /// Fetch warga berdasarkan NIK
  Future<Warga?> getWargaByNik(String nik) async {
    try {
      final response = await _supabase
          .from('warga')
          .select('''
            id, nama, tanggal_lahir, tempat_lahir, telepon, gender, 
            gol_darah, pendidikan_terakhir, pekerjaan, status_penduduk, keluarga_id, agama, foto_ktp, foto_profil, email, role, status_hidup_wafat,
            keluarga:keluarga_id(id, nama_keluarga, kepala_keluarga_id, alamat_rumah, status_kepemilikan, status_keluarga, rumah:alamat_rumah(alamat)),
            anggota_keluarga:keluarga_warga(peran)
          ''')
          .eq('nik', nik)
          .single();

      return Warga.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching warga: $e');
    }
  }

  /// Fetch warga berdasarkan keluarga_id
  Future<List<Warga>> getWargaByKeluargaId(String keluargaId) async {
    try {
      final response = await _supabase
          .from('warga')
          .select('''
            id, nama, tanggal_lahir, tempat_lahir, telepon, gender, 
            gol_darah, pendidikan_terakhir, pekerjaan, status_penduduk, keluarga_id, agama, foto_ktp, foto_profil, email, role, status_hidup_wafat,
            keluarga:keluarga_id(id, nama_keluarga, kepala_keluarga_id, alamat_rumah, status_kepemilikan, status_keluarga, rumah:alamat_rumah(alamat)),
            anggota_keluarga:keluarga_warga(peran)
          ''')
          .eq('keluarga_id', keluargaId)
          .order('nama');

      return List<Warga>.from(
          response.map((json) => Warga.fromJson(json)));
    } catch (e) {
      throw Exception('Error fetching warga by keluarga: $e');
    }
  }

  /// Fetch warga dengan filter
  Future<List<Warga>> getWargaFiltered({
    String? gender,
    String? statusPenduduk,
    String? keluargaId,
    String? searchQuery,
  }) async {
    try {
      var query = _supabase
          .from('warga')
          .select('''
            id, nama, tanggal_lahir, tempat_lahir, telepon, gender, 
            gol_darah, pendidikan_terakhir, pekerjaan, status_penduduk, keluarga_id, agama, foto_ktp, foto_profil, email, role, status_hidup_wafat,
            keluarga:keluarga_id(id, nama_keluarga, kepala_keluarga_id, alamat_rumah, status_kepemilikan, status_keluarga, rumah:alamat_rumah(alamat)),
            anggota_keluarga:keluarga_warga(peran)
          ''');

      if (gender != null && gender.isNotEmpty) {
        query = query.eq('gender', gender);
      }

      if (statusPenduduk != null && statusPenduduk.isNotEmpty) {
        query = query.eq('status_penduduk', statusPenduduk);
      }

      if (keluargaId != null && keluargaId.isNotEmpty) {
        query = query.eq('keluarga_id', keluargaId);
      }

      final response = await query.order('nama');

      List<Warga> wargaList =
          List<Warga>.from(response.map((json) => Warga.fromJson(json)));

      // Filter berdasarkan search query (nama atau ID)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        wargaList = wargaList
            .where((w) =>
                w.nama.toLowerCase().contains(lowerQuery) ||
                (w.id.contains(searchQuery)))
            .toList();
      }

      return wargaList;
    } catch (e) {
      throw Exception('Error filtering warga: $e');
    }
  }

  /// Fetch warga yang belum memiliki keluarga
  Future<List<Warga>> getWargaWithoutKeluarga() async {
    try {
      final response = await _supabase
          .from('warga')
          .select('''
            id, nama, tanggal_lahir, tempat_lahir, telepon, gender, 
            gol_darah, pendidikan_terakhir, pekerjaan, status_penduduk, keluarga_id, agama, foto_ktp, foto_profil, email, role, status_hidup_wafat
          ''')
          .isFilter('keluarga_id', null)
          .order('nama');

      return List<Warga>.from(
          response.map((json) => Warga.fromJson(json)));
    } catch (e) {
      throw Exception('Error fetching warga without keluarga: $e');
    }
  }

  /// Create warga baru
  Future<Warga> createWarga(Warga warga) async {
    try {
      final response = await _supabase
          .from('warga')
          .insert(warga.toJson())
          .select('''
            id, nama, tanggal_lahir, tempat_lahir, telepon, gender, 
            gol_darah, pendidikan_terakhir, pekerjaan, status_penduduk, keluarga_id, agama, foto_ktp, foto_profil, email, role, status_hidup_wafat,
            keluarga:keluarga_id(id, nama_keluarga, kepala_keluarga_id, alamat_rumah, status_kepemilikan, status_keluarga, rumah:alamat_rumah(alamat)),
            anggota_keluarga:keluarga_warga(peran)
          ''')
          .single();

      return Warga.fromJson(response);
    } catch (e) {
      throw Exception('Error creating warga: $e');
    }
  }

  /// Update warga
  Future<Warga> updateWarga(String id, Warga warga) async {
    try {
      final response = await _supabase
          .from('warga')
          .update(warga.toJson())
          .eq('id', id) // DIGANTI dari nik ke id
          .select('''
            id, nama, tanggal_lahir, tempat_lahir, telepon, gender, 
            gol_darah, pendidikan_terakhir, pekerjaan, status_penduduk, keluarga_id, agama, foto_ktp, foto_profil, email, role, status_hidup_wafat,
            keluarga:keluarga_id(id, nama_keluarga, kepala_keluarga_id, alamat_rumah, status_kepemilikan, status_keluarga, rumah:alamat_rumah(alamat)),
            anggota_keluarga:keluarga_warga(peran)
          ''')
          .single();

      final updatedWarga = Warga.fromJson(response);

      // Log
      await _logService.createLog(
        judul: 'Memperbarui Profil Warga: ${updatedWarga.nama}',
        type: 'Profil',
      );

      return updatedWarga;
    } catch (e) {
      throw Exception('Error updating warga: $e');
    }
  }

  /// Delete warga
  Future<void> deleteWarga(String id) async {
    try {
      await _supabase.from('warga').delete().eq('id', id); // DIGANTI dari nik ke id
    } catch (e) {
      throw Exception('Error deleting warga: $e');
    }
  }

  /// Fetch semua keluarga
  Future<List<Keluarga>> getAllKeluarga() async {
    try {
      final response = await _supabase
          .from('keluarga')
          .select()
          .order('nama_keluarga');

      return List<Keluarga>.from(
          response.map((json) => Keluarga.fromJson(json)));
    } catch (e) {
      throw Exception('Error fetching keluarga: $e');
    }
  }

  /// Fetch warga berdasarkan ID
  Future<Warga> getWargaById(String id) async {
    try {
      final response = await _supabase
          .from('warga')
          .select('''
            id, nama, tanggal_lahir, tempat_lahir, telepon, gender, 
            gol_darah, pendidikan_terakhir, pekerjaan, status_penduduk, keluarga_id, agama, foto_ktp, foto_profil, email, role, status_hidup_wafat,
            keluarga:keluarga_id(
              id, nama_keluarga, kepala_keluarga_id, alamat_rumah, status_kepemilikan, status_keluarga, 
              rumah:alamat_rumah(alamat)
            ),
            anggota_keluarga:keluarga_warga(peran)
          ''')
          .eq('id', id)
          .single();

      return Warga.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching warga by id: $e');
    }
  }
}
