import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/order_model.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;

class MyStoreOrderDetail extends StatelessWidget {
  final OrderModel order;

  const MyStoreOrderDetail({super.key, required this.order});

  static const Color primaryColor = Color(0xFF6A5AE0); // Ungu Tua
  static const Color accentColor = Color(0xFF8EA3F5); // Ungu Muda
  static const Color successColor = Color(0xFF4CAF50); // Hijau
  static const Color warningColor = Colors.orange;
  static const Color errorColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

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
      backgroundColor: const Color(
        0xFFF7F7F7,
      ), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(order.status, statusColor),
            const SizedBox(height: 16),

            _buildSectionTitle(context, "Informasi Produk"),
            _buildDetailCard(
              children: [
                _buildRow("Nama Produk", order.productName, isTitleBold: true),
                _buildRow("Jumlah", "${order.quantity} item"),
              ],
            ),

            const SizedBox(height: 20),

            _buildSectionTitle(context, "Info Pembeli & Pengiriman"),
            _buildDetailCard(
              children: [
                _buildRow(
                  "Nama Pembeli",
                  order.customerName,
                  isValuePrimary: true,
                ),
                _buildRow(
                  "Alamat",
                  order.deliveryAddress ?? "Alamat tidak tersedia",
                ),
                _buildRow("Tanggal Pesan", "24 Nov 2025"),
              ],
            ),

            const SizedBox(height: 20),

            _buildSectionTitle(context, "Ringkasan Pembayaran"),
            _buildDetailCard(
              children: [
                _buildRow("Subtotal Produk", formatRupiah(order.totalPrice)),
                _buildRow("Biaya Admin", formatRupiah(1000)),
                const Divider(height: 10),
                _buildRow(
                  "Total Dibayar",
                  formatRupiah(order.totalPrice + 1000),
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

            _buildActionButtons(context, order.status),
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
          "STATUS: ${status.toUpperCase()}",
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: isTitleBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style:
                valueStyle ??
                TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isValuePrimary ? primaryColor : Colors.black87,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String status) {
    final lowerStatus = status.toLowerCase();

    if (lowerStatus == 'pending') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Pesanan berhasil diproses!")),
            );
          },
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          label: const Text("Proses Pesanan"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => Navigator.pop(context),
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Tutup Detail",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "selesai":
        return Colors.purple;
      case "perlu dikirim":
        return Colors.amber;
      case "dikirim":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
