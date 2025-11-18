import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'tambah_broadcast.dart';
import 'edit_broadcast_screen.dart';
import 'detail_broadcast_screen.dart';
import 'broadcast_filter_screen.dart';

class KegiatanBroadcast {
  final String judul;
  final String pengirim;
  final String tanggal;
  final String kategori;
  final String konten;
  final String? lampiranGambarUrl;
  final List<String> lampiranDokumen;

  KegiatanBroadcast({
    required this.judul,
    required this.pengirim,
    required this.tanggal,
    required this.konten,
    this.kategori = "Pemberitahuan",
    this.lampiranGambarUrl,
    this.lampiranDokumen = const [],
  });
}

List<KegiatanBroadcast> dummyData = [
  KegiatanBroadcast(
    judul: "Pemberitahuan Kerja Bakti",
    pengirim: "Ketua RT",
    tanggal: "12/10/2025",
    konten:
        "PENGUMUMAN — Kepada seluruh warga RT 03/RW 07, besok Minggu pukul 07.00 akan diadakan kerja bakti membersihkan selokan dan lingkungan sekitar. Diharapkan semua warga ikut berpartisipasi. Terima kasih",
    lampiranGambarUrl: 'assets/images/kerjabkati.png',
    lampiranDokumen: ["file_panduan.pdf", "file_absensi.pdf"],
  ),
  KegiatanBroadcast(
    judul: "Pengumuman Lomba Kebersihan",
    pengirim: "Sekretaris RW",
    tanggal: "23/10/2025",
    kategori: "Pengumuman",
    konten:
        "Lomba Kebersihan Lingkungan akan dimulai minggu depan. Mohon partisipasi seluruh warga agar lingkungan tetap bersih dan asri.",
    lampiranGambarUrl: null,
    lampiranDokumen: ["Panduan_Lomba.pdf"],
  ),
  KegiatanBroadcast(
    judul: "Himbauan Pembayaran Iuran",
    pengirim: "Bendahara RT",
    tanggal: "15/10/2025",
    kategori: "Keuangan",
    konten:
        "Dimohon segera melunasi iuran bulanan sebelum tanggal 20. Bagi yang belum membayar, harap segera menghubungi Bendahara RT.",
    lampiranGambarUrl: null,
    lampiranDokumen: ["laporan_keuangan.pdf"],
  ),
  KegiatanBroadcast(
    judul: "Undangan Rapat Program",
    pengirim: "Sekretaris RW",
    tanggal: "20/10/2025",
    kategori: "Pemberitahuan",
    konten:
        "Rapat Program Kerja akan diadakan pada hari Rabu di Balai Warga. Kehadiran para ketua RT/RW sangat diharapkan.",
    lampiranGambarUrl: null,
    lampiranDokumen: ["Undangan_Rapat.pdf"],
  ),
];

class DaftarBroadcastScreen extends StatefulWidget {
  const DaftarBroadcastScreen({super.key});

  @override
  State<DaftarBroadcastScreen> createState() => _DaftarBroadcastScreenState();
}

class _DaftarBroadcastScreenState extends State<DaftarBroadcastScreen> {
  String _searchQuery = '';
  DateTime? _filterDate;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final TextEditingController _searchController = TextEditingController();

  // 🔥 Logika untuk menentukan apakah filter sedang aktif
  bool get _isFilterActive => _filterDate != null;

  List<KegiatanBroadcast> _filterBroadcast() {
    Iterable<KegiatanBroadcast> result = dummyData;
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
      // 🔥 Atur background color menjadi transparan di sini jika perlu, tapi fokus pada isi modal
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return Container(
          // 🔥 Bungkus dengan Container untuk styling background dan radius
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                top: 20, bottom: MediaQuery.of(modalContext).viewInsets.bottom),
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

  void _navigateToDetail(BuildContext context, KegiatanBroadcast data) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailBroadcastScreen(broadcastData: data),
      ),
    );
    // Logika pembaruan/penghapusan data di sini jika diperlukan setelah kembali dari detail
    if (result != null && result is Map<String, dynamic>) {
      // Logic untuk menghapus data dummy jika status 'deleted'
      if (result['status'] == 'deleted') {
        setState(() {
          dummyData.removeWhere((item) => item.judul == data.judul);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Broadcast "${data.judul}" telah dihapus.'),
            backgroundColor: Colors.grey.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (result['status'] == 'updated') {
        // Logika memperbarui item di dummyData jika diperlukan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Broadcast "${result['judul']}" berhasil diperbarui.'),
            backgroundColor: Colors.grey.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }


  void _navigateToAddBroadcast() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahBroadcastScreen(),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      final newBroadcast = KegiatanBroadcast(
        judul: result['judul'] ?? 'Broadcast Baru',
        konten: result['isi'] ?? 'Tanpa isi',
        pengirim: 'Admin RT',
        tanggal: _dateFormat.format(DateTime.now()),
        kategori: 'Pemberitahuan',
      );
      setState(() {
        dummyData.insert(0, newBroadcast);
      });
      // Show Snackbar for success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Broadcast baru "${newBroadcast.judul}" berhasil ditambahkan!'),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 🔥 WIDGET BARU UNTUK SEARCHBAR DAN FILTER
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
                  hintText: 'Cari Berdasarkan Judul/Pengirim...', // 🔥 Hint text relevan
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
                    borderSide: const BorderSide(color: Color(0xFF4E46B4), width: 1.5), // Warna fokus
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
  Widget _buildBroadcastCard(KegiatanBroadcast kegiatan) {
    final Color detailColor = Colors.grey.shade700;

    return GestureDetector(
      onTap: () => _navigateToDetail(context, kegiatan),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bagian kiri: isi teks
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
                          const Text(' • ', style: TextStyle(color: Colors.grey)),
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
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
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
    const primaryColor = Colors.deepPurple;

    return Scaffold(
      backgroundColor: Colors.grey[50], // 🔥 Tambahkan background agar searchbar terlihat menonjol
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
          // 🔥 Ganti Padding lama dengan _buildFilterBar()
          _buildFilterBar(),

          // Daftar Card
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddBroadcast,
        backgroundColor: primaryColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}