class OrderItemModel {
  final int? id;
  final int? productId;
  final int? qty;
  final int? orderId;
  final DateTime? createdAt;

  OrderItemModel({
    this.id,
    this.productId,
    this.qty,
    this.orderId,
    this.createdAt,
  });

  // From JSON (dari Supabase)
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int?,
      productId: json['product_id'] as int?,
      qty: json['qty'] as int?,
      orderId: json['order_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // To JSON (untuk insert/update ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (qty != null) 'qty': qty,
      if (orderId != null) 'order_id': orderId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  // Copy with
  OrderItemModel copyWith({
    int? id,
    int? productId,
    int? qty,
    int? orderId,
    DateTime? createdAt,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
