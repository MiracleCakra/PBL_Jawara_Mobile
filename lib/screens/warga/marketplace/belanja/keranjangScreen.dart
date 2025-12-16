import 'package:SapaWarga_kel_2/models/marketplace/product_model.dart';
import 'package:SapaWarga_kel_2/providers/marketplace/cart_provider.dart';
import 'package:SapaWarga_kel_2/utils.dart' show formatRupiah;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  int? cartId; // Store cart_id for deletion

  CartItem({required this.product, this.quantity = 1, this.cartId});

  int get subtotal => (product.harga?.toInt() ?? 0) * quantity;
}

// Dummy data - nanti akan diganti dengan data dari CartProvider
List<CartItem> initialCartItems = [];

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  static const Color _primaryColor = Color(0xFF6366F1);
  static const Color _greenFresh = Color(0xFF4ADE80);
  static const int _shippingFee = 5000;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(initialCartItems);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCart();
    });
  }

  Future<void> _loadCart() async {
    try {
      // Get warga.id (NIK) from warga table using email
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser?.email == null) {
        if (mounted) {
          setState(() {
            _cartItems = [];
          });
        }
        return;
      }

      // Query warga table to get warga.id (NIK)
      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', authUser!.email!)
          .maybeSingle();

      if (wargaResponse != null) {
        final userId = wargaResponse['id'] as String;
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        await cartProvider.fetchCartWithProducts(userId);

        // Convert cart items from provider to CartItem format
        if (mounted) {
          setState(() {
            _cartItems = cartProvider.cartItems
                .map((item) {
                  final product = ProductModel.fromJson(item['produk']);
                  final quantity = item['qty'] as int? ?? 1;
                  final cartItem = CartItem(
                    product: product,
                    quantity: quantity,
                  );
                  cartItem.cartId = item['id'] as int;
                  return cartItem;
                })
                .where(
                  (item) => (item.product.stok ?? 0) > 0,
                ) // Filter produk dengan stok > 0
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error loading cart: $e');
      if (mounted) {
        setState(() {
          _cartItems = [];
        });
      }
    }
  }

  Future<void> _updateQuantity(CartItem item, int delta) async {
    final newQuantity = item.quantity + delta;

    if (newQuantity <= 0) {
      // If quantity becomes 0, remove item
      await _removeItem(item);
      return;
    }

    // Check if new quantity exceeds available stock
    final availableStock = item.product.stok ?? 0;
    if (newQuantity > availableStock) {
      if (mounted) {
        showDialog(
          context: context,
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
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Stok Maksimal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Hanya tersedia $availableStock ${item.product.satuan ?? "pcs"}',
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
                          backgroundColor: Colors.orange,
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
      return;
    }

    if (item.cartId == null) return;

    try {
      // Update quantity in database
      await Supabase.instance.client
          .from('cart')
          .update({'qty': newQuantity})
          .eq('id', item.cartId!);

      // Update local state
      setState(() {
        item.quantity = newQuantity;
      });
    } catch (e) {
      print('Error updating quantity: $e');
      if (mounted) {
        _showErrorDialog('Gagal mengubah jumlah: $e');
      }
    }
  }

  Future<void> _removeItem(CartItem item) async {
    if (item.cartId == null) {
      _showErrorDialog('Gagal menghapus item');
      return;
    }

    try {
      // Get warga.id (NIK) from warga table using email
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser?.email == null) return;

      // Query warga table to get warga.id (NIK)
      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', authUser!.email!)
          .maybeSingle();

      if (wargaResponse != null) {
        final userId = wargaResponse['id'] as String;
        final cartProvider = Provider.of<CartProvider>(context, listen: false);

        // Delete from database
        await cartProvider.removeFromCart(item.cartId!, userId);

        // Refresh cart from database
        await _loadCart();

        if (mounted) {
          _showSuccessDialog(
            'Dihapus dari Keranjang',
            '${item.product.nama} telah dihapus dari keranjang',
          );
        }
      }
    } catch (e) {
      print('Error removing item: $e');
      if (mounted) {
        _showErrorDialog('Gagal menghapus: $e');
      }
    }
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

  int get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get _totalAmount => _subtotal + _shippingFee;

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    item.product.gambar != null &&
                        item.product.gambar!.isNotEmpty
                    ? Image.network(
                        item.product.gambar!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: _primaryColor,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.nama ?? 'Produk',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Detail Grade
                    Text(
                      'Grade: ${item.product.grade ?? "Grade A"}',
                      style: TextStyle(
                        fontSize: 13,
                        color: item.product.grade == 'Grade A'
                            ? _greenFresh
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Harga Satuan
                    Text(
                      formatRupiah(item.product.harga?.toInt() ?? 0),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol Hapus
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _removeItem(item),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kontrol Kuantitas
              Row(
                children: [
                  _buildQuantityButton(
                    Icons.remove,
                    () => _updateQuantity(item, -1),
                    false,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    Icons.add,
                    () => _updateQuantity(item, 1),
                    false,
                  ),
                ],
              ),
              // Subtotal Item
              Text(
                formatRupiah(item.subtotal),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
    IconData icon,
    VoidCallback onTap,
    bool isDisabled,
  ) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey.shade300
              : _primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDisabled ? Colors.grey.shade500 : _primaryColor,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow('Subtotal Barang', formatRupiah(_subtotal), false),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Biaya Pengiriman',
            formatRupiah(_shippingFee),
            false,
          ),
          const Divider(height: 25),
          _buildSummaryRow(
            'Total Pembayaran',
            formatRupiah(_totalAmount),
            true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _cartItems.isEmpty
                  ? null
                  : () {
                      context.push('/warga/marketplace/checkout');
                    },
              icon: const Icon(Icons.shopping_bag_outlined, size: 24),
              label: const Text(
                'Lanjutkan Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? _primaryColor : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isTotal ? _primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Keranjang Anda Kosong.',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.go('/warga/marketplace/explore'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                    ),
                    child: const Text(
                      'Mulai Belanja',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                ..._cartItems.map((item) => _buildCartItemCard(item)).toList(),
              ],
            ),

      bottomSheet: _cartItems.isEmpty ? null : _buildSummaryCard(),
    );
  }
}
