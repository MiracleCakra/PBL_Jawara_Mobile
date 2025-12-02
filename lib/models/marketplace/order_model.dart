class OrderModel {
  final int? orderId;
  final String? userId;
  final double? totalPrice;
  final String?
  orderStatus; // pending, processing, shipped, delivered, cancelled
  final String? alamat;
  final int? totalQty;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    this.orderId,
    this.userId,
    this.totalPrice,
    this.orderStatus,
    this.alamat,
    this.totalQty,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON (dari Supabase)
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] as int?,
      userId: json['user_id'] as String?,
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      orderStatus: json['order_status'] as String?,
      alamat: json['alamat'] as String?,
      totalQty: json['total_qty'] as int?,
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
      if (orderId != null) 'order_id': orderId,
      if (userId != null) 'user_id': userId,
      if (totalPrice != null) 'total_price': totalPrice,
      if (orderStatus != null) 'order_status': orderStatus,
      if (alamat != null) 'alamat': alamat,
      if (totalQty != null) 'total_qty': totalQty,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Copy with
  OrderModel copyWith({
    int? orderId,
    String? userId,
    double? totalPrice,
    String? orderStatus,
    String? alamat,
    int? totalQty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      totalPrice: totalPrice ?? this.totalPrice,
      orderStatus: orderStatus ?? this.orderStatus,
      alamat: alamat ?? this.alamat,
      totalQty: totalQty ?? this.totalQty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayStatus => orderStatus ?? 'Unknown';
}
