import 'dart:convert';
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
  final String? gambarDokumentasi;
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
    this.gambarDokumentasi,
    this.createdAt,
  });

  // copyWith wajib ada buat Edit screen
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
    String? gambarDokumentasi,
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
      gambarDokumentasi: gambarDokumentasi ?? this.gambarDokumentasi,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'judul': judul,
      'pj': pj,
      'tanggal': tanggal.toIso8601String(),
      'kategori': kategori,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'dibuat_oleh': dibuatOleh,
      'has_docs': hasDocs,
      'gambardokumentasi': gambarDokumentasi,
    };
  }

  factory KegiatanModel.fromMap(Map<String, dynamic> map) {
    // Helper parsing bool yang bandel
    bool? parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is String) return val.toLowerCase() == 'true';
      return false;
    }

    return KegiatanModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      judul: map['judul']?.toString() ?? 'Tanpa Judul',
      pj: map['pj']?.toString() ?? '-',
      tanggal: DateTime.tryParse(map['tanggal'].toString()) ?? DateTime.now(),
      kategori: map['kategori']?.toString() ?? 'Umum',
      lokasi: map['lokasi']?.toString() ?? '-',
      deskripsi: map['deskripsi']?.toString() ?? '',
      dibuatOleh: map['dibuat_oleh']?.toString(),
      hasDocs: parseBool(map['has_docs']),
      gambarDokumentasi: map['gambardokumentasi']?.toString(),
      createdAt: map['created_at'] != null 
          ? DateTime.tryParse(map['created_at'].toString()) 
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory KegiatanModel.fromJson(String source) =>
      KegiatanModel.fromMap(json.decode(source));
}