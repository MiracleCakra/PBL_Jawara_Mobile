import 'package:shared_preferences/shared_preferences.dart';

class StoreStatusService {

  // 0 = belum daftar
  // 1 = pending
  // 2 = aktif
  static const String key = 'store_status';

  static Future<int> getStoreStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  static Future<void> setStoreStatus(int status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, status);
  }
}
