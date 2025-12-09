import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'package:jawara_pintar_kel_5/services/activity_log_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PenggunaService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ActivityLogService _logService = ActivityLogService();

  /// Fetch all users (warga with roles)
  Future<List<Warga>> fetchAllUsers() async {
    try {
      // Select only necessary columns to avoid join issues
      final response = await _supabase
          .from('warga')
          .select('id, nama, role, status_penduduk, email, telepon, gender, agama, foto_profil, foto_ktp, tempat_lahir, tanggal_lahir, pendidikan_terakhir, pekerjaan, status_hidup_wafat, gol_darah')
          .order('nama');

      return List<Warga>.from(
          response.map((json) => Warga.fromJson(json)));
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  /// Fetch user by ID
  Future<Warga> getUserById(String id) async {
    try {
      final response = await _supabase
          .from('warga')
          .select('id, nama, role, status_penduduk, email, telepon, gender, agama, foto_profil, foto_ktp, tempat_lahir, tanggal_lahir, pendidikan_terakhir, pekerjaan, status_hidup_wafat, gol_darah')
          .eq('id', id)
          .single();

      return Warga.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching user by ID: $e');
    }
  }

  /// Add a new user
  Future<void> addUser(Map<String, dynamic> data) async {
    try {
      final insertData = {
        'nama': data['nama'],
        'email': data['email'],
        'telepon': data['telepon'],
        'role': data['role'],
        'status_penduduk': 'Aktif',
      };

      await _supabase.from('warga').insert(insertData);

      // Log
      await _logService.createLog(
        judul: 'Menambah Pengguna Baru: ${data['nama']}',
        type: 'Manajemen Pengguna',
      );
    } catch (e) {
      throw Exception('Gagal menambah pengguna: $e');
    }
  }

  /// Update user details
  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase.from('warga').update(updates).eq('id', id).select('nama').single();
      final String nama = response['nama'] ?? 'Pengguna';

      // Log
      await _logService.createLog(
        judul: 'Mengubah Data Pengguna: $nama',
        type: 'Manajemen Pengguna',
      );
    } catch (e) {
      throw Exception('Gagal memperbarui pengguna: $e');
    }
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    try {
      final data = await _supabase.from('warga').select('nama').eq('id', id).single();
      final String nama = data['nama'] ?? 'Pengguna';

      await _supabase.from('warga').delete().eq('id', id);

      // Log
      await _logService.createLog(
        judul: 'Menghapus Pengguna: $nama',
        type: 'Manajemen Pengguna',
      );
    } catch (e) {
      throw Exception('Gagal menghapus pengguna: $e');
    }
  }
  
  // Stream versions (if needed for other parts, kept for compatibility if any)
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
}