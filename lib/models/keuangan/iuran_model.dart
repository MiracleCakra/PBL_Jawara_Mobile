import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IuranModel {
  final int? no;
  final String namaIuran;
  final String jenisIuran;
  final double nominal;
  final String? status; // 'Aktif' atau 'Hidup'

  IuranModel({
    this.no,
    required this.namaIuran,
    required this.jenisIuran,
    required this.nominal,
    this.status,
  });

  Future<List<IuranModel>> fetchIuran() async {
    try {
      final response = await Supabase.instance.client.from('iuran').select('*');
      debugPrint('Iuran fetched successfully: $response');
      return response.map<IuranModel>((item) {
        return IuranModel(
          no: item['id'] as int?,
          namaIuran: item['nama'] as String,
          jenisIuran: item['kategori'] as String,
          nominal: (item['nominal'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching iuran: $e');
      return <IuranModel>[];
    }
  }

  Future<List<IuranOption>> fetchNamaIuran() async {
    try {
      final response = await Supabase.instance.client
          .from('iuran')
          .select('id, nama');

      List<IuranOption> options = [];
      for (var item in response) {
        options.add(
          IuranOption(
            id: item['id'], // Assuming 'id' is the primary key
            nama: item['nama'], // 'nama' is the column you want to display
          ),
        );
      }

      debugPrint('Nama and Id Iuran fetched successfully: $response');
      return options; // Return the list of IuranOption objects
    } catch (e) {
      debugPrint('Error fetching nama iuran: $e');
      return []; // Return an empty list in case of error
    }
  }

  saveIuran(String namaIuran, JenisIuran jenisIuran, double nominal) {
    Supabase.instance.client
        .from('iuran')
        .insert({
          'nama': namaIuran,
          'kategori': jenisIuran.displayName,
          'nominal': nominal,
        })
        .then((value) {
          debugPrint('Iuran saved successfully: $value');
        })
        .catchError((error) {
          debugPrint('Error saving iuran: $error');
        });
  }

  editIuran(int id, String namaIuran, JenisIuran jenisIuran, double nominal) {
    Supabase.instance.client
        .from('iuran')
        .update({
          'nama': namaIuran,
          'kategori': jenisIuran.displayName,
          'nominal': nominal,
        })
        .eq('id', id)
        .then((value) {
          debugPrint('Iuran updated successfully!');
        })
        .catchError((error) {
          debugPrint('Error updating iuran: $error');
        });
  }

  Future<void> saveTagihanForAllFamilies(
    String idIuran,
    DateTime tglTagihan,
  ) async {
    try {
      // Fetch all families from the 'keluarga' table where the status_keluarga is 'Aktif'
      final response = await Supabase.instance.client
          .from('keluarga')
          .select('id, alamat_rumah')
          .eq('status_keluarga', 'Aktif'); // Filter by status_keluarga 'Aktif'

      List<dynamic> families = response;

      // Loop through each family and create a tagihan
      for (var family in families) {
        String idKeluarga = family['id'].toString();
        await Supabase.instance.client
            .from('tagihan_iuran') // Reference only the 'tagihan_iuran' table
            .insert({
              'id_iuran': idIuran,
              'tgl_tagihan': tglTagihan.toIso8601String(),
              'id_keluarga': idKeluarga,
              'id_rumah': family['alamat_rumah'],
            });
      }
      debugPrint('Tagihan Iuran saved successfully for all families');
    } catch (e) {
      debugPrint('Error saving tagihan iuran: $e');
    }
  }
}

class IuranOption {
  final int id;
  final String nama;

  IuranOption({required this.id, required this.nama});
}

enum JenisIuran {
  bulanan('Iuran Bulanan'),
  khusus('Iuran Khusus');

  final String displayName;
  const JenisIuran(this.displayName);
}
