import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_validation_model.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/store_model.dart';

import 'detail_validasi_produk.dart';

const Color unguColor = Color(0xFF6366F1);

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class DaftarProdukTokoScreen extends StatefulWidget {
  final StoreModel store;

  const DaftarProdukTokoScreen({super.key, required this.store});

  @override
  State<DaftarProdukTokoScreen> createState() => _DaftarProdukTokoScreenState();
}

class _DaftarProdukTokoScreenState extends State<DaftarProdukTokoScreen> {
  // Data dummy produk untuk toko
  List<ProductValidation> _allProducts = [];
  List<ProductValidation> _filteredProducts = [];
  String _currentSearchQuery = '';
  String _currentFilterStatus = 'Semua';

  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  bool get isFilterActive => _currentFilterStatus != 'Semua';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    // Dummy data produk berdasarkan toko
    _allProducts = [
      const ProductValidation(
        id: 'P001',
        productName: 'Tomat Segar',
        sellerName: 'Toko Sayur Segar Pak Budi',
        category: 'Sayuran',
        imageUrl: 'assets/images/tomatsegar.jpg',
        timeUploaded: '5 menit lalu',
        cvResult: 'Tomat Kualitas A',
        cvConfidence: 0.98,
        status: 'Pending',
        description:
            'Tomat segar berkualitas tinggi dengan warna merah cerah dan tekstur padat.',
      ),
      const ProductValidation(
        id: 'P002',
        productName: 'Tomat Busuk',
        sellerName: 'Toko Sayur Segar Pak Budi',
        category: 'Sayuran',
        imageUrl: 'assets/images/tomatbusuk.jpg',
        timeUploaded: '25 menit lalu',
        cvResult: 'Hasil Buah Busuk',
        cvConfidence: 0.25,
        status: 'Ditolak',
        description:
            'Produk tidak sesuai standar kualitas. Ditolak karena busuk.',
      ),
      const ProductValidation(
        id: 'P003',
        productName: 'Wortel Segar',
        sellerName: 'Toko Sayur Segar Pak Budi',
        category: 'Sayuran',
        imageUrl: 'assets/images/wortelsegar.jpg',
        timeUploaded: '1 jam lalu',
        cvResult: 'Akar Sayuran Kualitas Baik',
        cvConfidence: 0.99,
        status: 'Pending',
        description:
            'Wortel segar dengan ukuran seragam dan warna orange cerah.',
      ),
      const ProductValidation(
        id: 'P004',
        productName: 'Wortel Layu',
        sellerName: 'Toko Sayur Segar Pak Budi',
        category: 'Sayuran',
        imageUrl: 'assets/images/wortellayu.jpg',
        timeUploaded: '3 jam lalu',
        cvResult: 'Akar Sayuran Kualitas Rendah',
        cvConfidence: 0.65,
        status: 'Disetujui',
        description: 'Wortel dengan kualitas standar untuk konsumsi.',
      ),
    ];

    _filterList();
  }

  void _refreshListAfterAction(String productId, String newStatus) {
    setState(() {
      final index = _allProducts.indexWhere((item) => item.id == productId);
      if (index != -1) {
        _allProducts[index] = _allProducts[index].copyWith(status: newStatus);
        _filterList();
      }
    });
  }

  void _filterList() {
    setState(() {
      _filteredProducts = _allProducts.where((item) {
        bool statusMatch =
            _currentFilterStatus == 'Semua' ||
            item.status == _currentFilterStatus;

        bool searchMatch =
            _currentSearchQuery.isEmpty ||
            item.productName.toLowerCase().contains(
              _currentSearchQuery.toLowerCase(),
            ) ||
            item.sellerName.toLowerCase().contains(
              _currentSearchQuery.toLowerCase(),
            );

        return statusMatch && searchMatch;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      setState(() {
        _currentSearchQuery = query;
        _filterList();
      });
    });
  }

  void _openFilterModal() {
    final List<String> options = ['Semua', 'Pending', 'Disetujui', 'Ditolak'];
    String? tempSelectedStatus = _currentFilterStatus;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Filter Status Produk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...options.map((status) {
                      final bool isSelected = tempSelectedStatus == status;
                      return ListTile(
                        title: Text(status),
                        leading: Radio<String>(
                          value: status,
                          groupValue: tempSelectedStatus,
                          activeColor: unguColor,
                          onChanged: (String? value) {
                            modalSetState(() {
                              tempSelectedStatus = value;
                            });
                            if (value != null) {
                              setState(() {
                                _currentFilterStatus = value;
                                _filterList();
                              });
                              Navigator.pop(context);
                            }
                          },
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: unguColor)
                            : null,
                        onTap: () {
                          setState(() {
                            _currentFilterStatus = status;
                            _filterList();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductValidation item) {
    Color statusColor;
    Color statusBgColor;

    switch (item.status) {
      case 'Pending':
        statusColor = const Color(0xFFF59E0B);
        statusBgColor = const Color(0xFFFEF3C7);
        break;
      case 'Ditolak':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        break;
      case 'Disetujui':
        statusColor = const Color(0xFF673AB7);
        statusBgColor = const Color(0xFFEDE7F6);
        break;
      default:
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailValidasiProdukScreen(
              product: item,
              onStatusUpdated: _refreshListAfterAction,
            ),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 8),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: unguColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          item.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.shopping_basket,
                              color: unguColor,
                              size: 30,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Penjual: ${item.sellerName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.timeUploaded,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Setujui Semua Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  subtitle: Text(
                    'Setujui semua produk pending',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showApproveAllProductsDialog();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.store_mall_directory_outlined,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Nonaktifkan Toko',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    'Toko tidak dapat menjual produk',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeactivateStoreDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showApproveAllProductsDialog() {
    final pendingProducts = _allProducts
        .where((p) => p.status == 'Pending')
        .length;

    if (pendingProducts == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak ada produk pending untuk disetujui'),
          backgroundColor: Colors.grey.shade800,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF6366F1),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Setujui Semua Produk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Apakah Anda yakin ingin menyetujui semua $pendingProducts produk pending dari toko "${widget.store.nama}"?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implementasi logika setujui semua produk
                          setState(() {
                            for (var i = 0; i < _allProducts.length; i++) {
                              if (_allProducts[i].status == 'Pending') {
                                _allProducts[i] = _allProducts[i].copyWith(
                                  status: 'Disetujui',
                                );
                              }
                            }
                            _filterList();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$pendingProducts produk telah disetujui',
                              ),
                              backgroundColor: Colors.grey.shade800,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF6366F1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Setujui',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

  void _showDeactivateStoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nonaktifkan Toko',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Apakah Anda yakin ingin menonaktifkan toko "${widget.store.nama}"? Toko yang dinonaktifkan tidak dapat menjual produk.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implementasi logika nonaktifkan toko
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Toko "${widget.store.nama}" telah dinonaktifkan',
                              ),
                              backgroundColor: Colors.grey.shade800,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Nonaktifkan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Produk',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.store.nama ?? 'Nama Toko',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showOptionsBottomSheet,
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Daftar Produk (${_filteredProducts.length} produk)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada produk.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      bottom: 80,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
