import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;

class OrderModel {
  final String orderId;
  final String date;
  final int totalAmount;
  final String status;
  final String itemName;
  final String imageUrl;

  OrderModel({
    required this.orderId,
    required this.date,
    required this.totalAmount,
    required this.status,
    required this.itemName,
    required this.imageUrl,
  });
}
List<OrderModel> dummyOrders = [
  OrderModel(
    orderId: 'JWP-20251124-001',
    date: '24 Nov 2025',
    totalAmount: 25000,
    status: 'Diproses',
    itemName: 'Tomat Segar Grade A (x2)',
    imageUrl: 'assets/images/tomatsegar.jpg',
  ),
  OrderModel(
    orderId: 'JWP-20251120-045',
    date: '20 Nov 2025',
    totalAmount: 13000,
    status: 'Selesai',
    itemName: 'Wortel Layu Grade B (x3)',
    imageUrl: 'assets/images/wortellayu.jpg',
  ),
  OrderModel(
    orderId: 'JWP-20251118-022',
    date: '18 Nov 2025',
    totalAmount: 45000,
    status: 'Dibatalkan',
    itemName: 'Bawang Merah Grade A (x1)',
    imageUrl: 'assets/images/wortelsegar.jpg',
  ),
];


class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});
  
  static const Color _primaryColor = Color(0xFF6A5AE0); 
  static const Color _backgroundColor = Color(0xFFF7F7F7); 

  @override
  Widget build(BuildContext context) {
    final activeOrders = dummyOrders.where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan').toList();
    final historyOrders = dummyOrders.where((o) => o.status == 'Selesai' || o.status == 'Dibatalkan').toList();
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _backgroundColor, 
        appBar: AppBar(
          title: const Text('Riwayat Pesanan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: Colors.black,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pesanan Aktif'),
              Tab(text: 'Riwayat Selesai'),
            ],
            labelColor: _primaryColor,
            indicatorColor: _primaryColor,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(context, activeOrders),
            _buildOrderList(context, historyOrders),
          ],
        ),
      ),
    );
  }

  // --- WIDGET DAFTAR PESANAN ---
  Widget _buildOrderList(BuildContext context, List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 15),
            Text('Tidak ada pesanan di sini.', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    Color statusColor;
    switch (order.status) {
      case 'Diproses':
        statusColor = Colors.orange;
        break;
      case 'Selesai':
        statusColor = Colors.green;
        break;
      case 'Dibatalkan':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return InkWell(
      onTap: () {
          context.pushNamed('WargaOrderDetail', extra: order);
      },
      child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
              padding: const EdgeInsets.all(16.0), 
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      // Header Pesanan & Status
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text(
                                  'ID: ${order.orderId}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                      order.status,
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                              ),
                          ],
                      ),
                      Text(order.date, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const Divider(height: 15),

                      // Detail Item
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                      order.imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                          width: 60, height: 60, color: _primaryColor.withOpacity(0.1),
                                          child: const Center(child: Icon(Icons.image_not_supported, size: 20, color: _primaryColor)),
                                      ),
                                  ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(
                                      order.itemName,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                  ),
                              ),
                          ],
                      ),
                      const Divider(height: 20), 
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      const Text('Total Bayar', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text(
                                          formatRupiah(order.totalAmount),
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _primaryColor),
                                      ),
                                  ],
                              ),
                              
                              if (order.status == 'Diproses')
                                  ElevatedButton(
                                      onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka halaman lacak pesanan')));
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: _primaryColor, 
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      ),
                                      child: const Text('Lacak Pesanan'),
                                  )
                              else if (order.status == 'Selesai')
                                  TextButton(
                                      onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membuka formulir ulasan')));
                                      },
                                      style: TextButton.styleFrom(foregroundColor: _primaryColor),
                                      child: const Text('Beri Ulasan'),
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
