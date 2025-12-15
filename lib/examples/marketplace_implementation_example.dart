// File contoh implementasi lengkap marketplace
// Simpan di: lib/examples/marketplace_implementation_example.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SapaWarga_kel_2/models/marketplace/product_model.dart';
import 'package:SapaWarga_kel_2/models/marketplace/order_model.dart';
import 'package:SapaWarga_kel_2/models/marketplace/order_item_model.dart';
import 'package:SapaWarga_kel_2/providers/product_provider.dart';
import 'package:SapaWarga_kel_2/providers/marketplace/cart_provider.dart';
import 'package:SapaWarga_kel_2/providers/marketplace/order_provider.dart';

// ============================================
// CONTOH 1: Homepage dengan Produk dari Supabase
// ============================================

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  String? selectedGrade;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.fetchAllProducts();
  }

  Future<void> _filterByGrade(String grade) async {
    setState(() => selectedGrade = grade);
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.filterByGrade(grade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Grade
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildGradeChip('Grade A'),
                const SizedBox(width: 8),
                _buildGradeChip('Grade B'),
                const SizedBox(width: 8),
                _buildGradeChip('Grade C'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() => selectedGrade = null);
                    _loadProducts();
                  },
                  child: const Text('Semua'),
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${provider.errorMessage}'),
                        ElevatedButton(
                          onPressed: _loadProducts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return const Center(child: Text('Belum ada produk'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return _buildProductCard(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeChip(String grade) {
    final isSelected = selectedGrade == grade;
    return FilterChip(
      label: Text(grade),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _filterByGrade(grade);
        }
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[300],
              child: product.gambar != null
                  ? Image.network(
                      product.gambar!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    )
                  : const Icon(Icons.image, size: 50),
            ),
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nama ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${product.harga?.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Stok: ${product.stok ?? 0} ${product.satuan ?? ''}'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getGradeColor(product.grade),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.grade ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Add to Cart Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addToCart(product.productId!),
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String? grade) {
    switch (grade) {
      case 'Grade A':
        return Colors.green;
      case 'Grade B':
        return Colors.orange;
      case 'Grade C':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _addToCart(int productId) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    const userId = 'user123'; // TODO: Get from auth

    final success = await cartProvider.addToCart(userId, productId);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ditambahkan ke keranjang')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cartProvider.errorMessage ?? 'Gagal')),
      );
    }
  }
}

// ============================================
// CONTOH 2: Cart Screen dengan Checkout
// ============================================

class MarketplaceCartScreen extends StatefulWidget {
  const MarketplaceCartScreen({super.key});

  @override
  State<MarketplaceCartScreen> createState() => _MarketplaceCartScreenState();
}

class _MarketplaceCartScreenState extends State<MarketplaceCartScreen> {
  static const String userId = 'user123'; // TODO: Get from auth

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final provider = Provider.of<CartProvider>(context, listen: false);
    await provider.fetchCartWithProducts(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, provider, _) {
              if (provider.cartItems.isEmpty) return const SizedBox();
              
              return TextButton(
                onPressed: () => _clearCart(provider),
                child: const Text('Kosongkan', style: TextStyle(color: Colors.red)),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.cartItems.isEmpty) {
            return const Center(child: Text('Keranjang kosong'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: provider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.cartItems[index];
                    final product = item['produk'];
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: product['gambar'] != null
                              ? Image.network(
                                  product['gambar'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image),
                                )
                              : const Icon(Icons.image),
                        ),
                        title: Text(product['nama'] ?? ''),
                        subtitle: Text(
                          'Rp ${(product['harga'] as num?)?.toStringAsFixed(0) ?? '0'}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFromCart(item['id'], provider),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Rp ${provider.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _checkout(provider),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _removeFromCart(int cartId, CartProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item'),
        content: const Text('Yakin ingin menghapus item ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.removeFromCart(cartId, userId);
    }
  }

  Future<void> _clearCart(CartProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Keranjang'),
        content: const Text('Yakin ingin mengosongkan keranjang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kosongkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.clearCart(userId);
    }
  }

  Future<void> _checkout(CartProvider cartProvider) async {
    // Show checkout dialog atau navigate ke checkout screen
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // Create order
    final order = OrderModel(
      userId: userId,
      totalPrice: cartProvider.totalPrice,
      orderStatus: 'pending',
      alamat: 'Alamat default', // TODO: Get from form
      totalQty: cartProvider.totalItems,
    );

    final createdOrder = await orderProvider.createOrder(order);

    if (createdOrder == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat order')),
      );
      return;
    }

    // Create order items for each cart item
    for (final cartItem in cartProvider.cartItems) {
      final orderItem = OrderItemModel(
        orderId: createdOrder.orderId,
        productId: cartItem['product_id'] as int,
        qty: 1, // TODO: Implement quantity in cart
      );
      
      await orderProvider.createOrderItem(orderItem);
    }

    // Clear cart
    await cartProvider.clearCart(userId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order berhasil dibuat!')),
    );

    // Navigate to order history
    // Navigator.push(...)
  }
}

// ============================================
// CONTOH 3: Product Management (Toko Saya)
// ============================================

class MyStoreProductsScreen extends StatefulWidget {
  final int storeId;

  const MyStoreProductsScreen({super.key, required this.storeId});

  @override
  State<MyStoreProductsScreen> createState() => _MyStoreProductsScreenState();
}

class _MyStoreProductsScreenState extends State<MyStoreProductsScreen> {
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.fetchProductsByStore(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Produk'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProduct,
        child: const Icon(Icons.add),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.products.isEmpty) {
            return const Center(child: Text('Belum ada produk'));
          }

          return ListView.builder(
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(product.nama ?? ''),
                  subtitle: Text(
                    'Rp ${product.harga} • Stok: ${product.stok}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editProduct(product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product.productId!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addNewProduct() async {
    // Show form dialog atau navigate ke form screen
    final newProduct = ProductModel(
      nama: 'Produk Baru',
      deskripsi: 'Deskripsi produk',
      harga: 10000,
      stok: 50,
      grade: 'Grade A',
      satuan: 'kg',
      storeId: widget.storeId,
    );

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final result = await provider.createProduct(newProduct);

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan produk')),
      );
    }
  }

  Future<void> _editProduct(ProductModel product) async {
    // Show edit form
  }

  Future<void> _deleteProduct(int productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final success = await provider.deleteProduct(productId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus produk')),
        );
      }
    }
  }
}
