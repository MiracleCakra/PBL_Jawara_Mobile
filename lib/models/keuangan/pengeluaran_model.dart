import 'package:flutter/material.dart';

class PengeluaranModel {
  final int id;
  final String nama;
  final String jenisPengeluaran;
  final DateTime tanggal;
  final double nominal;
  final String status; // Status badge
  final String idCode; // ID code seperti IR175458A501
  final DateTime? tanggalVerifikasi; // Tanggal terverifikasi
  final String? verifikator; // Nama verifikator

  PengeluaranModel({
    required this.id,
    required this.nama,
    required this.jenisPengeluaran,
    required this.tanggal,
    required this.nominal,
    required this.status,
    required this.idCode,
    this.tanggalVerifikasi,
    this.verifikator,
  });

  // Sample data sesuai dengan gambar
  static List<PengeluaranModel> getSampleData() {
    return [
      PengeluaranModel(
        id: 1,
        nama: 'Kerja Bakti',
        jenisPengeluaran: 'Kegiatan Warga',
        tanggal: DateTime(2025, 10, 19),
        nominal: 100000.00,
        status: 'Terverifikasi',
        idCode: 'PE001',
        tanggalVerifikasi: DateTime(2025, 10, 19, 20, 26),
        verifikator: 'Admin Jawara',
      ),
      PengeluaranModel(
        id: 2,
        nama: 'Kerja Bakti',
        jenisPengeluaran: 'Pemeliharaan Fasilitas',
        tanggal: DateTime(2025, 10, 19),
        nominal: 50000.00,
        status: 'Terverifikasi',
        idCode: 'PE002',
        tanggalVerifikasi: DateTime(2025, 10, 19, 20, 26),
        verifikator: 'Admin Jawara',
      ),
      PengeluaranModel(
        id: 3,
        nama: 'Arka',
        jenisPengeluaran: 'Operasional RT/RW',
        tanggal: DateTime(2025, 10, 17),
        nominal: 6.00,
        status: 'Belum Diverifikasi',
        idCode: 'PE003',
      ),
      PengeluaranModel(
        id: 4,
        nama: 'adsad',
        jenisPengeluaran: 'Pemeliharaan Fasilitas',
        tanggal: DateTime(2025, 10, 2),
        nominal: 2112.00,
        status: 'Belum Diverifikasi',
        idCode: 'PE004',
      ),
    ];
  }

  String getFormattedNominal() {
    return 'Rp ${nominal.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String getFormattedTanggal() {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${tanggal.day} ${months[tanggal.month - 1]} ${tanggal.year}';
  }

  String getShortTanggal() {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${tanggal.day} ${months[tanggal.month - 1]} ${tanggal.year}';
  }

  String getFormattedVerifikasi() {
    if (tanggalVerifikasi == null) return '-';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${tanggalVerifikasi!.day} ${months[tanggalVerifikasi!.month - 1]} ${tanggalVerifikasi!.year} ${tanggalVerifikasi!.hour.toString().padLeft(2, '0')}:${tanggalVerifikasi!.minute.toString().padLeft(2, '0')}';
  }

  Color getStatusColor() {
    switch (status) {
      case 'Terverifikasi':
        return const Color(0xFF10B981); // Green
      case 'Belum Diverifikasi':
        return const Color(0xFFFFA726); // Orange
      default:
        return const Color(0xFF6B7280); // Grey
    }
  }

  Color getStatusBackgroundColor() {
    switch (status) {
      case 'Terverifikasi':
        return const Color(0xFFD1FAE5); // Light Green
      case 'Belum Diverifikasi':
        return const Color(0xFFFFF3E0); // Light Orange
      default:
        return const Color(0xFFF3F4F6); // Light Grey
    }
  }
}
