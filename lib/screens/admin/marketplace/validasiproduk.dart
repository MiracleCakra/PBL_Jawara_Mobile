import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:jawara_pintar_kel_5/models/marketplace/marketplace_model.dart';
import 'detail_validasi_produk.dart';

const Color unguColor = Color(0xFF6366F1);

class ValidasiProdukBaruScreen extends StatefulWidget {
  const ValidasiProdukBaruScreen({super.key});

  @override
  State<ValidasiProdukBaruScreen> createState() =>
      _ValidasiProdukBaruScreenState();
}

class _ValidasiProdukBaruScreenState extends State<ValidasiProdukBaruScreen> {
  List<ActiveProductItem> _allProducts = [
    const ActiveProductItem(
      id: 'P001',
      productName: 'Tomat Segar',
      sellerName: 'Warga Blok A2/05',
      category: 'Sayuran',
      imageUrl: 'assets/images/tomatsegar.jpg',
      timeUploaded: '5 menit lalu',
      cvResult: 'Tomat Kualitas A',
      cvConfidence: 0.98,
      status: 'Pending',
    ),
    const ActiveProductItem(
      id: 'P002',
      productName: 'Tomat Busuk',
      sellerName: 'Warga Blok C1/12',
      category: 'Sayuran',
      imageUrl: 'assets/images/tomatbusuk.jpg',
      timeUploaded: '25 menit lalu',
      cvResult: 'Hasil Buah Busuk',
      cvConfidence: 0.25,
      status: 'Ditolak',
    ),
    const ActiveProductItem(
      id: 'P003',
      productName: 'Wortel Segar',
      sellerName: 'Warga Blok B5/01',
      category: 'Sayuran',
      imageUrl: 'assets/images/wortelsegar.jpg',
      timeUploaded: '1 jam lalu',
      cvResult: 'Akar Sayuran Kualitas Baik',
      cvConfidence: 0.99,
      status: 'Pending',
    ),
    const ActiveProductItem(
      id: 'P004',
      productName: 'Wortel Layu',
      sellerName: 'Warga Blok F1/02',
      category: 'Sayuran',
      imageUrl: 'assets/images/wortellayu.jpg',
      timeUploaded: '3 jam lalu',
      cvResult: 'Akar Sayuran Kualitas Rendah',
      cvConfidence: 0.65,
      status: 'Disetujui',
    ),
  ];

  List<ActiveProductItem> _filteredProducts = [];
  String _currentSearchQuery = '';
  String _currentFilterStatus = 'Semua';
  bool isFilterActive = false;

  final Debouncer _debouncer = Debouncer(milliseconds: 300);

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

  // FILTER UTAMA
  void _filterList() {
    setState(() {
      _filteredProducts = _allProducts.where((item) {
        bool statusMatch = _currentFilterStatus == 'Semua' ||
            item.status == _currentFilterStatus;

        bool searchMatch = _currentSearchQuery.isEmpty ||
            item.productName
                .toLowerCase()
                .contains(_currentSearchQuery.toLowerCase());

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

  // BOTTOM SHEET FILTER
  void _openFilterModal() {
    final List<String> options = ['Semua', 'Pending', 'Disetujui', 'Ditolak'];
    String? tempSelectedStatus = _currentFilterStatus;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Filter Berdasarkan Status',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...options.map((status) {
                    return ListTile(
                      title: Text(status),
                      leading: Radio<String>(
                        value: status,
                        groupValue: tempSelectedStatus,
                        onChanged: (String? value) {
                          modalSetState(() {
                            tempSelectedStatus = value;
                          });

                          if (value != null) {
                            setState(() {
                              _currentFilterStatus = value;
                              isFilterActive = value != "Semua"; // 🔥 update
                              _filterList();
                            });
                            context.pop();
                          }
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _currentFilterStatus = status;
                          isFilterActive = status != "Semua"; // 🔥 update
                          _filterList();
                        });
                        context.pop();
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // KARTU PRODUK
  Widget _buildValidationCard(
      BuildContext context, ActiveProductItem item) {
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
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailValidasiProdukScreen(
                product: item,
                onActionComplete: (newStatus) {
                  _refreshListAfterAction(item.id, newStatus);
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Penjual: ${item.sellerName}',
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    Text(
                      'Diunggah: ${item.timeUploaded}',
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FILTER BAR (SEARCH + ICON)
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
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4E46B4), width: 1.5),
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
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold),
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
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                return _buildValidationCard(
                    context, _filteredProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}