import 'dart:convert';

class AspirasiModel {
  final int? id;
  final String pengirim;
  final String judul;
  final DateTime tanggal;
  final String isi;
  final String status;
  final String? userId; //Foreign key to link with user table (warga)
  final DateTime? createdAt;

  AspirasiModel({
    this.id,
    required this.pengirim,
    required this.judul,
    required this.tanggal,
    required this.isi,
    required this.status,
    this.userId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pengirim': pengirim,
      'judul': judul,
      'tanggal': tanggal.toIso8601String(),
      'isi': isi,
      'status': status,
      'user_id': userId,
    };
  }

  factory AspirasiModel.fromMap(Map<String, dynamic> map) {
    return AspirasiModel(
      id: map['id']?.toInt(),
      pengirim: map['pengirim'] ?? '',
      judul: map['judul'] ?? '',
      tanggal: DateTime.parse(map['tanggal']),
      isi: map['isi'] ?? '',
      status: map['status'] ?? 'Pending',
      userId: map['user_id'],
      createdAt:
          map['created_at'] == null ? null : DateTime.parse(map['created_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AspirasiModel.fromJson(String source) =>
      AspirasiModel.fromMap(json.decode(source));

  AspirasiModel copyWith({
    int? id,
    String? pengirim,
    String? judul,
    DateTime? tanggal,
    String? isi,
    String? status,
    String? userId,
    DateTime? createdAt,
  }) {
    return AspirasiModel(
      id: id ?? this.id,
      pengirim: pengirim ?? this.pengirim,
      judul: judul ?? this.judul,
      tanggal: tanggal ?? this.tanggal,
      isi: isi ?? this.isi,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
