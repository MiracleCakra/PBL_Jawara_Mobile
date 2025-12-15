import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:SapaWarga_kel_2/models/marketplace/store_model.dart';
import 'package:SapaWarga_kel_2/providers/marketplace/store_provider.dart';
import 'package:provider/provider.dart';

const Color primaryColor = Color(0xFF6A5AE0);

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class ValidasiAkunTokoScreen extends StatefulWidget {
  const ValidasiAkunTokoScreen({super.key});

  @override
  State<ValidasiAkunTokoScreen> createState() => _ValidasiAkunTokoScreenState();
}

class _ValidasiAkunTokoScreenState extends State<ValidasiAkunTokoScreen> {
  List<StoreModel> _filteredStores = [];
  String _currentSearchQuery = '';
  String _currentFilterStatus = 'Semua';
  bool isFilterActive = false;
  bool _isLoading = false;

  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() => _isLoading = true);

    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    await storeProvider.fetchAllStores();

    _filterList();

    setState(() => _isLoading = false);
  }

  void _filterList() {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final allStores = storeProvider.stores;

    setState(() {
      _filteredStores = allStores.where((store) {
        bool statusMatch =
            _currentFilterStatus == 'Semua' ||
            (store.verifikasi?.toLowerCase() ==
                _currentFilterStatus.toLowerCase());

        bool searchMatch =
            _currentSearchQuery.isEmpty ||
            (store.nama?.toLowerCase().contains(
                  _currentSearchQuery.toLowerCase(),
                ) ??
                false) ||
            (store.kontak?.toLowerCase().contains(
                  _currentSearchQuery.toLowerCase(),
                ) ??
                false);

        return statusMatch && searchMatch;
      }).toList();
    });
  }

  String _getTimeAgo(DateTime? createdAt) {
    if (createdAt == null) return 'Tidak diketahui';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(createdAt);
    }
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
    final List<String> options = ['Semua', 'Pending', 'Diterima', 'Ditolak'];
    String tempSelectedStatus = _currentFilterStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (c) {
        final bottom = MediaQuery.of(c).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6A5AE0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.filter_alt,
                              color: Color(0xFF6A5AE0),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Filter Status Akun Toko',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Status Verifikasi',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          key: const Key('dropdown_filter_status_verifikasi'),
                          value: tempSelectedStatus,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          dropdownColor: Colors.white,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF6A5AE0),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          items: options
                              .map(
                                (option) => DropdownMenuItem(
                                  value: option,
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setModalState(
                            () => tempSelectedStatus = v ?? 'Semua',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey.shade700,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentFilterStatus = 'Semua';
                                  isFilterActive = false;
                                  _filterList();
                                });
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Reset',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A5AE0),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentFilterStatus = tempSelectedStatus;
                                  isFilterActive =
                                      tempSelectedStatus != 'Semua';
                                  _filterList();
                                });
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Terapkan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
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
          ),
        );
      },
    );
  }

  Widget _buildRegistrationCard(BuildContext context, StoreModel store) {
    Color statusColor;
    Color statusBgColor;

    final status = (store.verifikasi ?? 'Pending').toLowerCase();
    switch (status) {
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusBgColor = const Color(0xFFFEF3C7);
        break;
      case 'ditolak':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        break;
      case 'diterima':
        statusColor = const Color(0xFF6366F1);
        ;
        statusBgColor = const Color(0xFFEDE7F6);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusBgColor = const Color(0xFFF3F4F6);
        break;
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.pushNamed('detailValidasiToko', extra: store).then((_) {
            _loadStores();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.nama ?? 'Nama Toko',
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
                          'ID: ${store.storeId ?? '-'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          store.verifikasi ?? 'Pending',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      if (store.deactivatedBy == 'admin' &&
                          store.verifikasi == 'Pending') ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh,
                                size: 12,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Aktivasi Ulang',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    store.kontak ?? '-',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      store.alamat ?? '-',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getTimeAgo(store.createdAt),
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
                  hintText: 'Cari nama toko atau pemilik...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
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
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: isFilterActive ? Colors.grey.shade200 : Colors.white,
                ),
                child: Icon(
                  Icons.tune,
                  color: isFilterActive ? primaryColor : Colors.grey.shade600,
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
          'Validasi Akun Toko Warga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterBar(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Text(
                    'Daftar Validasi (${_filteredStores.length} data)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredStores.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.store_mall_directory_outlined,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada data toko',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadStores,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredStores.length,
                            itemBuilder: (context, index) {
                              return _buildRegistrationCard(
                                context,
                                _filteredStores[index],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
