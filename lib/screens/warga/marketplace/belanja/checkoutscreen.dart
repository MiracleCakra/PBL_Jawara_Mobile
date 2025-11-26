import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/keranjangScreen.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;

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
  final List<CartItem> _checkoutItems = initialCartItems;

  static const int _shippingFee = 5000;

  int get _subtotal {
    return _checkoutItems.fold(0, (sum, item) => sum + item.subtotal);
  }
  int get _finalTotal {
    final currentShipping = _selectedDeliveryOption == 'Ambil di Toko Warga'
        ? 0
        : _shippingFee;
    return _subtotal + currentShipping;
  }

  @override
  Widget build(BuildContext context) {
    if (_checkoutItems.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Keranjang kosong. Tidak bisa Checkout.')),
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
              children: [
                ..._checkoutItems
                    .map((item) => _buildOrderSummaryItem(item))
                    .toList(),
              ],
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
                _buildPaymentMethod(
                  label: 'Transfer Bank (Manual)',
                  value: 'Transfer Manual',
                  icon: Icons.account_balance_outlined,
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

  Widget _buildOrderSummaryItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.product.imageUrl,
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
                  '${item.product.name} (${item.product.grade})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.quantity} x ${formatRupiah(item.product.price)}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                'Bayar ${formatRupiah(_finalTotal)}',
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

  void _processOrder(BuildContext context) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pesanan berhasil dibuat! Menunggu pembayaran via: $_selectedPaymentMethod',
        ),
        backgroundColor: Colors.grey.shade800,
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      context.go('/warga/marketplace/orders');
    });
  }
}
