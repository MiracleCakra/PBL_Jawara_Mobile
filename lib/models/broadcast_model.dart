import 'dart:convert';

import 'package:flutter/foundation.dart';

class BroadcastModel {
  final int? id;
  final String judul;
  final String pengirim;
  final DateTime tanggal;
  final String kategori;
  final String konten;
  final String? lampiranGambarUrl;
  final List<String> lampiranDokumen;
  final DateTime? createdAt;

  BroadcastModel({
    this.id,
    required this.judul,
    required this.pengirim,
    required this.tanggal,
    required this.kategori,
    required this.konten,
    this.lampiranGambarUrl,
    this.lampiranDokumen = const [],
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
    List<String>? lampiranDokumen,
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
      lampiranDokumen: lampiranDokumen ?? this.lampiranDokumen,
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
      'lampiranDokumen': lampiranDokumen,
    };
  }

    factory BroadcastModel.fromMap(Map<String, dynamic> map) {
    List<String> doks = [];
    final dynamic lampiranData = map['lampiranDokumen'];

    if (lampiranData is List) {
      // Case 1: Already a list (correct jsonb type)
      doks = List<String>.from(lampiranData.map((item) => item.toString()));
    } else if (lampiranData is String) {
      // Case 2: It's a string.
      if (lampiranData.startsWith('[') && lampiranData.endsWith(']')) {
        // It looks like a JSON array string
        try {
          final decoded = json.decode(lampiranData);
          if (decoded is List) {
            doks = List<String>.from(decoded.map((item) => item.toString()));
          } 
        } catch (e) {
          // It looked like a JSON array but wasn't. Ignore.
        }
      } else if (lampiranData.isNotEmpty) {
        // Case 3: It's a non-empty, non-JSON-array string. Treat as a single item.
        doks = [lampiranData];
      }
    }
    // Case 4 (null) is handled by initializing doks = []

    return BroadcastModel(
      id: map['id']?.toInt(),
      judul: map['judul'] ?? '',
      pengirim: map['pengirim'] ?? '',
      tanggal: DateTime.parse(map['tanggal']),
      kategori: map['kategori'] ?? '',
      konten: map['konten'] ?? '',
      lampiranGambarUrl: map['lampiranGambarUrl'] as String?,
      lampiranDokumen: doks,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at']),
    );
  }


  String toJson() => json.encode(toMap());

  factory BroadcastModel.fromJson(String source) =>
      BroadcastModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BroadcastModel(id: $id, judul: $judul, pengirim: $pengirim, tanggal: $tanggal, kategori: $kategori, konten: $konten, lampiranGambarUrl: $lampiranGambarUrl, lampiranDokumen: $lampiranDokumen, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is BroadcastModel &&
      other.id == id &&
      other.judul == judul &&
      other.pengirim == pengirim &&
      other.tanggal == tanggal &&
      other.kategori == kategori &&
      other.konten == konten &&
      other.lampiranGambarUrl == lampiranGambarUrl &&
      listEquals(other.lampiranDokumen, lampiranDokumen) &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      judul.hashCode ^
      pengirim.hashCode ^
      tanggal.hashCode ^
      kategori.hashCode ^
      konten.hashCode ^
      lampiranGambarUrl.hashCode ^
      lampiranDokumen.hashCode ^
      createdAt.hashCode;
  }
}
