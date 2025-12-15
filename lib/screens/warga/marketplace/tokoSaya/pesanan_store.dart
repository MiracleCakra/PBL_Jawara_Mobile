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
  List<Map<String, dynamic>> _filteredOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'Semua'; // Semua, Diantar, Selesai
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilter();
    });
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
          _applyFilter();
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

  void _applyFilter() {
    List<Map<String, dynamic>> filtered = _orders;

    // Apply status filter
    if (_selectedFilter == 'Diantar') {
      filtered = filtered.where((orderData) {
        final order = orderData['order'];
        final status = (order['order_status'] as String? ?? '').toLowerCase();
        return status == 'pending';
      }).toList();
    } else if (_selectedFilter == 'Selesai') {
      filtered = filtered.where((orderData) {
        final order = orderData['order'];
        final status = (order['order_status'] as String? ?? '').toLowerCase();
        return status == 'completed';
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((orderData) {
        final order = orderData['order'];
        final product = orderData['produk'];
        final orderId = (order['order_id'] ?? '').toString();
        final productName = (product['nama'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();

        return orderId.contains(query) || productName.contains(query);
      }).toList();
    }

    _filteredOrders = filtered;
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6A5AE0);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
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
          : Column(
              children: [
                _buildSearchBar(primaryColor),
                Expanded(
                  child: _filteredOrders.isEmpty
                      ? _buildEmptyFilteredOrders()
                      : RefreshIndicator(
                          onRefresh: _loadOrders,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final orderData = _filteredOrders[index];
                              return _buildOrderCard(context, orderData);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Berdasarkan ID/Produk...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(primaryColor),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Icon(
                Icons.filter_list,
                color: Colors.grey.shade700,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(Color primaryColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.filter_alt,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Filter Pesanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildFilterOption(
                'Semua',
                'Tampilkan semua pesanan',
                primaryColor,
              ),
              _buildFilterOption(
                'Diantar',
                'Pesanan sedang diantar',
                primaryColor,
              ),
              _buildFilterOption(
                'Selesai',
                'Pesanan telah selesai',
                primaryColor,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    String label,
    String description,
    Color primaryColor,
  ) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        _onFilterChanged(label);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.08) : Colors.white,
          border: Border(
            left: BorderSide(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilteredOrders() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_off, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'Tidak ada pesanan $_selectedFilter',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
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
    const primaryColor = Color(0xFF6A5AE0);

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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: const Icon(Icons.shopping_bag, color: primaryColor),
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
