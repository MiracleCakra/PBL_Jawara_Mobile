import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/order_model.dart' show OrderModel;
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;

class Menupesanan extends StatelessWidget {
  const Menupesanan({super.key});

  static const Color pendingColor = Colors.orange;
  static const Color completedColor = Colors.green;
  static const Color canceledColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    final List<OrderModel> orders = OrderModel.dummyOrders; 

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: orders.isEmpty
          ? _buildEmptyOrders()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(context, order);
              },
            ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'Belum ada pesanan masuk.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
  // Warna status sesuai permintaan
  Color statusColor;
  switch (order.status.toLowerCase()) {
    case 'selesai':
      statusColor = Colors.deepPurple;
      break;
    case 'perlu dikirim':
      statusColor = Colors.amber;
      break;
    case 'dikirim':
      statusColor = Colors.green;
      break;
    default:
      statusColor = Colors.grey;
  }

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    color: Colors.white,
    child: ListTile(
      contentPadding: const EdgeInsets.all(12),
      tileColor: null,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: const Icon(Icons.shopping_bag, color: Colors.blue),
      ),
      title: Text(
        order.productName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jumlah: ${order.quantity}',
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            'Total: ${formatRupiah(order.totalPrice)}',
            style: const TextStyle(fontSize: 13, color: Colors.green),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.25),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: statusColor.withOpacity(0.7),
              ),
            ),
            child: Text(
              order.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        context.pushNamed('MyStoreOrderDetail', extra: order);
      },
    ),
  );
}
}
