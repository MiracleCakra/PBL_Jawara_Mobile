import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WargaTagihanModel {
  final String namaKeluarga;
  final String statusKeluarga;
  final String iuran;
  final String kodeTagihan;
  final double nominal;
  final DateTime periode;
  final String status;
  final String alamat;
  final String? bukti;
  final String? catatan;

  WargaTagihanModel({
    required this.namaKeluarga,
    required this.statusKeluarga,
    required this.iuran,
    required this.kodeTagihan,
    required this.nominal,
    required this.periode,
    required this.status,
    required this.alamat,
    this.bukti,
    this.catatan,
  });

  Future<List<WargaTagihanModel>> fetchTagihan() async {
    try {
      final idKeluarga = await Supabase.instance.client
          .from('warga')
          .select('keluarga_id')
          .eq('email', Supabase.instance.client.auth.currentUser?.email ?? '')
          .single();

      debugPrint('Keluarga ID fetched successfully: $idKeluarga');

      final response = await Supabase.instance.client
          .from('tagihan_iuran')
          .select(
            '*, keluarga!id_keluarga(nama_keluarga, status_keluarga), iuran!id_iuran(nama, nominal), rumah!id_rumah(alamat), bukti_pembayaran',
          )
          // .eq('status_pembayaran', 'Belum Dibayar')
          .eq('id_keluarga', idKeluarga['keluarga_id'].toString())
          .order('status_pembayaran', ascending: true);
      debugPrint('Tagihan fetched successfully: $response');
      return response.map<WargaTagihanModel>((item) {
        return WargaTagihanModel(
          namaKeluarga: item['keluarga']['nama_keluarga'],
          statusKeluarga: item['keluarga']['status_keluarga'],
          iuran: item['iuran']['nama'],
          kodeTagihan: item['id'].toString(),
          nominal: (item['iuran']['nominal'] as num).toDouble(),
          periode: DateTime.parse(item['tgl_tagihan'] as String),
          status: item['status_pembayaran'] as String,
          alamat: item['rumah']['alamat'] ?? '',
          bukti: item['bukti_pembayaran'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching tagihan: $e');
      return Future.value(<WargaTagihanModel>[]);
    }
  }

  saveTagihan(String bukti, String tagihanId) async {
    await Supabase.instance.client
        .from('tagihan_iuran')
        .update({
          'status_pembayaran': 'Menunggu Verifikasi',
          'bukti_pembayaran': bukti,
          'alasan_penolakan': catatan ?? '',
        })
        .eq('id', tagihanId);

    debugPrint('Tagihan berhasil disimpan');
  }
}
