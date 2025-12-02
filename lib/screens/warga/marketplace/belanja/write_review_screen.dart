import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/review_service.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/ReviewModel.dart';

class WriteReviewScreen extends StatefulWidget {
  final int productId;
  final int orderId;

  const WriteReviewScreen({
    super.key,
    required this.productId,
    required this.orderId,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  static const Color primaryColor = Color(0xFF6A5AE0);
  
  final _reviewController = TextEditingController();
  final _reviewService = ReviewService();
  
  int _selectedRating = 0;
  bool _isSubmitting = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser?.email != null) {
      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', authUser!.email!)
          .maybeSingle();
      
      if (wargaResponse != null) {
        setState(() => _userId = wargaResponse['id'] as String);
      }
    }
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih rating terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_reviewController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ulasan minimal 10 karakter'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Check if user already reviewed this product
      final existingReview = await _reviewService.getUserReviewForProduct(
        _userId!,
        widget.productId,
      );

      if (existingReview != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anda sudah memberikan ulasan untuk produk ini'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      final review = ReviewModel(
        productId: widget.productId,
        userId: _userId,
        rating: _selectedRating,
        reviewText: _reviewController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _reviewService.createReview(review);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ulasan berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim ulasan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Tulis Ulasan Anda',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beri Penilaian:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starValue),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      _selectedRating >= starValue
                          ? Icons.star
                          : Icons.star_border,
                      size: 48,
                      color: _selectedRating >= starValue
                          ? Colors.amber
                          : Colors.grey.shade400,
                    ),
                  ),
                );
              }),
            ),
            if (_selectedRating > 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getRatingText(_selectedRating),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            const Text(
              'Komentar Anda (Min 10 karakter):',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewController,
              maxLines: 6,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Review produk ini...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '➤ Kirim Ulasan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Buruk';
      case 3:
        return 'Cukup';
      case 4:
        return 'Baik';
      case 5:
        return 'Sangat Baik';
      default:
        return '';
    }
  }
}
