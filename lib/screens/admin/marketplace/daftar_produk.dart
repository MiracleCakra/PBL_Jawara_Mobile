import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_validation_model.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/store_model.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/product_service.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/store_service.dart';

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
  // Data produk dari Supabase
  List<ProductValidation> _allProducts = [];
  List<ProductValidation> _filteredProducts = [];
  String _currentSearchQuery = '';
  String _currentFilterStatus = 'Semua';
  bool _isLoading = false;

  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  final ProductService _productService = ProductService();

  bool get isFilterActive => _currentFilterStatus != 'Semua';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      // Load produk real dari Supabase
      final products = await _productService.getProductsByStoreForAdmin(
        widget.store.storeId!,
      );

      setState(() {
        _allProducts = products
            .map((p) => _convertToProductValidation(p))
            .toList();
        _filterList();
      });
    } catch (e) {
      print('Error loading products: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat produk: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  ProductValidation _convertToProductValidation(ProductModel product) {
    return ProductValidation(
      id: product.productId.toString(),
      productName: product.nama ?? 'Produk Tanpa Nama',
      sellerName: widget.store.nama ?? 'Toko',
      category: 'Sayuran',
      imageUrl: product.gambar ?? '',
      timeUploaded: _getTimeAgo(product.createdAt),
      cvResult: product.grade ?? '-',
      cvConfidence: 0.95,
      status: (product.stok ?? 0) > 0 ? 'Aktif' : 'Habis',
      description: product.deskripsi ?? '',
    );
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Tidak diketahui';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
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
    final List<String> options = ['Semua', 'Aktif', 'Habis'];
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
      case 'Aktif':
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFD1FAE5);
        break;
      case 'Habis':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusBgColor = const Color(0xFFF3F4F6);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailValidasiProdukScreen(
                product: item,
                onStatusUpdated: _refreshListAfterAction,
              ),
            ),
          );

          // If product was deleted (result == true), reload the product list
          if (result == true && mounted) {
            await _loadProducts();
          }
        },
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
                        child: item.imageUrl.startsWith('http')
                            ? Image.network(
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
                              )
                            : Image.asset(
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

  void _showDeactivateStoreDialog() {
    final TextEditingController alasanController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.block,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Nonaktifkan Toko',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Toko: ${widget.store.nama}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toko yang dinonaktifkan tidak dapat menjual produk. Pemilik toko harus mengajukan permohonan aktivasi ulang kepada admin.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Alasan Nonaktif *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: alasanController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Contoh: Toko menjual produk yang tidak sesuai dengan ketentuan...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (alasanController.text
                                          .trim()
                                          .isEmpty) {
                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Alasan nonaktif harus diisi',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() {
                                        isLoading = true;
                                      });

                                      try {
                                        final storeService = StoreService();
                                        await storeService
                                            .deactivateStoreByAdmin(
                                              widget.store.storeId!,
                                              alasanController.text.trim(),
                                            );

                                        if (!this.mounted) return;

                                        Navigator.pop(dialogContext);

                                        // Show success dialog
                                        await showDialog(
                                          context: this.context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              backgroundColor: Colors.white,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            16,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: unguColor
                                                            .withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        color: unguColor,
                                                        size: 48,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    const Text(
                                                      'Toko telah dinonaktifkan',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      'Toko "${widget.store.nama}" berhasil dinonaktifkan dari sistem',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 14,
                                                              ),
                                                          backgroundColor:
                                                              unguColor,
                                                          elevation: 0,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'OK',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
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

                                        // Back to previous screen
                                        this.context.pop();
                                      } catch (e) {
                                        setState(() {
                                          isLoading = false;
                                        });

                                        if (!this.mounted) return;

                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Gagal menonaktifkan toko: $e',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: Colors.red,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
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
              ),
            );
          },
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(unguColor),
                    ),
                  )
                : _filteredProducts.isEmpty
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
