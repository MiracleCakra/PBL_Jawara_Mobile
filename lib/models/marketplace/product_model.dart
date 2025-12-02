class ProductModel {
  final int? productId;
  final String? nama;
  final String? deskripsi;
  final double? harga; // harga dari supabase adalah numeric
  final int? stok;
  final String? gambar;
  final String? grade; // Grade A, B, C
  final String? satuan; // kg, ikat, pcs, karung
  final int? storeId;
  final DateTime? createdAt;

  ProductModel({
    this.productId,
    this.nama,
    this.deskripsi,
    this.harga,
    this.stok,
    this.gambar,
    this.grade,
    this.satuan,
    this.storeId,
    this.createdAt,
  });

  // From JSON (dari Supabase)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['product_id'] as int?,
      nama: json['nama'] as String?,
      deskripsi: json['deskripsi'] as String?,
      harga: (json['harga'] as num?)?.toDouble(),
      stok: json['stok'] as int?,
      gambar: json['gambar'] as String?,
      grade: json['grade'] as String?,
      satuan: json['satuan'] as String?,
      storeId: json['store_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // To JSON (untuk insert/update ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'product_id': productId,
      if (nama != null) 'nama': nama,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (harga != null) 'harga': harga,
      if (stok != null) 'stok': stok,
      if (gambar != null) 'gambar': gambar,
      if (grade != null) 'grade': grade,
      if (satuan != null) 'satuan': satuan,
      if (storeId != null) 'store_id': storeId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  // Copy with
  ProductModel copyWith({
    int? productId,
    String? nama,
    String? deskripsi,
    double? harga,
    int? stok,
    String? gambar,
    String? grade,
    String? satuan,
    int? storeId,
    DateTime? createdAt,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      gambar: gambar ?? this.gambar,
      grade: grade ?? this.grade,
      satuan: satuan ?? this.satuan,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
