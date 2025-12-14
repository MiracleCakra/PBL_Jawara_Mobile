import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/order_model.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/order_service.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;
import 'package:jawara_pintar_kel_5/widget/marketplace/custom_dialog.dart';

class MyStoreOrderDetail extends StatefulWidget {
  final OrderModel order;

  const MyStoreOrderDetail({super.key, required this.order});

  @override
  State<MyStoreOrderDetail> createState() => _MyStoreOrderDetailState();
}

class _MyStoreOrderDetailState extends State<MyStoreOrderDetail> {
  static const Color primaryColor = Color(0xFF6A5AE0);
  static const Color accentColor = Color(0xFF8EA3F5);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Colors.orange;
  static const Color errorColor = Colors.red;

  late String currentStatus;
  List<Map<String, dynamic>> _orderItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    currentStatus =
        widget.order.orderStatus ??
        'null'; // Keep as 'null' string if no status
    _loadOrderItems();
  }

  Future<void> _loadOrderItems() async {
    if (widget.order.orderId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final orderService = OrderService();
      final items = await orderService.getOrderWithItems(widget.order.orderId!);

      if (mounted) {
        setState(() {
          _orderItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading order items: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> updateOrderStatus(String newStatus) async {
    if (widget.order.orderId == null) {
      CustomSnackbar.show(
        context: context,
        message: 'Order ID tidak valid',
        type: DialogType.error,
      );
      return;
    }

    try {
      // Update status in database
      final orderService = OrderService();
      await orderService.updateOrderStatus(widget.order.orderId!, newStatus);

      if (mounted) {
        setState(() => currentStatus = newStatus);

        CustomSnackbar.show(
          context: context,
          message: 'Status berhasil diubah: $newStatus',
          type: DialogType.success,
        );

        // Return to previous screen with update flag
        if (newStatus == 'completed') {
          Navigator.pop(context, 'completed');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          message: 'Gagal mengubah status: $e',
          type: DialogType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(currentStatus);

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
            _buildStatusHeader(currentStatus, statusColor),
            const SizedBox(height: 16),

            _buildSectionTitle(context, "Informasi Pesanan"),
            _buildDetailCard(
              children: [
                _buildRow(
                  "Order ID",
                  "#${widget.order.orderId}",
                  isTitleBold: true,
                ),
                _buildRow("Total Item", "${widget.order.totalQty ?? 0} item"),
              ],
            ),

            const SizedBox(height: 20),

            _buildSectionTitle(context, "Info Pembeli & Pengiriman"),
            _buildDetailCard(
              children: [
                _buildRow(
                  "User ID",
                  widget.order.userId ?? "N/A",
                  isValuePrimary: true,
                  icon: Icons.person,
                ),
                _buildRow(
                  "Alamat Pengiriman",
                  widget.order.alamat ?? "Alamat tidak tersedia",
                  icon: Icons.location_on,
                ),
                _buildRow(
                  "Metode Pengiriman",
                  widget.order.deliveryMethod ?? "Ambil di Toko",
                  icon: Icons.local_shipping,
                ),
                _buildRow(
                  "Tanggal Pesan",
                  widget.order.createdAt?.toString().substring(0, 10) ?? "N/A",
                  icon: Icons.calendar_today,
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSectionTitle(context, "Detail Pembayaran"),
            _buildDetailCard(
              children: [
                _buildRow(
                  "Metode Pembayaran",
                  widget.order.paymentMethod ?? "COD",
                  icon: Icons.payment,
                ),
                _buildPaymentStatusRow(
                  "Status Pembayaran",
                  widget.order.paymentStatus ?? 'unpaid',
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSectionTitle(context, "Ringkasan Pembayaran"),
            _buildDetailCard(
              children: [
                _buildRow(
                  "Subtotal Produk",
                  formatRupiah(
                    ((widget.order.totalPrice ?? 0) -
                            (widget.order.shippingFee ?? 0))
                        .toInt(),
                  ),
                ),
                _buildRow(
                  "Ongkos Kirim",
                  formatRupiah((widget.order.shippingFee ?? 0).toInt()),
                ),
                const Divider(height: 10),
                _buildRow(
                  "Total Dibayar",
                  formatRupiah((widget.order.totalPrice ?? 0).toInt()),
                  valueStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                  isTitleBold: true,
                ),
              ],
            ),

            const SizedBox(height: 30),

            _buildActionButtons(currentStatus),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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

  Widget _buildStatusHeader(String status, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Center(
        child: Text(
          "STATUS: ${_getStatusLabel(status)}",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String title,
    String value, {
    TextStyle? valueStyle,
    bool isTitleBold = false,
    bool isValuePrimary = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: primaryColor),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: isTitleBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  valueStyle ??
                  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isValuePrimary ? primaryColor : Colors.black87,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusRow(String title, String status) {
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (status.toLowerCase()) {
      case 'paid':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        statusLabel = 'Lunas';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusLabel = 'Menunggu Konfirmasi';
        break;
      case 'unpaid':
      default:
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        statusLabel = 'Belum Bayar';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    final lower = status.toLowerCase();
    final paymentStatus = widget.order.paymentStatus?.toLowerCase() ?? 'unpaid';

    // Status: NULL (pesanan baru, belum direspons)
    if (lower == 'null' || status == 'null' || status.isEmpty) {
      return Column(
        children: [
          _button(
            label: "✅ Terima & Kirim Pesanan",
            icon: Icons.local_shipping_outlined,
            color: primaryColor,
            onTap: () {
              updateOrderStatus("pending");
              Navigator.pop(context, "pending");
            },
          ),
          const SizedBox(height: 12),
          _button(
            label: "❌ Tolak Pesanan",
            icon: Icons.cancel_outlined,
            color: Colors.red,
            onTap: () {
              updateOrderStatus("canceled");
              Navigator.pop(context, "canceled");
            },
          ),
        ],
      );
    }

    // Status: pending (pesanan sedang diantar)
    if (lower == 'pending') {
      return Column(
        children: [
          // Jika belum bayar & metode COD, beri info
          if (paymentStatus == 'unpaid' && widget.order.paymentMethod == 'COD')
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pembayaran COD - Terima uang saat pengiriman',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _button(
            label: "✅ Pesanan Selesai",
            icon: Icons.check_circle_outline,
            color: successColor,
            onTap: () {
              updateOrderStatus("completed");
              Navigator.pop(context, "completed");
            },
          ),
        ],
      );
    }

    // Status: completed atau canceled (tidak ada aksi)
    if (lower == 'completed' || lower == 'canceled') {
      return const SizedBox.shrink();
    }

    return _button(
      label: "Tutup Detail",
      icon: Icons.close,
      color: Colors.deepPurple,
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _button({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower == 'null' || status == 'null' || status.isEmpty) {
      return Colors.orange;
    }
    switch (lower) {
      case "pending":
        return Colors.blue;
      case "completed":
        return Colors.green;
      case "canceled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    final lower = status.toLowerCase();
    if (lower == 'null' || status == 'null' || status.isEmpty) {
      return "PESANAN BARU";
    }
    switch (lower) {
      case "pending":
        return "SEDANG DIANTAR";
      case "completed":
        return "SELESAI";
      case "canceled":
        return "DITOLAK";
      default:
        return status.toUpperCase();
    }
  }
}
