import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/order_model.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/order_service.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;
import 'package:jawara_pintar_kel_5/screens/warga/marketplace/belanja/write_review_screen.dart';

class BuyerOrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const BuyerOrderDetailScreen({super.key, required this.order});

  @override
  State<BuyerOrderDetailScreen> createState() => _BuyerOrderDetailScreenState();
}

class _BuyerOrderDetailScreenState extends State<BuyerOrderDetailScreen> {
  static const Color primaryColor = Color(0xFF6A5AE0);
  static const Color successColor = Color(0xFF4CAF50);

  List<Map<String, dynamic>> _orderItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderItems();
  }

  Future<void> _loadOrderItems() async {
    if (widget.order.orderId == null) return;
    
    try {
      final orderService = OrderService();
      final items = await orderService.getOrderWithItems(widget.order.orderId!);
      setState(() {
        _orderItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading order items: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(widget.order.orderStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTimeline(widget.order.orderStatus),
            const SizedBox(height: 20),
            
            _buildSectionTitle(context, "Informasi Pesanan"),
            _buildDetailCard(
              children: [
                _buildRow("Order ID", "#${widget.order.orderId}", isTitleBold: true),
                _buildRow("Total Item", "${widget.order.totalQty ?? 0} item"),
                _buildRow(
                  "Tanggal Pesan",
                  widget.order.createdAt?.toString().substring(0, 16) ?? "N/A",
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSectionTitle(context, "Alamat Pengiriman"),
            _buildDetailCard(
              children: [
                _buildRow(
                  "Alamat",
                  widget.order.alamat ?? "Alamat tidak tersedia",
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSectionTitle(context, "Detail Produk"),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orderItems.isEmpty
                    ? const Text("Tidak ada produk")
                    : Column(
                        children: _orderItems.map((item) {
                          final product = item['produk'];
                          final qty = item['qty'] as int? ?? 0;
                          final price = product['harga'] as num? ?? 0;
                          final subtotal = qty * price;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.shopping_bag,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['nama'] ?? 'Produk',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${formatRupiah(price.toInt())} x $qty',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formatRupiah(subtotal.toInt()),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

            const SizedBox(height: 20),

            _buildSectionTitle(context, "Ringkasan Pembayaran"),
            _buildDetailCard(
              children: [
                _buildRow(
                  "Subtotal Produk",
                  formatRupiah((widget.order.totalPrice ?? 0).toInt()),
                ),
                _buildRow("Biaya Admin", formatRupiah(1000)),
                const Divider(height: 16),
                _buildRow(
                  "Total Dibayar",
                  formatRupiah(((widget.order.totalPrice ?? 0) + 1000).toInt()),
                  valueStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tombol Review jika order completed
            if (widget.order.orderStatus?.toLowerCase() == 'completed')
              _buildReviewButton(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to review screen with order items
          if (_orderItems.isNotEmpty) {
            // For now, navigate to product review screen
            // You can implement multi-product review later
            final firstProduct = _orderItems[0]['produk'];
            final productId = firstProduct['product_id'] as int;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WriteReviewScreen(
                  productId: productId,
                  orderId: widget.order.orderId!,
                ),
              ),
            );
          }
        },
        icon: const Icon(Icons.rate_review, color: Colors.white),
        label: const Text(
          'Tulis Ulasan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(String? status) {
    final statusInfo = _getStatusInfo(status);
    final lower = status?.toLowerCase() ?? '';
    final isNull = lower == 'null' || status == null;
    final isPending = lower == 'pending';
    final isCompleted = lower == 'completed';
    final isCanceled = lower == 'canceled';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusInfo['icon'], color: statusInfo['color'], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Status: ${statusInfo['label']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusInfo['color'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTimelineStep(
              'Pesanan Dibuat',
              true,
              Colors.green,
            ),
            _buildTimelineStep(
              'Menunggu Konfirmasi Penjual',
              isNull || isPending || isCompleted,
              isNull ? Colors.orange : (isPending || isCompleted ? Colors.green : Colors.grey),
            ),
            _buildTimelineStep(
              'Sedang Dikirim',
              isPending || isCompleted,
              isPending || isCompleted ? Colors.blue : Colors.grey,
            ),
            _buildTimelineStep(
              'Pesanan Selesai',
              isCompleted,
              isCompleted ? Colors.green : Colors.grey,
              isLast: !isCanceled,
            ),
            if (isCanceled)
              _buildTimelineStep(
                'Pesanan Ditolak',
                true,
                Colors.red,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, bool isActive, Color color, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? color : Colors.grey.shade300,
                border: Border.all(
                  color: isActive ? color : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isActive ? color.withOpacity(0.3) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildRow(
    String title,
    String value, {
    TextStyle? valueStyle,
    bool isTitleBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: isTitleBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String? status) {
    final lower = status?.toLowerCase() ?? '';
    
    if (lower == 'null' || status == null) {
      return {
        'label': 'Menunggu Konfirmasi',
        'color': Colors.orange,
        'icon': Icons.hourglass_empty,
      };
    }
    
    switch (lower) {
      case 'pending':
        return {
          'label': 'Sedang Dikirim',
          'color': Colors.blue,
          'icon': Icons.local_shipping,
        };
      case 'completed':
        return {
          'label': 'Selesai',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'canceled':
        return {
          'label': 'Ditolak',
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      default:
        return {
          'label': status ?? 'Unknown',
          'color': Colors.grey,
          'icon': Icons.help_outline,
        };
    }
  }
}
