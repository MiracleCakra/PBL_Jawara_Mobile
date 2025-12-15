import 'package:SapaWarga_kel_2/models/log/activity_log_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityLogService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tableName = 'activity_log';

  // Fetch logs (Stream for realtime updates)
  Stream<List<ActivityLogModel>> getLogsStream() {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => ActivityLogModel.fromJson(json)).toList());
  }

  // Fetch logs (Future)
  Future<List<ActivityLogModel>> getLogs() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => ActivityLogModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching activity logs: $e');
    }
  }

  // Create log (Insert with Automatic User Lookup)
  Future<void> createLog({required String judul, required String type}) async {
    try {
      String userName = 'System'; 
      final user = _supabase.auth.currentUser;

      if (user?.email != null) {
        // Cari nama di tabel warga berdasarkan email yang sedang login
        final response = await _supabase
            .from('warga')
            .select('nama')
            .eq('email', user!.email!)
            .maybeSingle();
        
        if (response != null && response['nama'] != null) {
          userName = response['nama'];
        } else {
          // Fallback ke email jika data warga tidak ditemukan
          userName = user.email!;
        }
      }

      final logData = {
        'judul': judul,
        'type': type,
        'user': userName, // Nama user otomatis diambil dari DB
        'tanggal': DateTime.now().toIso8601String(),
      };

      await _supabase.from(_tableName).insert(logData);
    } catch (e) {
      throw Exception('Error creating activity log: $e');
    }
  }
}