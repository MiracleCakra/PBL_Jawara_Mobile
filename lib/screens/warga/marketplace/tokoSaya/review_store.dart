import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/review_service.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/store_service.dart';

class MyStoreReviewsScreen extends StatefulWidget {
  const MyStoreReviewsScreen({super.key});

  @override
  _MyStoreReviewsScreenState createState() => _MyStoreReviewsScreenState();
}

class _MyStoreReviewsScreenState extends State<MyStoreReviewsScreen> {
  static const primaryColor = Color(0xFF6A5AE0);
  
  final _reviewService = ReviewService();
  final _storeService = StoreService();
  
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    
    try {
      // Get store ID dari email user
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser?.email != null) {
        final wargaResponse = await Supabase.instance.client
            .from('warga')
            .select('id')
            .eq('email', authUser!.email!)
            .maybeSingle();
        
        if (wargaResponse != null) {
          final userId = wargaResponse['id'] as String;
          final store = await _storeService.getStoreByUserId(userId);
          
          if (store != null && store.storeId != null) {
            final reviews = await _reviewService.getReviewsByStore(store.storeId!);
            setState(() {
              _reviews = reviews;
              _isLoading = false;
            });
          } else {
            setState(() => _isLoading = false);
          }
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() => _isLoading = false);
    }
  }

  void _replyToReview(Map<String, dynamic> reviewData) {
    final reviewId = reviewData['review_id'] as int;
    final existingReply = reviewData['review_reply'] as String?;
    final controller = TextEditingController(text: existingReply ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Balas Ulasan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Tulis balasan...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final reply = controller.text.trim();
                      if (reply.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Balasan tidak boleh kosong'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      try {
                        await _reviewService.updateReviewReply(reviewId, reply);
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Balasan berhasil dikirim'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          _loadReviews(); // Reload reviews
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal mengirim balasan: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Kirim Balasan",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ulasan Pembeli",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada ulasan",
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReviews,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final review = _reviews[index];
                      final userName = review['user_name'] as String? ?? 'Pembeli';
                      final productName = review['product_name'] as String? ?? 'Produk';
                      final rating = review['rating'] as int? ?? 0;
                      final reviewText = review['review_text'] as String? ?? '';
                      final reviewReply = review['review_reply'] as String?;

                      return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header + Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            productName,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.star,
                          size: 18,
                          color: i < rating
                              ? Colors.amber
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Ulasan pembeli
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    reviewText,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),

                // Seller Reply
                if (reviewReply != null && reviewReply.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.reply, size: 18, color: primaryColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            reviewReply,
                            style: const TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                // Button Reply
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _replyToReview(review),
                    icon: const Icon(Icons.edit_note),
                    label: Text(
                      (reviewReply == null || reviewReply.isEmpty) ? "Balas" : "Edit Balasan",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
                      );
                    },
                  ),
                ),
    );
  }
}
