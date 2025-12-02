import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:jawara_pintar_kel_5/providers/product_provider.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/product_service.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;
import 'package:jawara_pintar_kel_5/widget/product_image.dart';
import 'package:provider/provider.dart';

class MyStoreProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const MyStoreProductDetailScreen({super.key, required this.product});

  @override
  State<MyStoreProductDetailScreen> createState() =>
      _MyStoreProductDetailScreenState();
}

class _MyStoreProductDetailScreenState
    extends State<MyStoreProductDetailScreen> {
  static const Color primaryColor = Color(0xFF6A5AE0);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color rejectedColor = Colors.red;
  static const Color verifiedColor = Colors.green;

  late ProductModel currentProduct;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product;
  }

  (String, Color, IconData) _getVerificationStatus() {
    // Simplified status - will use backend verification status
    return ('Active', verifiedColor, Icons.check_circle_outline);
  }

  Future<void> _navigateToEditForm(BuildContext context) async {
    final result = await context.pushNamed(
      'MyStoreProductEdit',
      extra: currentProduct,
    );

    if (result is ProductModel) {
      setState(() {
        currentProduct = result;
      });
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hapus Produk?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus produk "${currentProduct.nama ?? 'produk ini'}"? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: rejectedColor),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Delete from database
        final productService = ProductService();
        await productService.deleteProduct(currentProduct.productId!);

        // Refresh provider
        if (mounted) {
          final productProvider = Provider.of<ProductProvider>(
            context,
            listen: false,
          );
          await productProvider.fetchAllProducts();
        }

        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${currentProduct.nama ?? 'Produk'} berhasil dihapus dari database',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, 'deleted');
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus produk: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showActionBottomSheet(BuildContext context) {
    final bool isRejected = false; // Simplified - rejection removed

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Aksi Produk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 1),

            // Hanya tampilkan tombol edit jika produk tidak ditolak
            if (!isRejected)
              ListTile(
                leading: const Icon(Icons.edit, color: primaryColor),
                title: const Text('Edit Produk'),
                onTap: () {
                  Navigator.pop(ctx);
                  _navigateToEditForm(context);
                },
              ),

            ListTile(
              leading: const Icon(Icons.delete_forever, color: rejectedColor),
              title: Text(
                'Hapus Produk',
                style: TextStyle(color: rejectedColor),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final (statusText, statusColor, statusIcon) = _getVerificationStatus();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentProduct.nama ?? 'Detail Produk',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showActionBottomSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(
              imagePath: currentProduct.gambar,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: statusColor.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor),
                  const SizedBox(width: 10),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentProduct.deskripsi ?? 'Tidak ada deskripsi',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatRupiah(currentProduct.harga?.toInt() ?? 0),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: verifiedColor,
                            ),
                          ),
                          Text(
                            'Per ${currentProduct.satuan ?? 'unit'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      _buildDetailBadge(
                        Icons.star,
                        currentProduct.grade ?? 'Grade A',
                        primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildDetailRow(
                    Icons.storage,
                    'Stok Tersedia',
                    '${currentProduct.stok ?? 0} ${currentProduct.satuan ?? 'unit'}',
                  ),
                  _buildDetailRow(
                    Icons.date_range,
                    'Tanggal Posting',
                    '01 Des 2025',
                  ),

                  // rejectionReason removed
                  ...[
                    const SizedBox(height: 16),
                    Container(), // Placeholder
                  ],

                  const SizedBox(height: 30),

                  const Text(
                    'Performa Produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildPerformanceStat('Total Penjualan (Bulan Ini)', '5x'),
                  _buildPerformanceStat('Rata-rata Rating', '0.0 / 5.0'),
                  _buildPerformanceStat(
                    'Total Pendapatan (Produk Ini)',
                    formatRupiah((currentProduct.harga?.toInt() ?? 0) * 5),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBadge(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRejectionCard(String reason) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rejectedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rejectedColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alasan Penolakan Admin:',
            style: TextStyle(fontWeight: FontWeight.bold, color: rejectedColor),
          ),
          const SizedBox(height: 5),
          Text(reason, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
