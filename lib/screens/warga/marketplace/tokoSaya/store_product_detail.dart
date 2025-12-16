import 'package:SapaWarga_kel_2/models/marketplace/product_model.dart';
import 'package:SapaWarga_kel_2/providers/product_provider.dart';
import 'package:SapaWarga_kel_2/services/marketplace/product_service.dart';
import 'package:SapaWarga_kel_2/utils.dart' show formatRupiah;
import 'package:SapaWarga_kel_2/widget/marketplace/custom_dialog.dart';
import 'package:SapaWarga_kel_2/widget/product_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    if (result == 'updated') {
      // Reload product from database to get fresh data
      try {
        final productService = ProductService();
        final updatedProduct = await productService.getProductById(
          currentProduct.productId!,
        );

        if (updatedProduct != null && mounted) {
          setState(() {
            currentProduct = updatedProduct;
          });

          // Return 'updated' to parent screen so it can refresh too
          if (context.mounted) {
            context.pop('updated');
          }
        }
      } catch (e) {
        print('Error reloading product: $e');
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirm = await CustomConfirmDialog.show(
      context: context,
      type: DialogType.error,
      title: 'Hapus Produk?',
      message:
          'Apakah kamu yakin ingin menghapus produk "${currentProduct.nama ?? "tes notif"}"? Tindakan ini tidak dapat dibatalkan.',
      cancelText: 'Batal',
      confirmText: 'Hapus',
    );

    if (confirm == true && mounted) {
      try {
        // Delete from database
        final productService = ProductService();
        await productService.deleteProduct(currentProduct.productId!);

        // Refresh provider in background
        if (mounted) {
          final productProvider = Provider.of<ProductProvider>(
            context,
            listen: false,
          );
          productProvider.fetchAllProducts();
        }

        if (mounted) {
          CustomSnackbar.show(
            context: context,
            message: '${currentProduct.nama ?? "Produk"} berhasil dihapus',
            type: DialogType.success,
          );
          Navigator.pop(context, 'deleted');
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.show(
            context: context,
            message: e.toString().contains('Produk memiliki riwayat pesanan')
                ? 'Produk memiliki pesanan, stok diatur ke 0'
                : 'Gagal menghapus produk: $e',
            type: e.toString().contains('Produk memiliki riwayat pesanan')
                ? DialogType.warning
                : DialogType.error,
            duration: const Duration(seconds: 3),
          );
          if (e.toString().contains('Produk memiliki riwayat pesanan')) {
            Navigator.pop(context, 'updated');
          }
        }
      }
    }
  }

  void _showActionBottomSheet(BuildContext context) {
    final bool isRejected = false; // Simplified - rejection removed

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  'Aksi Produk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Hanya tampilkan tombol edit jika produk tidak ditolak
              if (!isRejected)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    title: const Text(
                      'Edit Produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _navigateToEditForm(context);
                    },
                  ),
                ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: rejectedColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: rejectedColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: rejectedColor,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Hapus Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: rejectedColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDelete(context);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
