import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/broadcashwarga/detailBroadcash.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/broadcashwarga/filter_broadcashwarga.dart';
import 'package:jawara_pintar_kel_5/models/broadcah_model.dart';

/*class KegiatanBroadcastWarga {
  final String judul;
  final String pengirim;
  final String tanggal;
  final String kategori;
  final String konten;
  final String? lampiranGambarUrl;
  final List<String> lampiranDokumen;

  KegiatanBroadcastWarga({
    required this.judul,
    required this.pengirim,
    required this.tanggal,
    required this.konten,
    this.kategori = "Pemberitahuan",
    this.lampiranGambarUrl,
    this.lampiranDokumen = const [],
  });
}

List<KegiatanBroadcastWarga> dummyData = [
  KegiatanBroadcastWarga(
    judul: "Pemberitahuan Kerja Bakti",
    pengirim: "Ketua RT",
    tanggal: "12/10/2025",
    konten:
        "PENGUMUMAN — Kepada seluruh warga RT 03/RW 07, besok Minggu pukul 07.00 akan diadakan kerja bakti membersihkan selokan dan lingkungan sekitar. Diharapkan semua warga ikut berpartisipasi. Terima kasih",
    lampiranGambarUrl: 'assets/images/images.png',
    lampiranDokumen: ["file_panduan.pdf", "file_absensi.pdf"],
  ),
  KegiatanBroadcastWarga(
    judul: "Pengumuman Lomba Kebersihan",
    pengirim: "Sekretaris RW",
    tanggal: "23/10/2025",
    kategori: "Pengumuman",
    konten:
        "Lomba Kebersihan Lingkungan akan dimulai minggu depan. Mohon partisipasi seluruh warga agar lingkungan tetap bersih dan asri.",
    lampiranGambarUrl: null,
    lampiranDokumen: ["Panduan_Lomba.pdf"],
  ),
  KegiatanBroadcastWarga(
    judul: "Himbauan Pembayaran Iuran",
    pengirim: "Bendahara RT",
    tanggal: "15/10/2025",
    kategori: "Keuangan",
    konten:
        "Dimohon segera melunasi iuran bulanan sebelum tanggal 20. Bagi yang belum membayar, harap segera menghubungi Bendahara RT.",
    lampiranGambarUrl: null,
    lampiranDokumen: ["laporan_keuangan.pdf"],
  ),
  KegiatanBroadcastWarga(
    judul: "Undangan Rapat Program",
    pengirim: "Sekretaris RW",
    tanggal: "20/10/2025",
    kategori: "Pemberitahuan",
    konten:
        "Rapat Program Kerja akan diadakan pada hari Rabu di Balai Warga. Kehadiran para ketua RT/RW sangat diharapkan.",
    lampiranGambarUrl: null,
    lampiranDokumen: ["Undangan_Rapat.pdf"],
  ),
];*/

class DaftarBroadcastWargaScreen extends StatefulWidget {
  const DaftarBroadcastWargaScreen({super.key});

  @override
  State<DaftarBroadcastWargaScreen> createState() =>
      _DaftarBroadcastWargaScreenState();
}

class _DaftarBroadcastWargaScreenState
    extends State<DaftarBroadcastWargaScreen> {
  String _searchQuery = '';
  DateTime? _filterDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final TextEditingController _searchController = TextEditingController();

  bool get _isFilterActive => _filterDate != null;

  List<KegiatanBroadcastWarga> _filterBroadcast() {
    Iterable<KegiatanBroadcastWarga> result = dummyData;
    final query = _searchQuery.toLowerCase();

    if (_searchQuery.isNotEmpty) {
      result = result.where((broadcast) {
        final judul = broadcast.judul.toLowerCase();
        final pengirim = broadcast.pengirim.toLowerCase();
        return judul.contains(query) || pengirim.contains(query);
      });
    }

    if (_filterDate != null) {
      result = result.where((broadcast) {
        try {
          final broadcastDate = _dateFormat.parse(broadcast.tanggal);
          return broadcastDate.isAtSameMomentAs(_filterDate!);
        } catch (e) {
          return false;
        }
      });
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

  void _navigateToDetail(BuildContext context, KegiatanBroadcastWarga data) {
    context.pushNamed('WargaBroadcastDetail', extra: data);
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
                  hintText:
                      'Cari Berdasarkan Judul/Pengirim...', 
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
                    ), // Warna fokus
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

  //
  Widget _buildBroadcastCard(KegiatanBroadcastWarga kegiatan) {
    final Color detailColor = Colors.grey.shade700;

    return GestureDetector(
      onTap: () => _navigateToDetail(context, kegiatan),
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
                        kegiatan.judul,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            kegiatan.pengirim,
                            style: TextStyle(fontSize: 14, color: detailColor),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "Tanggal : ${kegiatan.tanggal}",
                            style: TextStyle(fontSize: 14, color: detailColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kegiatan.konten.length > 80
                            ? "${kegiatan.konten.substring(0, 80)}..."
                            : kegiatan.konten,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filterBroadcast();
    // const primaryColor = Colors.deepPurple;

    return Scaffold(
      backgroundColor: Colors
          .grey[50], 
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
            child: filteredList.isEmpty
                ? const Center(
                    child: Text("Tidak ada Broadcast yang ditemukan."),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final kegiatan = filteredList[index];
                      return _buildBroadcastCard(kegiatan);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
