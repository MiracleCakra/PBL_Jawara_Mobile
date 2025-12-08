import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/order_item_model.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/order_model.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:jawara_pintar_kel_5/providers/marketplace/cart_provider.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/keranjangScreen.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/order_service.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color _primaryColor = Color(0xFF6366F1);
  static const Color _iconColor = Color(0xFF8B5CF6);
  static const Color _greenFresh = Colors.orange;

  String _selectedPaymentMethod = 'COD';
  String _selectedDeliveryOption = 'Ambil di Toko Warga';

  List<CartItem> _checkoutItems = [];
  ProductModel? _buyNowProduct;
  String? _userId;
  bool _isLoading = true;
  String _checkoutType = 'cart'; // 'cart' or 'buy_now'

  static const int _shippingFee = 5000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCheckoutData();
    });
  }

  Future<void> _loadCheckoutData() async {
    final extra = GoRouterState.of(context).extra;

    print('DEBUG Checkout: extra data = $extra');

    if (extra is Map<String, dynamic> && extra['type'] == 'buy_now') {
      // Buy Now flow
      print('DEBUG Checkout: Buy Now mode detected');
      setState(() {
        _checkoutType = 'buy_now';
        _buyNowProduct = extra['product'] as ProductModel;
        _userId = extra['userId'] as String;
        _isLoading = false;
      });
      print('DEBUG Checkout: Buy Now product loaded: ${_buyNowProduct?.nama}');
    } else {
      // Cart flow - load cart items
      print('DEBUG Checkout: Cart mode detected');
      setState(() {
        _checkoutType = 'cart';
      });

      try {
        final authUser = Supabase.instance.client.auth.currentUser;
        if (authUser?.email == null) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }

        // Get warga.id
        final wargaResponse = await Supabase.instance.client
            .from('warga')
            .select('id')
            .eq('email', authUser!.email!)
            .maybeSingle();

        if (wargaResponse == null) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }

        final userId = wargaResponse['id'] as String;

        // Load cart from provider
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        await cartProvider.fetchCartWithProducts(userId);

        print(
          'DEBUG Checkout: Cart items count = ${cartProvider.cartItems.length}',
        );

        if (mounted) {
          setState(() {
            _userId = userId;
            _checkoutItems = cartProvider.cartItems.map((cartItem) {
              print(
                'DEBUG Checkout: Processing cart item: ${cartItem['produk']['nama']}',
              );
              final product = ProductModel.fromJson(cartItem['produk']);
              final quantity =
                  cartItem['qty'] as int? ??
                  1; // Get actual quantity from database
              print('DEBUG Checkout: Quantity = $quantity');
              return CartItem(product: product, quantity: quantity);
            }).toList();
            _isLoading = false;
          });
          print(
            'DEBUG Checkout: Final checkout items count = ${_checkoutItems.length}',
          );
        }
      } catch (e) {
        print('Error loading cart: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  int get _subtotal {
    if (_checkoutType == 'buy_now' && _buyNowProduct != null) {
      return _buyNowProduct!.harga?.toInt() ?? 0;
    }
    return _checkoutItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get _totalQuantity {
    if (_checkoutType == 'buy_now') {
      return 1;
    }
    return _checkoutItems.fold(0, (sum, item) => sum + item.quantity);
  }

  int get _finalTotal {
    final currentShipping = _selectedDeliveryOption == 'Ambil di Toko Warga'
        ? 0
        : _shippingFee;
    return _subtotal + currentShipping;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout Pembayaran'),
          backgroundColor: Colors.white,
          elevation: 0.5,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_checkoutType == 'cart' && _checkoutItems.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Keranjang kosong. Tidak bisa Checkout.')),
      );
    }

    if (_checkoutType == 'buy_now' && _buyNowProduct == null) {
      return const Scaffold(
        body: Center(child: Text('Produk tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Checkout Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: '📍 Ambil/Kirim',
              icon: Icons.location_on_outlined,
              children: [
                _buildDeliveryOption(
                  label: 'Ambil di Toko Warga',
                  cost: 'Gratis',
                  value: 'Ambil di Toko Warga',
                ),
                _buildDeliveryOption(
                  label: 'Diantar ke Rumah Warga',
                  cost: formatRupiah(_shippingFee),
                  value: 'Diantar ke Rumah Warga',
                ),
                const Divider(),
                const Text(
                  'Alamat Warga: Jl. Mawar No. 12, RT 01 / RW 01',
                  style: TextStyle(fontSize: 14),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fungsi Ubah Alamat belum diimplementasikan.',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Ubah Alamat',
                    style: TextStyle(color: _iconColor),
                  ),
                ),
              ],
            ),

            _buildSectionCard(
              title: 'Rincian Pesanan',
              icon: Icons.receipt_long,
              children: _checkoutType == 'buy_now'
                  ? [_buildBuyNowOrderItem()]
                  : _checkoutItems
                        .map((item) => _buildOrderSummaryItem(item))
                        .toList(),
            ),

            _buildSectionCard(
              title: 'Metode Pembayaran',
              icon: Icons.payment,
              children: [
                _buildPaymentMethod(
                  label: 'Tunai (COD / Bayar di Tempat)',
                  value: 'COD',
                  icon: Icons.money,
                ),
              ],
            ),
          ],
        ),
      ),

      bottomSheet: _buildBottomSummary(),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primaryColor, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDeliveryOption({
    required String label,
    required String cost,
    required String value,
  }) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        cost,
        style: TextStyle(
          color: cost == 'Gratis' ? _greenFresh : Colors.black87,
        ),
      ),
      value: value,
      groupValue: _selectedDeliveryOption,
      onChanged: (String? val) {
        setState(() {
          _selectedDeliveryOption = val!;
        });
      },
      activeColor: _primaryColor,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildBuyNowOrderItem() {
    if (_buyNowProduct == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              _buyNowProduct!.gambar ?? 'assets/images/placeholder.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_buyNowProduct!.nama} (${_buyNowProduct!.grade ?? "Grade A"})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '1 x ${formatRupiah(_buyNowProduct!.harga?.toInt() ?? 0)}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  'Stok tersedia: ${_buyNowProduct!.stok ?? 0} ${_buyNowProduct!.satuan ?? "pcs"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: (_buyNowProduct!.stok ?? 0) > 0
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatRupiah(_buyNowProduct!.harga?.toInt() ?? 0),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.product.gambar ?? 'assets/images/placeholder.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade300,
                  child: Center(
                    child: Icon(
                      Icons.error_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.product.nama} (${item.product.grade})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.quantity} x ${formatRupiah(item.product.harga?.toInt() ?? 0)}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  'Stok tersedia: ${item.product.stok ?? 0} ${item.product.satuan ?? "pcs"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: (item.product.stok ?? 0) > 0
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatRupiah(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      secondary: Icon(icon, color: _iconColor),
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (String? val) {
        setState(() {
          _selectedPaymentMethod = val!;
        });
      },
      activeColor: _primaryColor,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildBottomSummary() {
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
            _selectedDeliveryOption == 'Ambil di Toko Warga'
                ? 'Gratis'
                : formatRupiah(_shippingFee),
            false,
          ),
          const Divider(height: 25),
          _buildSummaryRow('TOTAL BAYAR', formatRupiah(_finalTotal), true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                // Logika Final: Order Placement API call
                _processOrder(context);
              },
              icon: const Icon(Icons.lock_open, size: 24),
              label: Text(
                'Beli ${formatRupiah(_finalTotal)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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

  // Baris Ringkasan Pembayaran
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

  Future<void> _processOrder(BuildContext context) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak terautentikasi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final orderService = OrderService();

      // Create order
      final newOrder = OrderModel(
        userId: _userId,
        totalPrice: _finalTotal.toDouble(),
        orderStatus:
            null, // Status NULL = pesanan baru, menunggu konfirmasi penjual
        alamat:
            'Jl. Mawar No. 12, RT 01 / RW 01', // TODO: get from user profile
        totalQty: _totalQuantity,
        createdAt: DateTime.now(),
      );

      final createdOrder = await orderService.createOrder(newOrder);

      // Create order items and reduce stock
      if (_checkoutType == 'buy_now' && _buyNowProduct != null) {
        await orderService.createOrderItem(
          OrderItemModel(
            orderId: createdOrder.orderId,
            productId: _buyNowProduct!.productId,
            qty: 1,
          ),
        );

        // Reduce stock for buy now product
        await orderService.reduceProductStock(_buyNowProduct!.productId!, 1);
      } else {
        for (var item in _checkoutItems) {
          await orderService.createOrderItem(
            OrderItemModel(
              orderId: createdOrder.orderId,
              productId: item.product.productId,
              qty: item.quantity,
            ),
          );

          // Reduce stock for each cart item
          await orderService.reduceProductStock(
            item.product.productId!,
            item.quantity,
          );
        }

        // Clear cart after successful order
        if (_checkoutType == 'cart') {
          final cartProvider = Provider.of<CartProvider>(
            context,
            listen: false,
          );
          await cartProvider.clearCart(_userId!);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pesanan berhasil dibuat! Order ID: ${createdOrder.orderId}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/warga/marketplace');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
