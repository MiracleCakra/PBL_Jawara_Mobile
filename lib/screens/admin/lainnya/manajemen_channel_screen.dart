import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/models/keuangan/channel_transfer_model.dart';
import 'package:SapaWarga_kel_2/services/channel_transfer_service.dart'; // Sesuaikan path
import 'package:SapaWarga_kel_2/utils.dart' show getPrimaryColor;

class ChannelTransferScreen extends StatefulWidget {
  const ChannelTransferScreen({super.key});

  @override
  State<ChannelTransferScreen> createState() => _ChannelTransferScreenState();
}

class _ChannelTransferScreenState extends State<ChannelTransferScreen> {
  final Color primary = const Color(0xFF4E46B4);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ChannelTransferService _channelService = ChannelTransferService();
  late Stream<List<ChannelTransferModel>> _channelStream;

  String _query = '';
  String? _selectedTypeFilter;

  void _refreshData() {
    setState(() {
      _channelStream = const Stream.empty();
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        _channelStream = _channelService.getChannelsStream();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _channelStream = _channelService.getChannelsStream();
  }

  List<ChannelTransferModel> _applyFilter(List<ChannelTransferModel> data) {
    return data.where((channel) {
      final searchLower = _query.toLowerCase();
      final matchesSearch =
          channel.nama.toLowerCase().contains(searchLower) ||
          channel.pemilik.toLowerCase().contains(searchLower);
      final matchesType =
          _selectedTypeFilter == null ||
          channel.tipe.toLowerCase() == _selectedTypeFilter!.toLowerCase();

      return matchesSearch && matchesType;
    }).toList();
  }

  void _openFilter() {
    String tempSelected = _selectedTypeFilter ?? 'Semua';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
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
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Filter Channel Transfer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tipe Channel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        key: const Key('dropdown_filter_tipe_channel'),
                        value: tempSelected,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
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
                              color: Color(0xFF4E46B4),
                              width: 1.2,
                            ),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Semua',
                            child: Text('Semua'),
                          ),
                          DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                          DropdownMenuItem(value: 'QRIS', child: Text('QRIS')),
                          DropdownMenuItem(
                            value: 'e-wallet',
                            child: Text('E-Wallet'),
                          ),
                        ],
                        onChanged: (v) =>
                            setModalState(() => tempSelected = v ?? 'Semua'),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
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
                                  _selectedTypeFilter = 'Semua';
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: getPrimaryColor(context),
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
                                  _selectedTypeFilter = tempSelected;
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Terapkan'),
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

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        borderSide: const BorderSide(color: Color(0xFF4E46B4), width: 1.2),
      ),
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Channel Transfer',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/admin/lainnya/manajemen-channel/tambah');
          _refreshData();
        },
        backgroundColor: getPrimaryColor(context),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: const Text(
                'Daftar Channel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            _SearchFilterBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (v) => setState(() => _query = v),
              onFilterTap: _openFilter,
            ),
            Expanded(
              child: StreamBuilder<List<ChannelTransferModel>>(
                stream: _channelStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("Belum ada channel transfer."),
                    );
                  }

                  final filteredList = _applyFilter(snapshot.data!);

                  if (filteredList.isEmpty) {
                    return const Center(
                      child: Text("Tidak ada data yang cocok."),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80, top: 8),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final channel = filteredList[index];
                        return _ChannelCard(
                          channel: channel, // Kirim object model
                          primary: primary,
                          onTap: () async {
                            await context.push(
                              '/admin/lainnya/channel-transfer/detail',
                              extra: channel,
                            );
                            _refreshData();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const _SearchFilterBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                onTap: () => focusNode.requestFocus(),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  hintText: 'Cari Nama Channel / Pemilik...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 1.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.03),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.tune, color: Colors.black, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final ChannelTransferModel channel;
  final Color primary;
  final VoidCallback? onTap;

  const _ChannelCard({
    required this.channel,
    required this.primary,
    this.onTap,
  });

  // Badge style mirip validasi akun
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
        return const Color(0xFF4E46B4);
      case 'qris':
        return const Color(0xFFF59E0B);
      case 'e-wallet':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getTypeBgColor(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
        return const Color(0xFFEDE7F6);
      case 'qris':
        return const Color(0xFFFFF7E6);
      case 'e-wallet':
        return const Color(0xFFE6FFF5);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(channel.tipe);
    final typeBgColor = _getTypeBgColor(channel.tipe);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.nama, // Panggil properti model
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      channel.pemilik, // Panggil properti model
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                  color: typeBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: typeColor.withOpacity(0.3)),
                ),
                child: Text(
                  channel.tipe,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
