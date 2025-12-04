import 'dart:convert';

class ChannelTransferModel {
  final int? id;
  final String nama;
  final String tipe;
  final String norek;
  final String pemilik;
  final String catatan;
  final String? qrisImg;
  final DateTime? createdAt;

  ChannelTransferModel({
    this.id,
    required this.nama,
    required this.tipe,
    required this.norek,
    required this.pemilik,
    required this.catatan,
    this.qrisImg,
    this.createdAt,
  });

  // CopyWith untuk Edit data
  ChannelTransferModel copyWith({
    int? id,
    String? nama,
    String? tipe,
    String? norek,
    String? pemilik,
    String? catatan,
    String? qrisImg,
    DateTime? createdAt,
  }) {
    return ChannelTransferModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tipe: tipe ?? this.tipe,
      norek: norek ?? this.norek,
      pemilik: pemilik ?? this.pemilik,
      catatan: catatan ?? this.catatan,
      qrisImg: qrisImg ?? this.qrisImg,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Mapping ke Database (Kolom DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'tipe': tipe,
      'norek': norek,
      'pemilik': pemilik,
      'catatan': catatan,
      'qris_img': qrisImg,
    };
  }

  // Mapping dari Database ke Model
  factory ChannelTransferModel.fromMap(Map<String, dynamic> map) {
    return ChannelTransferModel(
      id: map['id']?.toInt(),
      nama: map['nama'] ?? '',
      tipe: map['tipe'] ?? 'Bank',
      norek: map['norek'] ?? '',
      pemilik: map['pemilik'] ?? '',
      catatan: map['catatan'] ?? '',
      qrisImg: map['qris_img'],
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChannelTransferModel.fromJson(String source) =>
      ChannelTransferModel.fromMap(json.decode(source));
}