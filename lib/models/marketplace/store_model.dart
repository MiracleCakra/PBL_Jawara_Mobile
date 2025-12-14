class StoreModel {
  final int? storeId;
  final String? nama;
  final String? deskripsi;
  final String? alamat;
  final String? logo;
  final String? userId;
  final String? kontak;
  final String? verifikasi; // status penerimaan (pending, approved, rejected)
  final String? alasan; // alasan reject
  final String?
  deactivatedBy; // 'owner' = nonaktif sendiri, 'admin' = dinonaktifkan admin, null = aktif
  final DateTime? createdAt;

  StoreModel({
    this.storeId,
    this.nama,
    this.deskripsi,
    this.alamat,
    this.logo,
    this.userId,
    this.kontak,
    this.verifikasi,
    this.alasan,
    this.deactivatedBy,
    this.createdAt,
  });

  // From JSON (dari Supabase)
  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      storeId: json['store_id'] as int?,
      nama: json['nama'] as String?,
      deskripsi: json['deskripsi'] as String?,
      alamat: json['alamat'] as String?,
      logo: json['logo'] as String?,
      userId: json['user_id'] as String?,
      kontak: json['kontak'] as String?,
      verifikasi: json['verifikasi'] as String?,
      alasan: json['alasan'] as String?,
      deactivatedBy: json['deactivated_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // To JSON (untuk insert/update ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (storeId != null) 'store_id': storeId,
      if (nama != null) 'nama': nama,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (alamat != null) 'alamat': alamat,
      if (logo != null) 'logo': logo,
      if (userId != null) 'user_id': userId,
      if (kontak != null) 'kontak': kontak,
      if (verifikasi != null) 'verifikasi': verifikasi,
      if (alasan != null) 'alasan': alasan,
      if (deactivatedBy != null) 'deactivated_by': deactivatedBy,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  // Copy with
  StoreModel copyWith({
    int? storeId,
    String? nama,
    String? deskripsi,
    String? alamat,
    String? logo,
    String? userId,
    String? kontak,
    String? verifikasi,
    String? alasan,
    String? deactivatedBy,
    DateTime? createdAt,
  }) {
    return StoreModel(
      storeId: storeId ?? this.storeId,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      alamat: alamat ?? this.alamat,
      logo: logo ?? this.logo,
      userId: userId ?? this.userId,
      kontak: kontak ?? this.kontak,
      verifikasi: verifikasi ?? this.verifikasi,
      alasan: alasan ?? this.alasan,
      deactivatedBy: deactivatedBy ?? this.deactivatedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
