import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/models/marketplace/order_item_model.dart';
import 'package:SapaWarga_kel_2/models/marketplace/order_model.dart';
import 'package:SapaWarga_kel_2/models/marketplace/product_model.dart';
import 'package:SapaWarga_kel_2/providers/marketplace/cart_provider.dart';
import 'package:SapaWarga_kel_2/screens/warga/marketplace/belanja/keranjangScreen.dart';
import 'package:SapaWarga_kel_2/services/marketplace/order_service.dart';
import 'package:SapaWarga_kel_2/utils.dart' show formatRupiah;
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
              title: '💳 Metode Pembayaran',
              icon: Icons.payment,
              children: [
                _buildPaymentMethod(
                  label: 'Tunai (COD)',
                  subtitle: 'Bayar saat barang diterima',
                  value: 'COD',
                  icon: Icons.money,
                ),
                _buildPaymentMethod(
                  label: 'Transfer Bank',
                  subtitle: 'Transfer ke rekening toko',
                  value: 'Transfer Bank',
                  icon: Icons.account_balance,
                ),
                _buildPaymentMethod(
                  label: 'QRIS',
                  subtitle: 'Scan QR Code untuk bayar',
                  value: 'QRIS',
                  icon: Icons.qr_code_scanner,
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
    String? subtitle,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? _primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? _primaryColor.withOpacity(0.05) : Colors.white,
      ),
      child: RadioListTile<String>(
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? _primaryColor : Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? _primaryColor.withOpacity(0.7)
                      : Colors.grey.shade600,
                ),
              )
            : null,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey.shade600,
            size: 20,
          ),
        ),
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (String? val) {
          setState(() {
            _selectedPaymentMethod = val!;
          });
        },
        activeColor: _primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
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
                // Check payment method first
                if (_selectedPaymentMethod == 'Transfer Bank') {
                  _showTransferBankDialog(context);
                } else if (_selectedPaymentMethod == 'QRIS') {
                  _showQRISDialog(context);
                } else {
                  // COD - langsung proses
                  _processOrder(context);
                }
              },
              icon: const Icon(Icons.lock_open, size: 24),
              label: Text(
                _selectedPaymentMethod == 'COD'
                    ? 'Buat Pesanan ${formatRupiah(_finalTotal)}'
                    : 'Lanjut Pembayaran',
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

  // Dialog untuk Transfer Bank
  void _showTransferBankDialog(BuildContext context) {
    final screenContext = context; // Simpan context screen
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_balance,
                color: _primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Transfer Bank',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Transfer ke rekening toko',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildBankInfo(
                      'Bank BCA',
                      '1234567890',
                      'Toko Sayur Segar',
                    ),
                    const SizedBox(height: 8),
                    _buildBankInfo(
                      'Bank Mandiri',
                      '9876543210',
                      'Toko Sayur Segar',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Total Transfer: ${formatRupiah(_finalTotal)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '📝 Instruksi:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildInstructionStep(
                '1',
                'Transfer ke salah satu rekening di atas',
              ),
              _buildInstructionStep(
                '2',
                'Pesanan akan dibuat dengan status "Menunggu Pembayaran"',
              ),
              _buildInstructionStep(
                '3',
                'Penjual akan konfirmasi setelah transfer diterima',
              ),
              _buildInstructionStep(
                '4',
                'Barang akan dikirim setelah pembayaran dikonfirmasi',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blue.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Konfirmasi pembayaran: 1x24 jam',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Delay sedikit agar dialog tertutup dulu
              Future.delayed(const Duration(milliseconds: 100), () {
                _processOrder(screenContext);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  // Dialog untuk QRIS
  void _showQRISDialog(BuildContext context) {
    final screenContext = context; // Simpan context screen
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                color: _primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Pembayaran QRIS',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 120,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'QR Code Toko',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total: ${formatRupiah(_finalTotal)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '📝 Cara Bayar:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildInstructionStep(
                '1',
                'Buka aplikasi e-wallet atau mobile banking',
              ),
              _buildInstructionStep('2', 'Scan QR Code di atas'),
              _buildInstructionStep('3', 'Selesaikan pembayaran'),
              _buildInstructionStep('4', 'Penjual akan konfirmasi otomatis'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mendukung: GoPay, OVO, Dana, LinkAja, ShopeePay',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Delay sedikit agar dialog tertutup dulu
              Future.delayed(const Duration(milliseconds: 100), () {
                _processOrder(screenContext);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sudah Bayar'),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfo(
    String bankName,
    String accountNumber,
    String accountName,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bankName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  accountNumber,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
              InkWell(
                onTap: () {
                  // TODO: Copy to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$accountNumber disalin'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(Icons.copy, size: 16, color: _primaryColor),
              ),
            ],
          ),
          Text(
            'a.n. $accountName',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text, style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processOrder(BuildContext context) async {
    print('🔄 [CHECKOUT] Starting _processOrder...');

    if (_userId == null) {
      print('❌ [CHECKOUT] User not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak terautentikasi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('✅ [CHECKOUT] User ID: $_userId');
    print('💳 [CHECKOUT] Payment Method: $_selectedPaymentMethod');
    print('🚚 [CHECKOUT] Delivery Method: $_selectedDeliveryOption');

    try {
      final orderService = OrderService();

      // Create order with payment & delivery info
      final shippingCost = _selectedDeliveryOption == 'Ambil di Toko Warga'
          ? 0.0
          : _shippingFee.toDouble();

      final newOrder = OrderModel(
        userId: _userId,
        totalPrice: _finalTotal.toDouble(),
        orderStatus:
            null, // Status NULL = pesanan baru, menunggu konfirmasi penjual
        alamat:
            'Jl. Mawar No. 12, RT 01 / RW 01', // TODO: get from user profile
        totalQty: _totalQuantity,
        createdAt: DateTime.now(),
        // Payment & Delivery fields
        paymentMethod: _selectedPaymentMethod, // COD, Transfer Bank, QRIS
        deliveryMethod: _selectedDeliveryOption, // Ambil di Toko / Diantar
        shippingFee: shippingCost,
        paymentStatus: 'paid', // Langsung dibayar untuk semua metode
      );

      print('📦 [CHECKOUT] Creating order...');
      final createdOrder = await orderService.createOrder(newOrder);
      print('✅ [CHECKOUT] Order created! ID: ${createdOrder.orderId}');

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
        _showSuccessDialog(context, createdOrder.orderId ?? 0);
      }
    } catch (e, stackTrace) {
      print('❌ [CHECKOUT] Error creating order: $e');
      print('📍 [CHECKOUT] Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context, int orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, _primaryColor.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon with animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, size: 60, color: _primaryColor),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Pesanan Berhasil!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),

              // Order ID
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, color: _primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Order ID: #$orderId',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                'Pesanan Anda telah berhasil dibuat!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                'Penjual akan segera memproses pesanan Anda',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/warga/marketplace/my-orders');
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Lihat Pesanan',
                        style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/warga/marketplace');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Belanja Lagi',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
