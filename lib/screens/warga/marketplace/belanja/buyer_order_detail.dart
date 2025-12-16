import 'package:SapaWarga_kel_2/models/marketplace/order_model.dart';
import 'package:SapaWarga_kel_2/screens/warga/marketplace/belanja/write_review_screen.dart';
import 'package:SapaWarga_kel_2/services/marketplace/order_service.dart';
import 'package:SapaWarga_kel_2/utils.dart' show formatRupiah;
import 'package:flutter/material.dart';

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
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    if (widget.order.orderId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final orderService = OrderService();

      // Reload order data from database to get fresh info
      final freshOrder = await orderService.getOrderById(widget.order.orderId!);

      // If order not found, use widget.order
      if (freshOrder == null) {
        // Load order items only
        final items = await orderService.getOrderWithItems(
          widget.order.orderId!,
        );
        setState(() {
          _orderItems = items;
          _isLoading = false;
        });
        return;
      }

      // Load order items
      final items = await orderService.getOrderWithItems(widget.order.orderId!);

      setState(() {
        _currentOrder = freshOrder;
        _orderItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading order data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(_currentOrder.orderStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTimeline(_currentOrder.orderStatus),
            const SizedBox(height: 20),

            _buildSectionTitle(context, "Informasi Pesanan"),
            _buildDetailCard(
              children: [
                _buildRow(
                  "Order ID",
                  "#${_currentOrder.orderId}",
                  isTitleBold: true,
                ),
                _buildRow("Total Item", "${_currentOrder.totalQty ?? 0} item"),
                _buildRow(
                  "Tanggal Pesan",
                  _currentOrder.createdAt?.toString().substring(0, 16) ?? "N/A",
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSectionTitle(context, "Alamat Pengiriman"),
            _buildDetailCard(
              children: [
                _buildRow(
                  "Alamat",
                  _currentOrder.alamat ?? "Alamat tidak tersedia",
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

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor.withOpacity(0.1),
                                      primaryColor.withOpacity(0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: primaryColor,
                                  size: 28,
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
                                        color: Colors.black87,
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

            _buildSectionTitle(context, "Metode Pengiriman & Pembayaran"),
            _buildDetailCard(
              children: [
                _buildRow(
                  "Metode Pengiriman",
                  _currentOrder.deliveryMethod ?? 'Ambil di Toko',
                  icon: Icons.local_shipping,
                ),
                _buildRow(
                  "Ongkos Kirim",
                  formatRupiah((_currentOrder.shippingFee ?? 0).toInt()),
                  icon: Icons.delivery_dining,
                ),
                const Divider(height: 16),
                _buildRow(
                  "Metode Pembayaran",
                  _formatPaymentMethod(_currentOrder.paymentMethod),
                  icon: Icons.payment,
                ),
                _buildPaymentStatusRow(
                  "Status Pembayaran",
                  _currentOrder.paymentStatus ?? 'unpaid',
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
                    ((_currentOrder.totalPrice ?? 0) -
                            (_currentOrder.shippingFee ?? 0))
                        .toInt(),
                  ),
                ),
                _buildRow(
                  "Ongkos Kirim",
                  formatRupiah((_currentOrder.shippingFee ?? 0).toInt()),
                ),
                const Divider(height: 16),
                _buildRow(
                  "Total Dibayar",
                  formatRupiah((_currentOrder.totalPrice ?? 0).toInt()),
                  valueStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tombol Bayar Sekarang jika pesanan diterima tapi belum bayar
            if (_currentOrder.orderStatus?.toLowerCase() == 'completed' &&
                _currentOrder.paymentStatus?.toLowerCase() == 'unpaid')
              _buildPaymentButton(),

            // Tombol Review jika order completed dan sudah bayar
            if (_currentOrder.orderStatus?.toLowerCase() == 'completed' &&
                _currentOrder.paymentStatus?.toLowerCase() == 'paid')
              _buildReviewButton(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Container(
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
              Icon(Icons.info_outline, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pesanan Anda telah diterima! Silakan lakukan pembayaran',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _showPaymentDialog();
              },
              icon: const Icon(Icons.payment, color: Colors.white),
              label: const Text(
                'Bayar Sekarang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusInfo['color'].withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusInfo['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusInfo['color'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    statusInfo['icon'],
                    color: statusInfo['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
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
            const SizedBox(height: 20),
            _buildTimelineStep('Pesanan Dibuat', true, primaryColor),
            _buildTimelineStep(
              'Menunggu Konfirmasi Penjual',
              isNull || isPending || isCompleted,
              isNull
                  ? primaryColor
                  : (isPending || isCompleted ? primaryColor : Colors.grey),
            ),
            _buildTimelineStep(
              'Sedang Dikirim',
              isPending || isCompleted,
              isPending || isCompleted ? primaryColor : Colors.grey,
            ),
            _buildTimelineStep(
              'Pesanan Selesai',
              isCompleted,
              isCompleted ? primaryColor : Colors.grey,
              isLast: !isCanceled,
            ),
            if (isCanceled)
              _buildTimelineStep(
                'Pesanan Ditolak',
                true,
                const Color(0xFFEF5350),
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    bool isActive,
    Color color, {
    bool isLast = false,
  }) {
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
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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

  void _showPaymentDialog() {
    final paymentMethod = _currentOrder.paymentMethod ?? 'COD';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.payment, color: primaryColor, size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pembayaran ${_formatPaymentMethod(paymentMethod)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Instruksi pembayaran berdasarkan metode
                if (paymentMethod == 'COD')
                  _buildCODInstructions()
                else if (paymentMethod == 'QRIS')
                  _buildQRISInstructions()
                else if (paymentMethod == 'Transfer Bank')
                  _buildTransferInstructions(),

                const SizedBox(height: 24),

                // Tombol
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Nanti',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _confirmPayment(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          paymentMethod == 'QRIS' ? 'Lanjutkan' : 'Sudah Bayar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCODInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
          const SizedBox(height: 12),
          Text(
            'Pembayaran COD (Cash on Delivery)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Anda akan membayar saat barang diterima. Siapkan uang pas sebesar:',
            style: TextStyle(fontSize: 13, color: Colors.blue.shade800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            formatRupiah((_currentOrder.totalPrice ?? 0).toInt()),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRISInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code_2, color: Colors.green.shade700, size: 48),
          const SizedBox(height: 12),
          Text(
            'Scan QRIS di bawah ini',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Placeholder QRIS - bisa diganti dengan QR code generator
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.qr_code,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total: ${formatRupiah((_currentOrder.totalPrice ?? 0).toInt())}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: primaryColor, size: 32),
              const SizedBox(width: 12),
              Text(
                'Transfer ke Rekening',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBankInfo('BCA', '1234567890', 'Toko Jawara'),
          const Divider(height: 16),
          _buildBankInfo('Mandiri', '0987654321', 'Toko Jawara'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Transfer:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  formatRupiah((_currentOrder.totalPrice ?? 0).toInt()),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bankName,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              accountNumber,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            GestureDetector(
              onTap: () {
                // Copy to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nomor rekening disalin'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Icon(Icons.copy, size: 18, color: primaryColor),
            ),
          ],
        ),
        Text(
          'a.n. $accountName',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Future<void> _confirmPayment() async {
    Navigator.pop(context); // Tutup dialog

    try {
      final orderService = OrderService();
      await orderService.updatePaymentStatus(_currentOrder.orderId!, 'paid');

      // Refresh order data
      await _loadOrderData();

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengkonfirmasi pembayaran: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Terima Kasih!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Terima kasih telah berbelanja di toko kami. Pembayaran Anda telah dikonfirmasi dan pesanan akan segera diproses.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Trigger rebuild untuk refresh tampilan
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

    // Auto close after 2 seconds and refresh
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          // Trigger rebuild untuk refresh tampilan detail pesanan
        });
      }
    });
  }

  Map<String, dynamic> _getStatusInfo(String? status) {
    final lower = status?.toLowerCase() ?? '';

    if (lower == 'null' || status == null) {
      return {
        'label': 'Menunggu Konfirmasi',
        'color': const Color(0xFFFB8C00),
        'icon': Icons.hourglass_empty,
      };
    }

    switch (lower) {
      case 'pending':
        return {
          'label': 'Sedang Dikirim',
          'color': const Color(0xFF42A5F5),
          'icon': Icons.local_shipping,
        };
      case 'completed':
        return {
          'label': 'Selesai',
          'color': const Color(0xFF66BB6A),
          'icon': Icons.check_circle,
        };
      case 'canceled':
        return {
          'label': 'Ditolak',
          'color': const Color(0xFFEF5350),
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

  String _formatPaymentMethod(String? method) {
    if (method == null || method.isEmpty) return 'COD';

    // Return the payment method as is since it's already in proper format
    // COD, Transfer Bank, or QRIS
    return method;
  }
}
