import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/kegiatanwarga/detailkegiatan.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/kegiatanwarga/filter_kegiatan_warga.dart';


class DaftarKegiatanWargaScreen extends StatefulWidget {
  const DaftarKegiatanWargaScreen({super.key});

  @override
  State<DaftarKegiatanWargaScreen> createState() => _DaftarKegiatanWargaScreenState();
}

class _DaftarKegiatanWargaScreenState extends State<DaftarKegiatanWargaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DateFormat logDateFormat = DateFormat('dd/MM/yyyy');

  String _searchQuery = '';
  DateTime? _filterDate;
  String? _filterKategori;

  bool get _isFilterActive => _filterDate != null || (_filterKategori != null && _filterKategori != 'Semua Kategori');


  final List<Map<String, String>> _kegiatanList = [
    {
      'judul': 'Kerja Bakti Lingkungan',
      'pj': 'Pak Habibi',
      'tanggal': '12/10/2025',
      'kategori': 'Sosial',
      'lokasi': 'Balai Warga RW 01',
      'deskripsi':
          'Kerja bakti membersihkan lingkungan dari sampah dan selokan untuk menjaga kebersihan dan keamanan lingkungan.',
      'dibuat_oleh': 'Admin Jawara',
      'has_docs': 'true',
    },
    {
      'judul': 'Pelatihan Keterampilan Digital',
      'pj': 'Karang Taruna',
      'tanggal': '25/10/2025',
      'kategori': 'Pendidikan',
      'lokasi': 'Aula Kecamatan',
      'deskripsi':
          'Pelatihan dasar desain grafis dan coding untuk remaja yang tertarik pada teknologi.',
      'dibuat_oleh': 'Admin Jawara',
      'has_docs': 'true',
    },
    {
      'judul': 'Senam Pagi',
      'pj': 'Puskesmas Keliling',
      'tanggal': '15/10/2025',
      'kategori': 'Kesehatan & Olahraga',
      'lokasi': 'Lapangan Bola',
      'deskripsi':
          'Senam rutin untuk meningkatkan kebugaran warga dan mempererat tali silaturahmi.',
      'dibuat_oleh': 'Admin Jawara',
      'has_docs': 'false',
    },
  ];
  List<Map<String, String>> _filterKegiatan() {
    Iterable<Map<String, String>> result = _kegiatanList;

    // Filter Pencarian Judul / PJ
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((kegiatan) {
        final judul = kegiatan['judul']?.toLowerCase() ?? '';
        final pj = kegiatan['pj']?.toLowerCase() ?? '';
        return judul.contains(query) || pj.contains(query);
      });
    }

    if (_filterDate != null) {
      result = result.where((kegiatan) {
        try {
          final kegiatanDate = logDateFormat.parse(kegiatan['tanggal']!);
          return kegiatanDate.isAtSameMomentAs(_filterDate!);
        } catch (_) {
          return false;
        }
      });
    }

    if (_filterKategori != null && _filterKategori != 'Semua Kategori') {
      result = result.where((kegiatan) =>
          kegiatan['kategori']?.toLowerCase() ==
          _filterKategori?.toLowerCase());
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
                    borderSide: const BorderSide(color: Color(0xFF4E46B4), width: 1.5),
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
    final filteredList = _filterKegiatan();
    //const primaryColor = Colors.deepPurple;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
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
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_note,
                            size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          _searchQuery.isNotEmpty ||
                                  _filterDate != null ||
                                  _filterKategori != null
                              ? "Tidak ada kegiatan yang cocok dengan filter."
                              : "Belum ada kegiatan yang ditambahkan.",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: filteredList.length,
                    itemBuilder: (_, index) {
                      final kegiatan = filteredList[index];
                      return GestureDetector(
                        onTap: () async {
                          final result = await context.pushNamed<String>(
                            'WargaKegiatanDetail',
                            extra: kegiatan,
                          );
                          if (result == 'deleted') {
                            setState(() {
                              _kegiatanList.removeWhere(
                                (item) => item['judul'] == kegiatan['judul'],
                              );
                            });
                          }
                        },
                        child: KegiatanCard(kegiatan: kegiatan),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
class KegiatanCard extends StatelessWidget {
  final Map<String, String> kegiatan;

  const KegiatanCard({super.key, required this.kegiatan});

  @override
  Widget build(BuildContext context) {
    const categoryColor = Color(0xFF5E65C0);

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
                    kegiatan['judul']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Penanggung Jawab : ${kegiatan['pj']}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Tanggal Pelaksanaan : ${kegiatan['tanggal']}',
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
                      kegiatan['kategori']!,
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
          ],
        ),
      ),
    );
  }
}