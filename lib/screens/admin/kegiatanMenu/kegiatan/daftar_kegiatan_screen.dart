import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:SapaWarga_kel_2/constants/constant_colors.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/kegiatan_model.dart';
import 'package:SapaWarga_kel_2/services/kegiatan_service.dart';

import 'kegiatan_filter_screen.dart';

class DaftarKegiatanScreen extends StatefulWidget {
  const DaftarKegiatanScreen({super.key});

  @override
  State<DaftarKegiatanScreen> createState() => _DaftarKegiatanScreenState();
}

class _DaftarKegiatanScreenState extends State<DaftarKegiatanScreen> {
  final TextEditingController _searchController = TextEditingController();
  final KegiatanService _kegiatanService = KegiatanService();
  final DateFormat logDateFormat = DateFormat('dd/MM/yyyy');

  late Stream<List<KegiatanModel>> _kegiatanStream;
  String _searchQuery = '';
  DateTime? _filterDate;
  String? _filterKategori;

  bool get _isFilterActive =>
      _filterDate != null ||
      (_filterKategori != null && _filterKategori != 'Semua Kategori');

  @override
  void initState() {
    super.initState();
    _kegiatanStream = _kegiatanService.getKegiatanStream();
  }

  void _refreshData(){
    setState((){
      _kegiatanStream = _kegiatanService.getKegiatanStream();
    });
  }

  List<KegiatanModel> _filterKegiatan(List<KegiatanModel> allKegiatan) {
    Iterable<KegiatanModel> result = allKegiatan;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((kegiatan) {
        final judul = kegiatan.judul.toLowerCase();
        final pj = kegiatan.pj.toLowerCase();
        return judul.contains(query) || pj.contains(query);
      });
    }

    if (_filterDate != null) {
      result = result.where((kegiatan) {
        return DateUtils.isSameDay(kegiatan.tanggal, _filterDate);
      });
    }

    if (_filterKategori != null && _filterKategori != 'Semua Kategori') {
      result = result.where((kegiatan) =>
          kegiatan.kategori.toLowerCase() == _filterKategori?.toLowerCase());
    }

    return result.toList();
  }

  void _showFilterModal(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>( 
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            ),
            child: KegiatanFilterScreen(
              initialDate: _filterDate,
              initialKategori: _filterKategori,
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _filterDate = result['date'] as DateTime?;
        _filterKategori = result['kategori'] as String?;
      });
    }
  }

  void _navigateToAddKegiatan(BuildContext context) async {
    final result = await context.push<bool>('/admin/kegiatan/tambah');
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
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Cari Berdasarkan Judul/PJ...',
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

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Kegiatan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<List<KegiatanModel>>(
              stream: _kegiatanStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        'Error: ${snapshot.error}\nSilakan coba lagi nanti.'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note,
                            size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          "Belum ada kegiatan yang ditambahkan.",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                final filteredList = _filterKegiatan(snapshot.data!);

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          "Tidak ada kegiatan yang cocok dengan filter.",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 90),
                  itemCount: filteredList.length,
                  itemBuilder: (_, index) {
                    final kegiatan = filteredList[index];
                    return GestureDetector(
                      onTap: () async {
                        final result = await context.push<String>(
                          '/admin/kegiatan/detail',
                          extra: kegiatan,
                        );
                        if (result == 'refresh') {
                          _refreshData();
                        }
                      },
                      child: KegiatanCard(kegiatan: kegiatan),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_kegiatan_fab'),
        onPressed: () => _navigateToAddKegiatan(context),
        backgroundColor: ConstantColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

class KegiatanCard extends StatelessWidget {
  final KegiatanModel kegiatan;
  const KegiatanCard({super.key, required this.kegiatan});

  @override
  Widget build(BuildContext context) {
    const categoryColor = Color(0xFF5E65C0);
    final DateFormat cardDateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kegiatan.judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Penanggung Jawab : ${kegiatan.pj}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Tanggal Pelaksanaan : ${cardDateFormat.format(kegiatan.tanggal)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      kegiatan.kategori,
                      style: const TextStyle(
                        color: categoryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
