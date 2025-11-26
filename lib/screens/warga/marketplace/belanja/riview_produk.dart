import 'package:flutter/material.dart';

class ProductReviewScreen extends StatelessWidget {
  final String productId;
  const ProductReviewScreen({super.key, required this.productId});

  static const Color _primaryColor = Color(0xFF6366F1);
  static const Color _iconColor = Color(0xFF8B5CF6);
  static const Color _ratingColor = Colors.amber;

  final List<Map<String, dynamic>> _dummyReviews = const [
    {
      'name': 'Lala S.',
      'comment': 'Tomatnya Grade A banget! Segar dan mulus. Cocok buat salad. Pengiriman cepat, puas!',
      'rating': 5.0,
      'date': '2025-11-20',
    },
    {
      'name': 'Budi J.',
      'comment': 'Wortel agak layu ini cocok untuk jus, harganya bersahabat. Seller responsif saat ditanya stok.',
      'rating': 4.0,
      'date': '2025-11-18',
    },
    {
      'name': 'Santi P.',
      'comment': 'wortelnya agak kecil-kecil, tapi jumlahnya pas. Lumayan untuk harga segini.',
      'rating': 3.5,
      'date': '2025-11-15',
    },
    {
      'name': 'Rahmat H.',
      'comment': 'Sayur  segar, tidak ada yang busuk. Terima kasih, toko sayur RT 01!',
      'rating': 5.0,
      'date': '2025-11-10',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Semua Ulasan Produk',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRatingSummary(),

            // Daftar Ulasan Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Text(
                'Total ${_dummyReviews.length} Ulasan',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),

            // Daftar Ulasan
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dummyReviews.length,
              itemBuilder: (context, index) {
                final review = _dummyReviews[index];
                return _buildSingleReviewTile(
                  review['name'],
                  review['comment'],
                  review['rating'],
                  review['date'],
                );
              },
            ),
            const SizedBox(height: 80), 
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showReviewForm(context);
        },
        icon: const Icon(Icons.rate_review),
        label: const Text('Tulis Ulasan'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
        elevation: 5,
      ),
    );
  }

  void _showReviewForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const WriteReviewForm(),
        );
      },
    );
  }

  // --- WIDGET RINGKASAN RATING ---
  Widget _buildRatingSummary() {
    double averageRating = _dummyReviews.fold(0.0, (sum, item) => sum + item['rating']) / _dummyReviews.length;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rating Besar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < averageRating.floor()
                        ? Icons.star
                        : (index < averageRating && averageRating % 1 != 0)
                            ? Icons.star_half
                            : Icons.star_border,
                    color: _ratingColor,
                    size: 24,
                  );
                }),
              ),
              const SizedBox(height: 5),
              Text(
                'Total ${_dummyReviews.length} Ratings',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 30),
          
          // Detail Distribusi Rating (Dummy)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingBar(5, 50, _iconColor),
                _buildRatingBar(4, 35, _iconColor.withOpacity(0.8)),
                _buildRatingBar(3, 10, _iconColor.withOpacity(0.6)),
                _buildRatingBar(2, 5, _iconColor.withOpacity(0.4)),
                _buildRatingBar(1, 0, _iconColor.withOpacity(0.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Pembantu untuk Rating Bar
  Widget _buildRatingBar(int star, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(Icons.star, size: 14, color: Colors.grey.shade500),
          Text('$star', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text('$percentage%', style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937))),
        ],
      ),
    );
  }

  Widget _buildSingleReviewTile(
      String name, String comment, double star, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _iconColor.withOpacity(0.15), // Transparan ungu
                child: Icon(Icons.person, color: _iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    '${date.toString()} - Pembelian Terverifikasi',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _ratingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _ratingColor.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 14, color: _ratingColor),
                    Text(
                      star.toStringAsFixed(1),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _ratingColor),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF1F2937)),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}


class WriteReviewForm extends StatefulWidget {
  const WriteReviewForm({super.key});

  @override
  State<WriteReviewForm> createState() => _WriteReviewFormState();
}

class _WriteReviewFormState extends State<WriteReviewForm> {
  double _currentRating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  static const Color _primaryColor = Color(0xFF6366F1);
  static const Color _ratingColor = Colors.amber;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0), 
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tulis Ulasan Anda',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 20),

          // Pemilihan Rating Bintang
          const Text('Beri Penilaian:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _currentRating ? Icons.star : Icons.star_border,
                    color: _ratingColor,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentRating = index + 1;
                    });
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Input Komentar
          const Text('Komentar Anda (Min 10 karakter):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Riview produk ini...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryColor, width: 2),
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Kirim 
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_currentRating == 0.0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berikan rating.')),
                  );
                } else if (_commentController.text.length < 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Komentar minimal 10 karakter.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ulasan berhasil dikirim! Rating: $_currentRating'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context); 
                }
              },
              icon: const Icon(Icons.send, size: 20),
              label: const Text('Kirim Ulasan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), 
                ),
                elevation: 5,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}