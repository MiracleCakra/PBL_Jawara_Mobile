import 'package:flutter/material.dart';
import '../models/warga_model.dart'; 

class Keluarga {
  final String id;
  final String namaKeluarga;
  final String kepalaKeluargaId;
  final String alamatRumah;
  final String statusKepemilikan;
  final String statusKeluarga;
  final Warga? kepalaKeluarga;
  final String? jenisMutasi;
  final String? alasanMutasi;
  final DateTime? tanggalMutasi;

  Keluarga({
    required this.id,
    required this.namaKeluarga,
    required this.kepalaKeluargaId,
    required this.alamatRumah,
    required this.statusKepemilikan,
    required this.statusKeluarga,
    this.kepalaKeluarga,
    this.jenisMutasi,
    this.alasanMutasi,
    this.tanggalMutasi,
  });

  factory Keluarga.fromJson(Map<String, dynamic> json) {
    return Keluarga(
      id: json['id'] as String? ?? 'UNKNOWN_ID',
      namaKeluarga: json['nama_keluarga'] as String? ?? 'Nama Keluarga Tidak Tersedia',
      kepalaKeluargaId: json['kepala_keluarga_id'] as String? ?? '',
      alamatRumah: json['alamat_rumah'] as String? ?? 'Alamat Tidak Ditemukan',
      statusKepemilikan: json['status_kepemilikan'] as String? ?? 'N/A',
      statusKeluarga: json['status_keluarga'] as String? ?? 'N/A',
      
      kepalaKeluarga: json['warga'] != null 
          ? Warga.fromJson(json['warga']) 
          : null,
          
      jenisMutasi: json['jenis_mutasi'] as String?,
      alasanMutasi: json['alasan_mutasi'] as String?,

      tanggalMutasi: json['tanggal_mutasi'] != null
          ? DateTime.parse(json['tanggal_mutasi'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_keluarga': namaKeluarga,
      'kepala_keluarga_id': kepalaKeluargaId,
      'alamat_rumah': alamatRumah,
      'status_kepemilikan': statusKepemilikan,
      'status_keluarga': statusKeluarga,
      'jenis_mutasi': jenisMutasi,
      'alasan_mutasi': alasanMutasi,
      'tanggal_mutasi': tanggalMutasi?.toIso8601String(),
    };
  }

  
  Color get statusColor {
    switch (statusKeluarga.toLowerCase()) {
      case 'aktif':
        return const Color(0xFF16A34A); // Green
      case 'nonaktif':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Grey
    }
  }

  Color get statusBackgroundColor {
    switch (statusKeluarga.toLowerCase()) {
      case 'aktif':
        return const Color(0xFFDCFCE7); // Light green
      case 'nonaktif':
        return const Color(0xFFFEE2E2); // Light red
      default:
        return const Color(0xFFF3F4F6); // Light grey
    }
  }
  
}