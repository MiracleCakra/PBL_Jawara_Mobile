import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/review_model.dart';

void main() {
  group('ReviewModel Test', () {
    test('should create ReviewModel from JSON correctly', () {
      final json = {
        'review_id': 10,
        'product_id': 5,
        'user_id': 'user123',
        'rating': 4,
        'review_text': 'Produk bagus!',
        'review_reply': 'Terima kasih!',
        'created_at': '2025-01-15T12:00:00Z',
        'updated_at': '2025-01-16T10:00:00Z',
      };

      final review = ReviewModel.fromJson(json);

      expect(review.reviewId, 10);
      expect(review.productId, 5);
      expect(review.userId, 'user123');
      expect(review.rating, 4);
      expect(review.reviewText, 'Produk bagus!');
      expect(review.reviewReply, 'Terima kasih!');
      expect(review.createdAt, DateTime.parse('2025-01-15T12:00:00Z'));
      expect(review.updatedAt, DateTime.parse('2025-01-16T10:00:00Z'));
    });

    test('toJson should convert ReviewModel to JSON correctly', () {
      final review = ReviewModel(
        reviewId: 10,
        productId: 5,
        userId: 'user123',
        rating: 4,
        reviewText: 'Produk bagus!',
        reviewReply: 'Terima kasih!',
        createdAt: DateTime.parse('2025-01-15T12:00:00Z'),
        updatedAt: DateTime.parse('2025-01-16T10:00:00Z'),
      );

      final json = review.toJson();

      expect(json['review_id'], 10);
      expect(json['product_id'], 5);
      expect(json['user_id'], 'user123');
      expect(json['rating'], 4);
      expect(json['review_text'], 'Produk bagus!');
      expect(json['review_reply'], 'Terima kasih!');
      expect(json['created_at'], '2025-01-15T12:00:00.000Z');
      expect(json['updated_at'], '2025-01-16T10:00:00.000Z');
    });

    test('copyWith should update only selected fields', () {
      final original = ReviewModel(
        reviewId: 10,
        productId: 5,
        userId: 'user123',
        rating: 4,
        reviewText: 'Produk bagus!',
        reviewReply: 'Terima kasih!',
        createdAt: DateTime.parse('2025-01-15T12:00:00Z'),
        updatedAt: DateTime.parse('2025-01-16T10:00:00Z'),
      );

      final updated = original.copyWith(
        rating: 5,
        reviewReply: 'Terima kasih banyak!',
      );

      expect(updated.rating, 5);
      expect(updated.reviewReply, 'Terima kasih banyak!');

      // Field lain harus tetap sama
      expect(updated.reviewId, 10);
      expect(updated.productId, 5);
      expect(updated.userId, 'user123');
      expect(updated.reviewText, 'Produk bagus!');
    });

    test('copyWith without params should keep original data', () {
      final review = ReviewModel(
        reviewId: 10,
        productId: 5,
        userId: 'user123',
        rating: 4,
        reviewText: 'Nice!',
        reviewReply: 'Thanks!',
        createdAt: DateTime.parse('2025-01-15T12:00:00Z'),
        updatedAt: DateTime.parse('2025-01-16T10:00:00Z'),
      );

      final copied = review.copyWith();

      expect(copied.reviewId, review.reviewId);
      expect(copied.rating, review.rating);
      expect(copied.reviewText, review.reviewText);
      expect(copied.reviewReply, review.reviewReply);
    });
  });
}
