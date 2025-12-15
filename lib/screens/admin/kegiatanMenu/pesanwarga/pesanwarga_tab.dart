import 'package:flutter/material.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/aspirasi_model.dart';
import 'package:SapaWarga_kel_2/services/aspirasi_service.dart';
import 'detail_pesan_warga_screen.dart';
import 'package:SapaWarga_kel_2/utils.dart' show getPrimaryColor;


class PesanWargaScreen extends StatefulWidget {
  const PesanWargaScreen({super.key});

  @override
  State<PesanWargaScreen> createState() => _PesanWargaScreenState();
}

class _PesanWargaScreenState extends State<PesanWargaScreen> {
  String? _selectedStatus;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  final AspirasiService _aspirasiService = AspirasiService();
  
  List<AspirasiModel> _allPesan = [];
  bool _isLoading = true;

  bool get _isFilterActive =>
      _selectedStatus != null && _selectedStatus!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _aspirasiService.getAspirations().first;
      if (mounted) {
        setState(() {
          _allPesan = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _refreshData() {
    _fetchData();
  }

  List<AspirasiModel> _filterPesan(List<AspirasiModel> allPesan) {
    Iterable<AspirasiModel> result = allPesan;

    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      result = result.where((pesan) => pesan.status == _selectedStatus);
    }

    if (_searchText.isNotEmpty) {
      final query = _searchText.toLowerCase();

      result = result.where(
        (pesan) =>
            pesan.pengirim.toLowerCase().contains(query) ||
            pesan.judul.toLowerCase().contains(query),
      );
    }

    return result.toList();
  }

  Widget _buildStatusChip(String status) {
    Color color;
    Color textColor;

    switch (status) {
      case 'Pending':
        color = Colors.yellow.shade800;
        break;
      case 'Diterima':
        color = Colors.green.shade700;
        break;
      case 'Ditolak':
        color = Colors.red.shade700;
        break;
      default:
        color = Colors.grey;
    }
    textColor = color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPesanCard(AspirasiModel pesan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPesanWargaScreen(pesan: pesan),
            ),
          );
          if (result == true) {
            _refreshData();
          }
        },
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pesan.judul,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pesan.pengirim,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        'Tanggal dibuat: ${pesan.tanggal}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusChip(pesan.status),
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

  Widget _buildFilterBar() {
    final statusList = ['Pending', 'Diterima', 'Ditolak'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchText = value),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Cari Judul/Pengirim...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 24,
                    color: Colors.grey.shade500,
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 45, minHeight: 45),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 16),
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
                    borderSide:
                        const BorderSide(color: Color(0xFF4E46B4), width: 1.5),
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
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                String tempStatus = _selectedStatus ?? 'Semua';
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
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
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Status Pesan Warga',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Status',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    key: const Key(
                                      'dropdown_filter_status_pesan',
                                    ),
                                    value:
                                        tempStatus == 'Semua' ? null : tempStatus,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
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
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Text('Semua'),
                                      ),
                                      ...statusList.map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      ),
                                    ],
                                    onChanged: (v) =>
                                        setModalState(() => tempStatus = v ?? 'Semua'),
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
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _selectedStatus = null;
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
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _selectedStatus =
                                                  tempStatus == 'Semua'
                                                      ? null
                                                      : tempStatus;
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
              },
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),

          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'Pesan Warga',

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
                : Builder(builder: (context) {
                    final filteredList = _filterPesan(_allPesan);
                    if (filteredList.isEmpty) {
                      return const Center(
                        child: Text("Tidak ada pesan yang ditemukan."),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _fetchData,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) =>
                            _buildPesanCard(filteredList[index]),
                      ),
                    );
                  }),
          ),
        ],
      ),
    );
  }
}
