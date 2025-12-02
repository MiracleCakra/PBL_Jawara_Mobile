import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:jawara_pintar_kel_5/providers/product_provider.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/store_service.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;
import 'package:jawara_pintar_kel_5/widget/product_image.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyStoreStockScreen extends StatefulWidget {
  const MyStoreStockScreen({super.key});

  @override
  State<MyStoreStockScreen> createState() => _MyStoreStockScreenState();
}

class _MyStoreStockScreenState extends State<MyStoreStockScreen> {
  late List<ProductModel> products;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    products = [];
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Get user's store_id
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser?.email == null) {
        throw Exception('User tidak terautentikasi');
      }

      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', authUser!.email!)
          .maybeSingle();

      if (wargaResponse == null) {
        throw Exception('Data warga tidak ditemukan');
      }

      final userId = wargaResponse['id'] as String;
      final storeService = StoreService();
      final store = await storeService.getStoreByUserId(userId);

      if (store == null || store.storeId == null) {
        throw Exception('Toko tidak ditemukan');
      }

      // Load only products from this store
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      await productProvider.fetchProductsByStore(store.storeId!);

      if (mounted) {
        setState(() {
          products = productProvider.products;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Gagal memuat produk: $e';
          isLoading = false;
        });
      }
    }
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
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat produk...'),
                ],
              ),
            )
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProducts,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : products.isEmpty
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

    // Status produk (simplified - will use backend status)
    String statusText = 'Active';
    Color statusColor = Colors.green;

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
              content: Text('${product.nama ?? 'Produk'} berhasil dihapus'),
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
                child: ProductImage(
                  imagePath: product.gambar,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nama ?? 'Produk',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Harga: ${formatRupiah(product.harga?.toInt() ?? 0)}',
                      style: const TextStyle(fontSize: 13, color: Colors.green),
                    ),
                    Text(
                      'Stok: ${product.stok ?? 0} ${product.satuan ?? 'unit'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Row(
                      children: [
                        Text(
                          'Grade: ${product.grade?.replaceAll('Grade ', '') ?? 'A'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: gradeColor,
                          ),
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
                    // rejectionReason check removed
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Status: Active',
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
