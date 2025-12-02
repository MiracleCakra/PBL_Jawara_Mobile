import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/store_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreVerificationHelper {
  static final _storeService = StoreService();

  /// Check store verification status
  /// Returns: {
  ///   'isVerified': bool,
  ///   'status': String, // 'Pending', 'Diterima', 'Ditolak', 'Nonaktif'
  ///   'message': String, // Message to display to user
  ///   'store': StoreModel? // Store data if exists
  /// }
  static Future<Map<String, dynamic>> checkStoreStatus() async {
    try {
      final authUser = Supabase.instance.client.auth.currentUser;

      if (authUser?.email == null) {
        return {
          'isVerified': false,
          'status': null,
          'message': 'User tidak terautentikasi',
          'store': null,
        };
      }

      // Get warga ID
      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', authUser!.email!)
          .maybeSingle();

      if (wargaResponse == null) {
        return {
          'isVerified': false,
          'status': null,
          'message': 'Data warga tidak ditemukan',
          'store': null,
        };
      }

      final userId = wargaResponse['id'] as String;

      // Get store data
      final store = await _storeService.getStoreByUserId(userId);

      if (store == null) {
        return {
          'isVerified': false,
          'status': null,
          'message': 'Anda belum mendaftar toko',
          'store': null,
        };
      }

      // Check verification status
      final status = store.verifikasi;

      switch (status) {
        case 'Diterima':
          return {
            'isVerified': true,
            'status': 'Diterima',
            'message': 'Toko Anda sudah diverifikasi',
            'store': store,
          };

        case 'Pending':
          return {
            'isVerified': false,
            'status': 'Pending',
            'message':
                'Toko Anda sedang dalam proses verifikasi admin. Mohon tunggu.',
            'store': store,
          };

        case 'Ditolak':
          final reason = store.alasan ?? 'Tidak ada alasan yang diberikan';
          return {
            'isVerified': false,
            'status': 'Ditolak',
            'message':
                'Pengajuan toko Anda ditolak oleh admin.\n\nAlasan: $reason',
            'store': store,
          };

        case 'Nonaktif':
          return {
            'isVerified': false,
            'status': 'Nonaktif',
            'message':
                'Toko Anda telah dinonaktifkan. Hubungi admin untuk informasi lebih lanjut.',
            'store': store,
          };

        default:
          return {
            'isVerified': false,
            'status': status,
            'message': 'Status toko tidak diketahui',
            'store': store,
          };
      }
    } catch (e) {
      print('Error checking store status: $e');
      return {
        'isVerified': false,
        'status': null,
        'message': 'Gagal memeriksa status toko: $e',
        'store': null,
      };
    }
  }

  /// Show dialog with store status information
  static void showStoreStatusDialog({
    required context,
    required String status,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getStatusIcon(status),
              color: _getStatusColor(status),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              _getStatusTitle(status),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Diterima':
        return Icons.check_circle;
      case 'Pending':
        return Icons.hourglass_empty;
      case 'Ditolak':
        return Icons.cancel;
      case 'Nonaktif':
        return Icons.block;
      default:
        return Icons.info;
    }
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'Diterima':
        return const Color(0xFF4CAF50);
      case 'Pending':
        return const Color(0xFFFF9800);
      case 'Ditolak':
        return const Color(0xFFF44336);
      case 'Nonaktif':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF2196F3);
    }
  }

  static String _getStatusTitle(String status) {
    switch (status) {
      case 'Diterima':
        return 'Toko Terverifikasi';
      case 'Pending':
        return 'Menunggu Verifikasi';
      case 'Ditolak':
        return 'Pengajuan Ditolak';
      case 'Nonaktif':
        return 'Toko Nonaktif';
      default:
        return 'Status Toko';
    }
  }
}
