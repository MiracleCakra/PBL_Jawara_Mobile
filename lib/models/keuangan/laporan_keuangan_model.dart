import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanKeuanganModel {
  final String nama;
  final String? kategoriPemasukan;
  final String? kategoriPengeluaran;
  final DateTime tanggal;
  final int nominal;
  final String? verifikator;
  final String? buktiFoto;

  LaporanKeuanganModel({
    required this.nama,
    this.kategoriPemasukan,
    this.kategoriPengeluaran,
    required this.tanggal,
    required this.nominal,
    this.verifikator,
    this.buktiFoto,
  });

  Future<List<LaporanKeuanganModel>> fetchIuran() async {
    try {
      final response = await Supabase.instance.client
          .from('tagihan_iuran')
          .select(
            'status_pembayaran, tgl_bayar, bukti_pembayaran, iuran!id_iuran(nama, nominal)',
          )
          .eq('status_pembayaran', 'Terverifikasi');
      debugPrint('Iuran fetched successfully: $response');
      return response.map<LaporanKeuanganModel>((item) {
        return LaporanKeuanganModel(
          tanggal: DateTime.parse(item['tgl_bayar'] as String),
          nama: 'Iuran ${item['iuran']['nama'] as String}',
          nominal: (item['iuran']['nominal'] as num).toInt(),
          kategoriPemasukan: 'Iuran',
          buktiFoto: item['bukti_pembayaran'] as String?,
          verifikator: 'Admin Jawara',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching iuran: $e');
      return Future.value(<LaporanKeuanganModel>[]);
    }
  }

  Future<List<LaporanKeuanganModel>> fetchPemasukan() async {
    try {
      // Fetch data from 'pemasukan' and 'iuran'
      final pemasukanResponse = await Supabase.instance.client
          .from('pemasukan')
          .select('*');
      debugPrint('Pemasukan and Iuran fetched successfully');

      return pemasukanResponse.map<LaporanKeuanganModel>((item) {
        return LaporanKeuanganModel(
          tanggal: DateTime.parse(item['tanggal'] as String),
          nama: item['nama'] as String,
          nominal: (item['nominal'] as num).toInt(),
          kategoriPemasukan: item['kategori'] as String,
          buktiFoto: item['bukti'] as String,
          verifikator: item['verifikator'] ?? 'Admin Jawara',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching pemasukan: $e');
      return Future.value(<LaporanKeuanganModel>[]);
    }
  }

  Future fetchPengeluaran() async {
    try {
      final response = await Supabase.instance.client
          .from('pengeluaran')
          .select('*');
      debugPrint('Pengeluaran fetched successfully: $response');
      return response.map<LaporanKeuanganModel>((item) {
        return LaporanKeuanganModel(
          tanggal: DateTime.parse(item['tanggal'] as String),
          nama: item['nama'] as String,
          nominal: (item['nominal'] as num).toInt(),
          kategoriPengeluaran: item['kategori'] as String,
          buktiFoto: item['bukti'] as String,
          verifikator: item['verifikator'] ?? 'Admin Jawara',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching pengeluaran: $e');
      return Future.value(<LaporanKeuanganModel>[]);
    }
  }

  savePemasukan(
    String nama,
    double nominal,
    String kategoriPemasukan,
    String buktiFoto,
    DateTime tanggal,
    String? verifikator,
  ) {
    Supabase.instance.client
        .from('pemasukan')
        .insert({
          'nama': nama,
          'nominal': nominal.toInt(),
          'kategori': kategoriPemasukan,
          'bukti': buktiFoto,
          'tanggal': tanggal.toIso8601String(),
          'verifikator': verifikator ?? 'Admin Jawara',
        })
        .then((value) {
          debugPrint('Pemasukan saved successfully: $value');
        })
        .catchError((error) {
          debugPrint('Error saving pemasukan: $error');
        });
  }

  savePengeluaran(
    String nama,
    double nominal,
    String kategoriPengeluaran,
    String buktiFoto,
    DateTime tanggal,
    String? verifikator,
  ) {
    Supabase.instance.client
        .from('pengeluaran')
        .insert({
          'nama': nama,
          'nominal': nominal.toInt(),
          'kategori': kategoriPengeluaran,
          'bukti': buktiFoto,
          'tanggal': tanggal.toIso8601String(),
          'verifikator': verifikator ?? 'Admin Jawara',
        })
        .then((value) {
          debugPrint('Pengeluaran saved successfully: $value');
        })
        .catchError((error) {
          debugPrint('Error saving pengeluaran: $error');
        });
  }

  getTotalPemasukanThisYear() {
    final currentYear = DateTime.now().year;
    return Supabase.instance.client
        .from('pemasukan')
        .select('nominal')
        .gte('tanggal', '$currentYear-01-01') // Start of the current year
        .lte('tanggal', '$currentYear-12-31'); // End of the current year
  }

  countTotalPemasukanThisYear() async {
    try {
      // Fetch the pemasukan data for the current year
      final response = await getTotalPemasukanThisYear();

      debugPrint('Data pemasukan fetched successfully: $response');

      // Ensure the response contains data and calculate the total pemasukan by summing up the 'nominal' field
      if (response.isEmpty) {
        return 0; // If no data, return 0
      }

      // Sum all the nominal values by explicitly casting each 'nominal' to an integer
      int totalPemasukan = response
          .map<int>(
            (item) => (item['nominal'] as num).toInt(),
          ) // Convert 'nominal' to int
          .fold(
            0,
            (a, b) => a + b,
          ); // Use fold to explicitly define types for the accumulation

      return totalPemasukan; // Return the formatted string
    } catch (e) {
      debugPrint('Error: $e');
      return 0;
    }
  }

  getTotalPengeluaranThisYear() async {
    final currentYear = DateTime.now().year;
    return Supabase.instance.client
        .from('pengeluaran')
        .select('nominal')
        .gte('tanggal', '$currentYear-01-01') // Start of the current year
        .lte('tanggal', '$currentYear-12-31'); // End of the current year
  }

  countTotalPengeluaranThisYear() async {
    try {
      // Fetch the pemasukan data for the current year
      final response = await getTotalPengeluaranThisYear();

      debugPrint('Data pengeluaran fetched successfully: $response');

      // Ensure the response contains data and calculate the total pemasukan by summing up the 'nominal' field
      if (response.isEmpty) {
        return 0; // If no data, return 0
      }

      // Sum all the nominal values by explicitly casting each 'nominal' to an integer
      int totalPengeluaran = response
          .map<int>(
            (item) => (item['nominal'] as num).toInt(),
          ) // Convert 'nominal' to int
          .fold(
            0,
            (a, b) => a + b,
          ); // Use fold to explicitly define types for the accumulation

      return totalPengeluaran; // Return the formatted string
    } catch (e) {
      debugPrint('Error: $e');
      return 0;
    }
  }
}

enum KategoriPengeluaran {
  operasional('Operasional'),
  pembangunan('Pembangunan'),
  pemeliharaan('Pemeliharaan'),
  kegiatanSosial('Kegiatan Sosial'),
  administrasi('Administrasi'),
  honorarium('Honorarium'),
  transportasi('Transportasi'),
  konsumsi('Konsumsi'),
  peralatan('Peralatan'),
  lainnya('Lainnya');

  // Enum values
  final String value;
  // Enum constructor
  const KategoriPengeluaran(this.value);

  // Enum fromString method
  static KategoriPengeluaran? fromString(String? value) {
    if (value == null) return null;
    try {
      return KategoriPengeluaran.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}
