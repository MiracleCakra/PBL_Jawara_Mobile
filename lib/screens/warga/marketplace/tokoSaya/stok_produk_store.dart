import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;

class MyStoreStockScreen extends StatefulWidget {
  const MyStoreStockScreen({super.key});

  @override
  State<MyStoreStockScreen> createState() => _MyStoreStockScreenState();
}

class _MyStoreStockScreenState extends State<MyStoreStockScreen> {
  late List<ProductModel> products;

  @override
  void initState() {
    super.initState();
    products = ProductModel.getSampleProducts();
  }

  void _navigateToProductAdd() async {
    await context.pushNamed('MyStoreProductAdd');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stok Produk Toko',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: products.isEmpty
      ? _buildEmptyStock()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, product);
              },
            ),
        floatingActionButton: FloatingActionButton(
        onPressed: _navigateToProductAdd,
        backgroundColor: Colors.deepPurple,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyStock() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 50,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              'Belum ada produk terdaftar.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    Color gradeColor = switch (product.grade) {
      'Grade A' => const Color(0xFF6A5AE0),
      'Grade B' => Colors.orange,
      'Grade C' => Colors.pink,
      _ => Colors.grey,
    };

    // Status produk
    String statusText;
    Color statusColor;
    if (product.isVerified) {
      statusText = 'Terverifikasi';
      statusColor = Colors.green;
    } else if (!product.isVerified && product.rejectionReason == null) {
      statusText = 'Pending';
      statusColor = Colors.orange;
    } else {
      statusText = 'Ditolak';
      statusColor = Colors.red;
    }

    return GestureDetector(
      onTap: () async {
        final result = await context.pushNamed(
          'MyStoreProductDetail',
          extra: product,
        );

        if (result == 'deleted') {
          setState(() {
            products.remove(product);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} berhasil dihapus'),
              backgroundColor: Colors.grey.shade800,
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  product.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: gradeColor.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: gradeColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Harga: ${formatRupiah(product.price)}',
                      style: const TextStyle(fontSize: 13, color: Colors.green),
                    ),
                    Text(
                      'Stok: ${product.stock} ${product.unit}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Row(
                      children: [
                        Text(
                          'Grade: ${product.grade.replaceAll('Grade ', '')}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: gradeColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        Text(
                          "${product.rating}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (product.rejectionReason != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Alasan ditolak: ${product.rejectionReason}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
