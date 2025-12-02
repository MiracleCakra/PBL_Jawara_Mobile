class ReviewModel {
  final int? reviewId;
  final int? productId;
  final String? userId;
  final int? rating; // 1-5
  final String? reviewText;
  final String? reviewReply; // balasan dari seller
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    this.reviewId,
    this.productId,
    this.userId,
    this.rating,
    this.reviewText,
    this.reviewReply,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON (dari Supabase)
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['review_id'] as int?,
      productId: json['product_id'] as int?,
      userId: json['user_id'] as String?,
      rating: json['rating'] as int?,
      reviewText: json['review_text'] as String?,
      reviewReply: json['review_reply'] as String?,
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
      if (reviewId != null) 'review_id': reviewId,
      if (productId != null) 'product_id': productId,
      if (userId != null) 'user_id': userId,
      if (rating != null) 'rating': rating,
      if (reviewText != null) 'review_text': reviewText,
      if (reviewReply != null) 'review_reply': reviewReply,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Copy with
  ReviewModel copyWith({
    int? reviewId,
    int? productId,
    String? userId,
    int? rating,
    String? reviewText,
    String? reviewReply,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      reviewReply: reviewReply ?? this.reviewReply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Dummy reviews untuk testing UI (akan diganti dengan data dari Supabase)
List<ReviewModel> dummyReviews = [];