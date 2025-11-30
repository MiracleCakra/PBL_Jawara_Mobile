import 'dart:convert';
import 'package:intl/intl.dart';

class KegiatanModel {
  final int? id;
  final String judul;
  final String pj;
  final DateTime tanggal;
  final String kategori;
  final String lokasi;
  final String deskripsi;
  final String? dibuatOleh;
  final bool? hasDocs;
  final DateTime? createdAt;

  KegiatanModel({
    this.id,
    required this.judul,
    required this.pj,
    required this.tanggal,
    required this.kategori,
    required this.lokasi,
    required this.deskripsi,
    this.dibuatOleh,
    this.hasDocs,
    this.createdAt,
  });

  KegiatanModel copyWith({
    int? id,
    String? judul,
    String? pj,
    DateTime? tanggal,
    String? kategori,
    String? lokasi,
    String? deskripsi,
    String? dibuatOleh,
    bool? hasDocs,
    DateTime? createdAt,
  }) {
    return KegiatanModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      pj: pj ?? this.pj,
      tanggal: tanggal ?? this.tanggal,
      kategori: kategori ?? this.kategori,
      lokasi: lokasi ?? this.lokasi,
      deskripsi: deskripsi ?? this.deskripsi,
      dibuatOleh: dibuatOleh ?? this.dibuatOleh,
      hasDocs: hasDocs ?? this.hasDocs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'pj': pj,
      'tanggal': tanggal.toIso8601String(), // Use ISO 8601 format
      'kategori': kategori,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'dibuat_oleh': dibuatOleh,
      'has_docs': hasDocs.toString(), // Convert bool to String
      // 'created_at' is handled by the database
    };
  }

  factory KegiatanModel.fromMap(Map<String, dynamic> map) {
    return KegiatanModel(
      id: map['id']?.toInt(),
      judul: map['judul'] ?? '',
      pj: map['pj'] ?? '',
      tanggal: DateTime.parse(map['tanggal']), // Parse ISO 8601 format
      kategori: map['kategori'] ?? '',
      lokasi: map['lokasi'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      dibuatOleh: map['dibuat_oleh'],
      // Convert String 'true'/'false' to bool
      hasDocs: map['has_docs']?.toString().toLowerCase() == 'true',
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory KegiatanModel.fromJson(String source) =>
      KegiatanModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'KegiatanModel(id: $id, judul: $judul, pj: $pj, tanggal: $tanggal, kategori: $kategori, lokasi: $lokasi, deskripsi: $deskripsi, dibuatOleh: $dibuatOleh, hasDocs: $hasDocs, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is KegiatanModel &&
        other.id == id &&
        other.judul == judul &&
        other.pj == pj &&
        other.tanggal == tanggal &&
        other.kategori == kategori &&
        other.lokasi == lokasi &&
        other.deskripsi == deskripsi &&
        other.dibuatOleh == dibuatOleh &&
        other.hasDocs == hasDocs &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        judul.hashCode ^
        pj.hashCode ^
        tanggal.hashCode ^
        kategori.hashCode ^
        lokasi.hashCode ^
        deskripsi.hashCode ^
        dibuatOleh.hashCode ^
        hasDocs.hashCode ^
        createdAt.hashCode;
  }
}
