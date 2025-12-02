import 'package:flutter/material.dart';
import '../../models/marketplace/ReviewModel.dart';
import '../../services/marketplace/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  
  List<ReviewModel> _reviews = [];
  double _averageRating = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  List<ReviewModel> get reviews => _reviews;
  double get averageRating => _averageRating;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReviewsByProduct(int productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await _reviewService.getReviewsByProduct(productId);
      _averageRating = await _reviewService.getAverageRating(productId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchReviewsByUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await _reviewService.getReviewsByUser(userId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ReviewModel?> createReview(ReviewModel review) async {
    try {
      final newReview = await _reviewService.createReview(review);
      _reviews.insert(0, newReview);
      notifyListeners();
      return newReview;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateReview(int reviewId, ReviewModel review) async {
    try {
      final updated = await _reviewService.updateReview(reviewId, review);
      int index = _reviews.indexWhere((r) => r.reviewId == reviewId);
      if (index != -1) {
        _reviews[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addSellerReply(int reviewId, String reply) async {
    try {
      await _reviewService.addSellerReply(reviewId, reply);
      int index = _reviews.indexWhere((r) => r.reviewId == reviewId);
      if (index != -1) {
        _reviews[index] = _reviews[index].copyWith(reviewReply: reply);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReview(int reviewId) async {
    try {
      await _reviewService.deleteReview(reviewId);
      _reviews.removeWhere((r) => r.reviewId == reviewId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
