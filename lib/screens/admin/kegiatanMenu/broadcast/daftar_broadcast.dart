import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/broadcast_model.dart';
import 'package:SapaWarga_kel_2/services/broadcast_service.dart';
import 'package:SapaWarga_kel_2/constants/constant_colors.dart';
import 'broadcast_filter_screen.dart';
import 'detail_broadcast_screen.dart';
import 'tambah_broadcast.dart';

class DaftarBroadcastScreen extends StatefulWidget {
  const DaftarBroadcastScreen({super.key});

  @override
  State<DaftarBroadcastScreen> createState() => _DaftarBroadcastScreenState();
}

class _DaftarBroadcastScreenState extends State<DaftarBroadcastScreen> {
  final BroadcastService _broadcastService = BroadcastService();
  
  // Ganti Stream dengan List untuk fetch manual
  List<BroadcastModel> _allBroadcasts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  String _searchQuery = '';
  DateTime? _filterDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final TextEditingController _searchController = TextEditingController();
  bool get _isFilterActive => _filterDate != null;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _broadcastService.getBroadcasts();
      if (mounted) {
        setState(() {
          _allBroadcasts = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data: $e';
        });
      }
    }
  }

  void _refreshData() {
    _fetchData();
  }

  void _showFilterModal(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            ),

            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: BroadcastFilterScreen(initialDate: _filterDate),
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _filterDate = result['date'] as DateTime?;
        _searchController.clear();
        _searchQuery = '';
      });
    }
  }

  void _navigateToDetail(BuildContext context, BroadcastModel data) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailBroadcastScreen(broadcastModel: data),
      ),
    );
    // Refresh jika ada perubahan (return true dari detail)
    if (result == true) {
      _refreshData();
    }
  }

  void _navigateToAddBroadcast() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahBroadcastScreen()),
    );
    // Refresh jika berhasil nambah (return true dari tambah)
    if (result == true) {
      _refreshData();
    }
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextField(
                key: const Key('broadcast_search_field'),
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Cari Berdasarkan Judul/Pengirim...',
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
            color: _isFilterActive ? Colors.grey.shade200 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              key: const Key('broadcast_filter_button'),
              onTap: () => _showFilterModal(context),
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
                  color: _isFilterActive ? Colors.grey.shade200 : Colors.white,
                ),
                child: Icon(
                  Icons.tune,
                  color: _isFilterActive ? Colors.black54 : Colors.black87,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastCard(BroadcastModel broadcast) {
    final Color detailColor = Colors.grey.shade700;

    return GestureDetector(
      onTap: () => _navigateToDetail(context, broadcast),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        broadcast.judul,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              broadcast.pengirim,
                              style: TextStyle(
                                fontSize: 14,
                                color: detailColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "Tanggal : ${_dateFormat.format(broadcast.tanggal)}",
                            style: TextStyle(fontSize: 14, color: detailColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        broadcast.konten.length > 80
                            ? "${broadcast.konten.substring(0, 80)}..."
                            : broadcast.konten,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Broadcast',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty 
                  ? Center(child: Text(_errorMessage))
                  : Builder(
                      builder: (context) {
                        if (_allBroadcasts.isEmpty) {
                          return const Center(
                            child: Text("Tidak ada Broadcast yang ditemukan."),
                          );
                        }

                        // FILTERING LOGIC
                        final filteredBroadcasts = _allBroadcasts.where((broadcast) {
                          final query = _searchQuery.toLowerCase();
                          final judul = broadcast.judul.toLowerCase();
                          final pengirim = broadcast.pengirim.toLowerCase();

                          final matchesSearch = query.isEmpty ||
                              judul.contains(query) ||
                              pengirim.contains(query);

                          final matchesDate = _filterDate == null ||
                              DateUtils.isSameDay(broadcast.tanggal, _filterDate);

                          return matchesSearch && matchesDate;
                        }).toList();

                        if (filteredBroadcasts.isEmpty) {
                          return const Center(child: Text("Tidak ada hasil pencarian."));
                        }

                        return RefreshIndicator(
                          onRefresh: _fetchData,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filteredBroadcasts.length,
                            itemBuilder: (context, index) {
                              final broadcast = filteredBroadcasts[index];
                              return _buildBroadcastCard(broadcast);
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_broadcast_fab'),
        onPressed: _navigateToAddBroadcast,
        backgroundColor: ConstantColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
