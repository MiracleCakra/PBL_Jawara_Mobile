import 'package:SapaWarga_kel_2/models/marketplace/product_model.dart';
import 'package:SapaWarga_kel_2/providers/marketplace/cart_provider.dart';
import 'package:SapaWarga_kel_2/services/marketplace/review_service.dart';
import 'package:SapaWarga_kel_2/utils.dart' show formatRupiah;
import 'package:SapaWarga_kel_2/widget/product_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WargaProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const WargaProductDetailScreen({super.key, required this.product});

  @override
  State<WargaProductDetailScreen> createState() =>
      _WargaProductDetailScreenState();
}

class _WargaProductDetailScreenState extends State<WargaProductDetailScreen> {
  static const Color _primaryColor = Color(0xFF6A5AE0);
  static const Color _greenFresh = Color(0xFF4ADE80);

  final _reviewService = ReviewService();
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;
  double _averageRating = 0.0;

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

      // Calculate average rating
      double totalRating = 0;
      for (var review in reviews) {
        totalRating += (review['rating'] as int? ?? 0);
      }

      setState(() {
        _reviews = reviews;
        _averageRating = reviews.isEmpty ? 0 : totalRating / reviews.length;
        _isLoadingReviews = false;
      });
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() => _isLoadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildContent(context),
          _buildBottomAction(context),
          _buildAppBar(context),
        ],
      ),
    );
  }

  ProductModel get product => widget.product;

  Widget _buildAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black54.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          expandedHeight: 380,
          backgroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'product-${product.productId}',
              child: ProductImage(
                imagePath: product.gambar,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama & Harga
                  Text(
                    product.nama ?? 'Produk',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatRupiah(product.harga?.toInt() ?? 0),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: _primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stok: ${product.stok ?? 0} ${product.satuan ?? "pcs"}',
                            style: TextStyle(
                              fontSize: 14,
                              color: (product.stok ?? 0) > 0
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Label Grade Produk
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (product.grade ?? 'Grade A') == 'Grade A'
                              ? _greenFresh
                              : (product.grade ?? 'Grade B') == 'Grade B'
                              ? Colors.amber
                              : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.grade ?? 'Grade A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // Detail Penjual
                  _buildSellerInfo(context),
                  const Divider(height: 30),

                  // Deskripsi Produk
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.deskripsi ?? 'Tidak ada deskripsi',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 25),

                  _buildRatingAndReviewSection(context),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildSellerInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Penjual',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: _primaryColor.withOpacity(0.15),
            child: Icon(Icons.storefront, color: _primaryColor),
          ),
          title: const Text(
            'Toko Sayur Agus',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: const Text(
            'Agus RT 01/RW 01 - Terakhir aktif 5 menit lalu',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          trailing: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka Chat dengan Penjual...')),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Chat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryColor,
              side: BorderSide(color: _primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingAndReviewSection(BuildContext context) {
    if (_isLoadingReviews) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.pushNamed('AllReviews', extra: widget.product);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 17),
                      const SizedBox(width: 8),
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          '(${_reviews.length} ulasan)',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_reviews.isNotEmpty)
                TextButton(
                  onPressed: () {
                    context.pushNamed('AllReviews', extra: widget.product);
                  },
                  child: const Text(
                    'Lihat Semua >',
                    style: TextStyle(
                      color: Color(0xFF6A5AE0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const Divider(height: 20),

          if (_reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Belum ada ulasan',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else ...[
            const Text(
              'Ulasan Terbaru:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Show first 2 reviews only
            for (
              int i = 0;
              i < (_reviews.length > 2 ? 2 : _reviews.length);
              i++
            )
              _buildSingleReview(
                _reviews[i]['user_name'] as String? ?? 'Pembeli',
                _reviews[i]['review_text'] as String? ?? '',
                (_reviews[i]['rating'] as int? ?? 0).toDouble(),
                _reviews[i]['review_reply'] as String?,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSingleReview(
    String name,
    String comment,
    double star,
    String? reply,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin, size: 20, color: _primaryColor),
              const SizedBox(width: 5),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 14,
                    color: i < star ? Colors.amber : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),

          // Seller Reply
          if (reply != null && reply.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.store, size: 16, color: _primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Balasan Penjual:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reply,
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final cartProvider = Provider.of<CartProvider>(
                    context,
                    listen: false,
                  );
                  // Get warga.id (NIK) from warga table using email
                  final authUser = Supabase.instance.client.auth.currentUser;
                  if (authUser?.email == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Silakan login terlebih dahulu'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Query warga table to get warga.id (NIK)
                  final wargaResponse = await Supabase.instance.client
                      .from('warga')
                      .select('id')
                      .eq('email', authUser!.email!)
                      .maybeSingle();

                  if (wargaResponse == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data warga tidak ditemukan'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final userId = wargaResponse['id'] as String;

                  if (product.productId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Produk tidak valid'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final success = await cartProvider.addToCart(
                    userId,
                    product.productId!,
                  );

                  if (success) {
                    if (mounted) {
                      _showSuccessDialog(
                        'Ditambahkan ke Keranjang',
                        '${product.nama} telah ditambahkan ke keranjang',
                      );
                    }
                  } else {
                    if (mounted) {
                      _showErrorDialog(
                        'Gagal menambahkan ke keranjang: ${cartProvider.errorMessage}',
                      );
                    }
                  }
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Keranjang'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryColor,
                  side: BorderSide(color: _primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Beli Sekarang - langsung ke checkout tanpa masuk keranjang
                    try {
                      final authUser =
                          Supabase.instance.client.auth.currentUser;
                      if (authUser?.email == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silakan login terlebih dahulu'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      print('DEBUG BuyNow: User email = ${authUser!.email}');

                      // Query warga table to get warga.id (NIK)
                      final wargaResponse = await Supabase.instance.client
                          .from('warga')
                          .select('id')
                          .eq('email', authUser.email!)
                          .maybeSingle();

                      if (wargaResponse == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data warga tidak ditemukan'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final userId = wargaResponse['id'] as String;
                      print('DEBUG BuyNow: User ID = $userId');
                      print(
                        'DEBUG BuyNow: Product = ${product.nama}, ID = ${product.productId}',
                      );

                      // Pass product to checkout with buy_now flag
                      final checkoutData = {
                        'type': 'buy_now',
                        'product': product,
                        'userId': userId,
                      };

                      print(
                        'DEBUG BuyNow: Navigating to checkout with data: $checkoutData',
                      );

                      context.push(
                        '/warga/marketplace/checkout',
                        extra: checkoutData,
                      );
                    } catch (e) {
                      print('DEBUG BuyNow: Error = $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Terjadi kesalahan: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Beli Sekarang (CO)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: _primaryColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: _primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Gagal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
}
