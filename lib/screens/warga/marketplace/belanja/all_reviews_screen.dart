import 'package:flutter/material.dart';
import 'package:SapaWarga_kel_2/models/marketplace/product_model.dart';
import 'package:SapaWarga_kel_2/services/marketplace/review_service.dart';

class AllReviewsScreen extends StatefulWidget {
  final ProductModel product;

  const AllReviewsScreen({super.key, required this.product});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  final _reviewService = ReviewService();
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  double _averageRating = 0.0;

  // Rating distribution
  Map<int, int> _ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _reviewService.getReviewsWithUserInfo(
        widget.product.productId!,
      );

      // Calculate average rating and distribution
      double totalRating = 0;
      Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (var review in reviews) {
        final rating = review['rating'] as int? ?? 0;
        totalRating += rating;
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }

      setState(() {
        _reviews = reviews;
        _averageRating = reviews.isEmpty ? 0 : totalRating / reviews.length;
        _ratingDistribution = distribution;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Semua Ulasan'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                _buildRatingSummary(),
                const Divider(height: 1),
                Expanded(child: _buildReviewsList()),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Ulasan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jadilah yang pertama memberikan ulasan',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Average rating
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A5AE0),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < _averageRating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_reviews.length} ulasan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right: Rating bars
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    for (int rating = 5; rating >= 1; rating--)
                      _buildRatingBar(rating),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int rating) {
    final count = _ratingDistribution[rating] ?? 0;
    final percentage = _reviews.isEmpty ? 0.0 : (count / _reviews.length);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text(
            '$rating',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6A5AE0),
                ),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final userName = review['user_name'] as String? ?? 'Pembeli';
    final reviewText = review['review_text'] as String? ?? '';
    final rating = review['rating'] as int? ?? 0;
    final createdAt = review['created_at'] != null
        ? DateTime.parse(review['created_at'] as String)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF6A5AE0).withOpacity(0.1),
                radius: 20,
                child: Text(
                  userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF6A5AE0),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 14,
                            ),
                          ),
                        ),
                        if (createdAt != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (reviewText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              reviewText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit lalu';
      }
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} minggu lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
