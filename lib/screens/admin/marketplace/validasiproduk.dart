import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const Color unguColor = Color(0xFF6366F1);

class ProductValidation {
  final String id;
  final String productName;
  final String sellerName;
  final String category;
  final String imageUrl;
  final String timeUploaded;
  final String cvResult;
  final double cvConfidence;
  final String status;
  final String description;

  const ProductValidation({
    required this.id,
    required this.productName,
    required this.sellerName,
    required this.category,
    required this.imageUrl,
    required this.timeUploaded,
    required this.cvResult,
    required this.cvConfidence,
    required this.status,
    this.description = '',
  });

  ProductValidation copyWith({String? status}) {
    return ProductValidation(
      id: id,
      productName: productName,
      sellerName: sellerName,
      category: category,
      imageUrl: imageUrl,
      timeUploaded: timeUploaded,
      cvResult: cvResult,
      cvConfidence: cvConfidence,
      status: status ?? this.status,
      description: description,
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class ValidasiProdukBaruScreen extends StatefulWidget {
  const ValidasiProdukBaruScreen({super.key});

  @override
  State<ValidasiProdukBaruScreen> createState() =>
      _ValidasiProdukBaruScreenState();
}

class _ValidasiProdukBaruScreenState extends State<ValidasiProdukBaruScreen> {
  List<ProductValidation> _allProducts = [
    const ProductValidation(
      id: 'P001',
      productName: 'Tomat Segar',
      sellerName: 'Warga Blok A2/05',
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
      sellerName: 'Warga Blok C1/12',
      category: 'Sayuran',
      imageUrl: 'assets/images/tomatbusuk.jpg',
      timeUploaded: '25 menit lalu',
      cvResult: 'Hasil Buah Busuk',
      cvConfidence: 0.25,
      status: 'Ditolak',
      description: 'Produk tidak sesuai standar kualitas.',
    ),
    const ProductValidation(
      id: 'P003',
      productName: 'Wortel Segar',
      sellerName: 'Warga Blok B5/01',
      category: 'Sayuran',
      imageUrl: 'assets/images/wortelsegar.jpg',
      timeUploaded: '1 jam lalu',
      cvResult: 'Akar Sayuran Kualitas Baik',
      cvConfidence: 0.99,
      status: 'Pending',
      description: 'Wortel segar dengan ukuran seragam dan warna orange cerah.',
    ),
    const ProductValidation(
      id: 'P004',
      productName: 'Wortel Layu',
      sellerName: 'Warga Blok F1/02',
      category: 'Sayuran',
      imageUrl: 'assets/images/wortellayu.jpg',
      timeUploaded: '3 jam lalu',
      cvResult: 'Akar Sayuran Kualitas Rendah',
      cvConfidence: 0.65,
      status: 'Disetujui',
      description: 'Wortel dengan kualitas standar untuk konsumsi.',
    ),
  ];

  List<ProductValidation> _filteredProducts = [];
  String _currentSearchQuery = '';
  String _currentFilterStatus = 'Semua';

  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  bool get isFilterActive => _currentFilterStatus != 'Semua';

  @override
  void initState() {
    super.initState();
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

  void _showDetailDialog(ProductValidation item) {
    Color confidenceColor = item.cvConfidence > 0.90
        ? Colors.green.shade700
        : (item.cvConfidence > 0.70
              ? Colors.orange.shade700
              : Colors.red.shade700);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detail Produk',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Gambar Produk
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      item.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Produk
                  _buildDetailRow(
                    'Nama Produk',
                    item.productName,
                    Icons.shopping_bag,
                  ),
                  _buildDetailRow('Kategori', item.category, Icons.category),
                  _buildDetailRow('Penjual', item.sellerName, Icons.person),
                  _buildDetailRow(
                    'Waktu Upload',
                    item.timeUploaded,
                    Icons.access_time,
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Deskripsi:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description.isNotEmpty ? item.description : '-',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),

                  const SizedBox(height: 16),

                  // Hasil Computer Vision
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verifikasi Computer Vision',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Klasifikasi:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  Text(
                                    item.cvResult,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade900,
                                    ),
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
                                color: confidenceColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${(item.cvConfidence * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: confidenceColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol Aksi
                  if (item.status == 'Pending')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _handleReject(item);
                            },
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Tolak'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _handleApprove(item);
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Setujui'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: unguColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleApprove(ProductValidation item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Setujui Produk'),
          content: Text(
            'Apakah Anda yakin ingin menyetujui produk "${item.productName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _refreshListAfterAction(item.id, 'Disetujui');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Produk "${item.productName}" telah disetujui',
                    ),
                    backgroundColor: Colors.grey.shade800,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: unguColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Setujui'),
            ),
          ],
        );
      },
    );
  }

  void _handleReject(ProductValidation item) {
    String alasan = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Tolak Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anda akan menolak produk "${item.productName}". Masukkan alasan penolakan:',
                style: TextStyle(color: Colors.grey[800], fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => alasan = value,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Gambar blur, produk tidak sesuai kategori',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (alasan.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Alasan tidak boleh kosong'),
                      backgroundColor: Colors.grey.shade800,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                _refreshListAfterAction(item.id, 'Ditolak');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Produk "${item.productName}" telah ditolak. Alasan: $alasan',
                    ),
                    backgroundColor: Colors.grey.shade800,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(ProductValidation item) {
    Color statusColor;
    Color statusBgColor;

    switch (item.status) {
      case 'Pending':
        statusColor = Colors.yellow.shade800;
        statusBgColor = Colors.yellow.shade100;
        break;
      case 'Ditolak':
        statusColor = Colors.red.shade800;
        statusBgColor = Colors.red.shade100;
        break;
      case 'Disetujui':
        statusColor = Colors.purple.shade800;
        statusBgColor = Colors.purple.shade100;
        break;
      default:
        statusColor = Colors.red.shade800;
        statusBgColor = Colors.red.shade100;
        break;
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailDialog(item),
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
                            fontSize: 16,
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
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
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
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Cari Berdasarkan Nama Sayur...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 24,
                    color: Colors.grey.shade500,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 45,
                    minHeight: 45,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF4E46B4),
                      width: 1.5,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: isFilterActive ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _openFilterModal,
              borderRadius: BorderRadius.circular(8),
              highlightColor: Colors.transparent,
              splashColor: Colors.grey.withOpacity(0.2),
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: isFilterActive ? Colors.grey.shade200 : Colors.white,
                ),
                child: Icon(
                  Icons.tune,
                  color: isFilterActive ? Colors.black54 : Colors.black87,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Validasi Produk Baru',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              'Daftar Produk (${_filteredProducts.length} data)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
