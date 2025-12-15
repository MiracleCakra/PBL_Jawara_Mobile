import 'dart:convert';
import 'package:SapaWarga_kel_2/models/kegiatan/kegiatan_img_model.dart';

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
  final List<KegiatanImageModel>? images;

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
    this.images,
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
    List<KegiatanImageModel>? images,
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
      images: images ?? this.images,
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
      // Note: 'images' biasanya tidak di-insert langsung via toMap ke tabel kegiatan utama
    };
  }

  factory KegiatanModel.fromMap(Map<String, dynamic> map) {
    // Helper parsing bool yang bandel
    bool? parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is String) return val.toLowerCase() == 'true';
      return false;
    }

    String? primaryImage = map['gambardokumentasi']?.toString();
    
    // Parse images list first
    List<KegiatanImageModel> parsedImages = map['kegiatan_img'] != null
          ? (map['kegiatan_img'] as List)
              .map((x) => KegiatanImageModel.fromMap(x))
              .toList()
          : [];

    // Fallback: If gambardokumentasi is empty, use the first image from the list
    if ((primaryImage == null || primaryImage.isEmpty) && parsedImages.isNotEmpty) {
      primaryImage = parsedImages.first.img;
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
      gambarDokumentasi: primaryImage,
      createdAt: map['created_at'] != null 
          ? DateTime.tryParse(map['created_at'].toString()) 
          : null,
      images: parsedImages,
    );
  }

  String toJson() => json.encode(toMap());

  factory KegiatanModel.fromJson(String source) =>
      KegiatanModel.fromMap(json.decode(source));
}