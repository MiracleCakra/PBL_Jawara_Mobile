import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreStatusService {
  // 0 = belum daftar
  // 1 = pending
  // 2 = aktif
  // 3 = ditolak
  // 4 = nonaktif (owner atau admin)
  static const String key = 'store_status';

  static Future<int> getStoreStatus() async {
    try {
      // Get current user email
      final authUser = Supabase.instance.client.auth.currentUser;
      print('DEBUG: Auth user email: ${authUser?.email}');

      if (authUser?.email == null) {
        print('DEBUG: No auth user found');
        return 0;
      }

      // Query warga table to get warga.id (NIK)
      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', authUser!.email!)
          .maybeSingle();

      print('DEBUG: Warga response: $wargaResponse');

      if (wargaResponse == null) {
        print('DEBUG: Warga not found');
        return 0;
      }

      final userId = wargaResponse['id'].toString(); // Force convert to string
      print('DEBUG: User ID (NIK): $userId (type: ${userId.runtimeType})');

      // Query store table to check if user has store
      final storeResponse = await Supabase.instance.client
          .from('store')
          .select('store_id, verifikasi')
          .eq('user_id', userId)
          .maybeSingle();

      print('DEBUG: Store response: $storeResponse');

      if (storeResponse == null) {
        print('DEBUG: Store not found for user_id: $userId');
        return 0; // Belum punya toko
      }

      // Check verification status
      final verifikasi = storeResponse['verifikasi'] as String?;
      print('DEBUG: Verifikasi status: $verifikasi');

      // Mapping status verifikasi:
      // 'Diterima' = Aktif (2)
      // 'Pending' = Menunggu validasi (1)
      // 'Ditolak' = Ditolak (3)
      // 'Nonaktif' = Nonaktif (4)
      // null atau lainnya = Belum punya toko (0)

      if (verifikasi == 'Diterima') {
        print('DEBUG: Returning status 2 (Aktif)');
        return 2; // Aktif
      } else if (verifikasi == 'Pending') {
        print('DEBUG: Returning status 1 (Pending)');
        return 1; // Menunggu validasi
      } else if (verifikasi == 'Nonaktif') {
        print('DEBUG: Returning status 4 (Nonaktif)');
        return 4; // Nonaktif
      } else if (verifikasi == 'Ditolak') {
        print('DEBUG: Returning status 3 (Ditolak)');
        return 3; // Ditolak
      } else {
        print('DEBUG: Returning status 0 (Unknown)');
        return 0; // Status lainnya
      }
    } catch (e) {
      print('ERROR getting store status: $e');
      return 0;
    }
  }

  static Future<void> setStoreStatus(int status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, status);
  }
}
