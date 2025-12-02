class CartModel {
  final int? id;
  final String? userId;
  final int? productId;
  final int? qty;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartModel({
    this.id,
    this.userId,
    this.productId,
    this.qty,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON (dari Supabase)
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String?,
      productId: json['product_id'] as int?,
      qty: json['qty'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // To JSON (untuk insert/update ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (productId != null) 'product_id': productId,
      if (qty != null) 'qty': qty,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Copy with
  CartModel copyWith({
    int? id,
    String? userId,
    int? productId,
    int? qty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
