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
      id: json['id'],
      namaKeluarga: json['nama_keluarga'],
      kepalaKeluargaId: json['kepala_keluarga_id'],
      alamatRumah: json['alamat_rumah'],
      statusKepemilikan: json['status_kepemilikan'],
      statusKeluarga: json['status_keluarga'],
      kepalaKeluarga: json['warga'] != null ? Warga.fromJson(json['warga']) : null,
      jenisMutasi: json['jenis_mutasi'],
      alasanMutasi: json['alasan_mutasi'],
      tanggalMutasi: json['tanggal_mutasi'] != null
          ? DateTime.parse(json['tanggal_mutasi'])
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
}
