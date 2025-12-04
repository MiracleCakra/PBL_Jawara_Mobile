import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TagihanModel {
  final String namaKeluarga;
  final String statusKeluarga;
  final String iuran;
  final String kodeTagihan;
  final double nominal;
  final DateTime periode;
  final String status;
  final String? alamat;

  TagihanModel({
    required this.namaKeluarga,
    required this.statusKeluarga,
    required this.iuran,
    required this.kodeTagihan,
    required this.nominal,
    required this.periode,
    required this.status,
    this.alamat,
  });

  Future<List<TagihanModel>> fetchTagihan() async {
    try {
      final response = await Supabase.instance.client
          .from('tagihan_iuran')
          .select(
            '*, keluarga!id_keluarga(nama_keluarga, status_keluarga), iuran!id_iuran(nama, nominal), rumah!id_rumah(alamat)',
          );
      debugPrint('Tagihan fetched successfully: $response');
      return response.map<TagihanModel>((item) {
        return TagihanModel(
          namaKeluarga: item['keluarga']['nama_keluarga'] as String,
          statusKeluarga: item['keluarga']['status_keluarga'] as String,
          iuran: item['iuran']['nama'] as String,
          kodeTagihan: item['id'].toString(),
          nominal: (item['iuran']['nominal'] as num).toDouble(),
          periode: DateTime.parse(item['tgl_tagihan'] as String),
          status: item['status_pembayaran'] as String,
          alamat: item['rumah']['alamat'] as String?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching tagihan: $e');
      return Future.value(<TagihanModel>[]);
    }
  }
}
