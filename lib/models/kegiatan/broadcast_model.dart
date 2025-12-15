import 'dart:convert';
import 'package:flutter/foundation.dart';

class BroadcastModel {
  final int? id;
  final String judul;
  final String pengirim;
  final DateTime tanggal;
  final String kategori;
  final String konten;
  final String? lampiranGambarUrl; // URL Gambar
  final String? lampiranDokumenUrl; // URL Dokumen (PDF) - Diubah dari List jadi String?
  final DateTime? createdAt;

  BroadcastModel({
    this.id,
    required this.judul,
    required this.pengirim,
    required this.tanggal,
    required this.kategori,
    required this.konten,
    this.lampiranGambarUrl,
    this.lampiranDokumenUrl,
    this.createdAt,
  });

  BroadcastModel copyWith({
    int? id,
    String? judul,
    String? pengirim,
    DateTime? tanggal,
    String? kategori,
    String? konten,
    String? lampiranGambarUrl,
    String? lampiranDokumenUrl,
    DateTime? createdAt,
  }) {
    return BroadcastModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      pengirim: pengirim ?? this.pengirim,
      tanggal: tanggal ?? this.tanggal,
      kategori: kategori ?? this.kategori,
      konten: konten ?? this.konten,
      lampiranGambarUrl: lampiranGambarUrl ?? this.lampiranGambarUrl,
      lampiranDokumenUrl: lampiranDokumenUrl ?? this.lampiranDokumenUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'pengirim': pengirim,
      'tanggal': tanggal.toIso8601String(),
      'kategori': kategori,
      'konten': konten,
      'lampiranGambarUrl': lampiranGambarUrl,
      'lampiranDokumen': lampiranDokumenUrl,
    };
  }

  factory BroadcastModel.fromMap(Map<String, dynamic> map) {
    // Helper buat handle dokumen yang mungkin null atau string kosong
    String? docUrl;
    if (map['lampiran_dokumen'] != null && map['lampiran_dokumen'].toString().isNotEmpty) {
       docUrl = map['lampiran_dokumen'].toString();
    } else if (map['lampiranDokumen'] != null && map['lampiranDokumen'].toString().isNotEmpty) {
       // Fallback for mixed naming if exists or if schema is strict
       docUrl = map['lampiranDokumen'].toString();
    }

    return BroadcastModel(
      id: map['id']?.toInt(),
      judul: map['judul'] ?? '',
      pengirim: map['pengirim'] ?? '',
      tanggal: DateTime.tryParse(map['tanggal'].toString()) ?? DateTime.now(),
      kategori: map['kategori'] ?? '',
      konten: map['konten'] ?? '',
      lampiranGambarUrl: map['lampiranGambarUrl'] as String?,
      lampiranDokumenUrl: docUrl,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory BroadcastModel.fromJson(String source) =>
      BroadcastModel.fromMap(json.decode(source));
}