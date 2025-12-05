import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const Color unguColor = Color(0xFF6366F1);

class StoreRegistration {
  final String id;
  final String storeName;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final String description;
  final String timeSubmitted;
  final String status; // 'Pending', 'Disetujui', 'Ditolak'

  const StoreRegistration({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.description,
    required this.timeSubmitted,
    required this.status,
  });

  StoreRegistration copyWith({String? status}) {
    return StoreRegistration(
      id: id,
      storeName: storeName,
      ownerName: ownerName,
      email: email,
      phone: phone,
      address: address,
      description: description,
      timeSubmitted: timeSubmitted,
      status: status ?? this.status,
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

class ValidasiAkunTokoScreen extends StatefulWidget {
  const ValidasiAkunTokoScreen({super.key});

  @override
  State<ValidasiAkunTokoScreen> createState() => _ValidasiAkunTokoScreenState();
}

class _ValidasiAkunTokoScreenState extends State<ValidasiAkunTokoScreen> {
  List<StoreRegistration> _allRegistrations = [
    const StoreRegistration(
      id: 'S001',
      storeName: 'SSS, Sayur Segar Susanto',
      ownerName: 'Susanto',
      email: 'susanto@email.com',
      phone: '081234567890',
      address: 'Jl. Anggrek No. 5, RT 001 / RW 001',
      description:
          'Menyediakan sayuran dan buah segar dari kebun lokal dengan pengiriman cepat ke seluruh RW.',
      timeSubmitted: '10 menit lalu',
      status: 'Pending',
    ),
    const StoreRegistration(
      id: 'S002',
      storeName: 'Sayur Ibu Dewi',
      ownerName: 'Dewi Lestari',
      email: 'dewi.lestari@email.com',
      phone: '082345678901',
      address: 'Jl. Mawar No. 12, RT 002 / RW 001',
      description: 'Sayur lengkap dengan harga terjangkau, melayani COD.',
      timeSubmitted: '10 jam lalu',
      status: 'Disetujui',
    ),
    const StoreRegistration(
      id: 'S003',
      storeName: 'Toko Sayur Segar Pak Budi',
      ownerName: 'Budi Santoso',
      email: 'budi.santoso@email.com',
      phone: '083456789012',
      address: 'Jl. Melati No. 8, RT 003 / RW 001',
      description:
          'Menjual berbagai macam sayuran segar lokal dengan kualitas terbaik.',
      timeSubmitted: '2 jam lalu',
      status: 'Pending',
    ),
    const StoreRegistration(
      id: 'S004',
      storeName: 'Toko Sayur Murah',
      ownerName: 'Ahmad Rifai',
      email: 'ahmad.rifai@email.com',
      phone: '084567890123',
      address: 'Jl. Kenanga No. 3, RT 004 / RW 001',
      description: 'Penyedia sayur dengan harga murah dan kualitas terjamin.',
      timeSubmitted: '3 jam lalu',
      status: 'Ditolak',
    ),
  ];

  List<StoreRegistration> _filteredRegistrations = [];
  String _currentSearchQuery = '';
  String _currentFilterStatus = 'Semua';
  bool isFilterActive = false;

  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _filterList();
  }

  void _refreshListAfterAction(String registrationId, String newStatus) {
    setState(() {
      final index = _allRegistrations.indexWhere(
        (item) => item.id == registrationId,
      );
      if (index != -1) {
        _allRegistrations[index] = _allRegistrations[index].copyWith(
          status: newStatus,
        );
        _filterList();
      }
    });
  }

  void _filterList() {
    setState(() {
      _filteredRegistrations = _allRegistrations.where((item) {
        bool statusMatch =
            _currentFilterStatus == 'Semua' ||
            item.status == _currentFilterStatus;

        bool searchMatch =
            _currentSearchQuery.isEmpty ||
            item.storeName.toLowerCase().contains(
              _currentSearchQuery.toLowerCase(),
            ) ||
            item.ownerName.toLowerCase().contains(
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
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Filter Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...options.map((option) {
                    final isSelected = option == tempSelectedStatus;
                    return RadioListTile<String>(
                      value: option,
                      groupValue: tempSelectedStatus,
                      title: Text(option),
                      activeColor: unguColor,
                      onChanged: (val) {
                        modalSetState(() {
                          tempSelectedStatus = val;
                        });
                        setState(() {
                          _currentFilterStatus = val!;
                          isFilterActive = val != 'Semua';
                          _filterList();
                        });
                        Navigator.pop(context);
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

  Widget _buildRegistrationCard(BuildContext context, StoreRegistration item) {
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
        onTap: () {
          _showDetailDialog(context, item);
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
                      color: unguColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: unguColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.storeName,
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
                          'Pemilik: ${item.ownerName}',
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
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    item.phone,
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
                      item.address,
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
                    item.timeSubmitted,
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

  void _showDetailDialog(BuildContext context, StoreRegistration item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detail Toko',
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
                const SizedBox(height: 20),
                _buildDetailRow('ID Pendaftaran', item.id),
                _buildDetailRow('Nama Toko', item.storeName),
                _buildDetailRow('Pemilik', item.ownerName),
                _buildDetailRow('Email', item.email),
                _buildDetailRow('No. HP', item.phone),
                _buildDetailRow('Alamat', item.address),
                _buildDetailRow(
                  'Deskripsi',
                  item.description,
                  isMultiline: true,
                ),
                _buildDetailRow('Waktu Daftar', item.timeSubmitted),
                _buildDetailRow('Status', item.status),
                const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
            maxLines: isMultiline ? 5 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _handleApprove(StoreRegistration item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Setujui Pendaftaran'),
        content: Text(
          'Apakah Anda yakin ingin menyetujui pendaftaran toko "${item.storeName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(backgroundColor: Colors.grey.shade300),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _refreshListAfterAction(item.id, 'Disetujui');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Toko "${item.storeName}" telah disetujui'),
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
      ),
    );
  }

  void _handleReject(StoreRegistration item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Tolak Pendaftaran'),
        content: Text(
          'Apakah Anda yakin ingin menolak pendaftaran toko "${item.storeName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(backgroundColor: Colors.grey.shade300),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _refreshListAfterAction(item.id, 'Ditolak');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Toko "${item.storeName}" telah ditolak'),
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
                    borderSide: const BorderSide(color: unguColor, width: 2),
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
                  color: isFilterActive ? unguColor : Colors.grey.shade600,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              'Daftar Validasi (${_filteredRegistrations.length} data)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRegistrations.length,
              itemBuilder: (context, index) {
                return _buildRegistrationCard(
                  context,
                  _filteredRegistrations[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
