import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/order_model.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/order_service.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/store_service.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;
import 'package:supabase_flutter/supabase_flutter.dart';

class Menupesanan extends StatefulWidget {
  const Menupesanan({super.key});

  @override
  State<Menupesanan> createState() => _MenupesananState();
}

class _MenupesananState extends State<Menupesanan> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      // Only show loading on first load
      if (_orders.isEmpty) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      // Get current user
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser?.email == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'User tidak terautentikasi';
          });
        }
        return;
      }

      // Get warga.id (NIK)
      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', authUser!.email!)
          .maybeSingle();

      if (wargaResponse == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Data warga tidak ditemukan';
          });
        }
        return;
      }

      final userId = wargaResponse['id'] as String;

      // Get user's store
      final storeService = StoreService();
      final store = await storeService.getStoreByUserId(userId);

      if (store == null || store.storeId == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Toko tidak ditemukan';
          });
        }
        return;
      }

      // Get orders for this store
      final orderService = OrderService();
      final orders = await orderService.getOrdersByStore(store.storeId!);

      print(
        'DEBUG Orders: Loaded ${orders.length} orders for store ${store.storeId}',
      );

      if (mounted) {
        setState(() {
          _orders = orders;
          if (_isLoading) _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading orders: $e');
      if (mounted) {
        setState(() {
          if (_isLoading) _isLoading = false;
          _errorMessage = 'Gagal memuat pesanan: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadOrders,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : _orders.isEmpty
          ? _buildEmptyOrders()
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final orderData = _orders[index];
                  return _buildOrderCard(context, orderData);
                },
              ),
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

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> orderData) {
    // Extract order data from nested structure
    final order = orderData['order'];
    final product = orderData['produk'];

    final orderId = order['order_id'] as int?;
    final orderStatus = order['order_status'] as String? ?? 'pending';
    final totalPrice = order['total_price'] as num? ?? 0;
    final productName = product['nama'] as String? ?? 'Produk';
    final qty = orderData['qty'] as int? ?? 0;

    Color statusColor;
    String statusLabel;
    final lower = orderStatus.toLowerCase();
    if (lower == 'null' || orderStatus == 'null' || orderStatus.isEmpty) {
      statusColor = Colors.orange;
      statusLabel = 'Baru';
    } else {
      switch (lower) {
        case 'pending':
          statusColor = Colors.blue;
          statusLabel = 'Diantar';
          break;
        case 'completed':
          statusColor = Colors.green;
          statusLabel = 'Selesai';
          break;
        case 'canceled':
          statusColor = Colors.red;
          statusLabel = 'Ditolak';
          break;
        default:
          statusColor = Colors.grey;
          statusLabel = orderStatus;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.shopping_bag, color: Colors.blue),
        ),
        title: Text(
          'Order #$orderId',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('Jumlah: $qty item', style: const TextStyle(fontSize: 13)),
            Text(
              'Total: ${formatRupiah(totalPrice.toInt())}',
              style: const TextStyle(fontSize: 13, color: Colors.green),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () async {
          // Convert orderData to OrderModel
          final orderModel = OrderModel(
            orderId: orderId,
            userId: order['user_id'] as String?,
            totalPrice: totalPrice.toDouble(),
            orderStatus: orderStatus,
            alamat: order['alamat'] as String?,
            totalQty: order['total_qty'] as int?,
            createdAt: order['created_at'] != null
                ? DateTime.parse(order['created_at'] as String)
                : null,
            updatedAt: order['updated_at'] != null
                ? DateTime.parse(order['updated_at'] as String)
                : null,
          );

          // Navigate to order detail and handle return
          final result = await context.pushNamed(
            'MyStoreOrderDetail',
            extra: orderModel,
          );

          // Refresh if order was updated (any status change)
          if (result != null && mounted) {
            _loadOrders();
          }
        },
      ),
    );
  }
}
