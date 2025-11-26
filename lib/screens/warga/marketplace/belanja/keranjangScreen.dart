
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/product_model.dart'; 
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah; 

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
  
  int get subtotal => product.price * quantity;
}

List<CartItem> initialCartItems = [
  CartItem(product: ProductModel.getSampleProducts()[0], quantity: 2),
  CartItem(product: ProductModel.getSampleProducts()[3], quantity: 3),
  CartItem(product: ProductModel.getSampleProducts()[2], quantity: 1),
];

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
  }

  void _updateQuantity(CartItem item, int delta) {
    setState(() {
      item.quantity += delta;
      if (item.quantity <= 0) {
        _cartItems.remove(item);
      }
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cartItems.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.product.name} dihapus dari keranjang.'), backgroundColor: Colors.red.shade700)
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
                child: Image.asset(
                  item.product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                        width: 80, height: 80, color: Colors.red.shade100,
                        child: Center(child: Icon(Icons.error_outline, size: 30, color: Colors.red.shade600)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis, 
                    ),
                    const SizedBox(height: 4),
                    // Detail Grade
                    Text(
                      'Grade: ${item.product.grade}',
                      style: TextStyle(
                        fontSize: 13,
                        color: item.product.grade == 'Grade A' ? _greenFresh : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Harga Satuan
                    Text(
                      formatRupiah(item.product.price),
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
                  _buildQuantityButton(Icons.remove, () => _updateQuantity(item, -1), item.quantity <= 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildQuantityButton(Icons.add, () => _updateQuantity(item, 1), false),
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
          )
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap, bool isDisabled) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade300 : _primaryColor.withOpacity(0.1),
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
          _buildSummaryRow('Biaya Pengiriman', formatRupiah(_shippingFee), false),
          const Divider(height: 25),
          _buildSummaryRow('Total Pembayaran', formatRupiah(_totalAmount), true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _cartItems.isEmpty ? null : () {
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
        title: const Text('Keranjang Belanja', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      
      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 15),
                  Text(
                    'Keranjang Anda Kosong.',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.go('/warga/marketplace/explore'),
                    style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                    child: const Text('Mulai Belanja', style: TextStyle(color: Colors.white)),
                  )
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