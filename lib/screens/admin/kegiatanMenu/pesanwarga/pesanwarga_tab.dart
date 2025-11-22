import 'package:flutter/material.dart';
import 'detail_pesan_warga_screen.dart';

class PesanWarga {
  final String judul;
  final String pengirim;
  final String tanggalDibuat;
  final String id;
  String status;

  PesanWarga({
    required this.id,
    required this.judul,
    required this.pengirim,
    required this.tanggalDibuat,
    required this.status,
  });
}

List<PesanWarga> allPesan = [
  PesanWarga(
    id: 'p001',
    judul: 'Laporan Kebocoran Pipa',
    pengirim: 'Bu Kartini',
    tanggalDibuat: '15/10/2025',
    status: 'Pending',
  ),
  PesanWarga(
    id: 'p002',
    judul: 'Pengaduan Parkir Liar',
    pengirim: 'Pak Budi',
    tanggalDibuat: '14/10/2025',
    status: 'Diterima',
  ),
  PesanWarga(
    id: 'p003',
    judul: 'Permintaan Lampu Jalan',
    pengirim: 'Bpk. Ahmad',
    tanggalDibuat: '13/10/2025',
    status: 'Ditolak',
  ),
  PesanWarga(
    id: 'p004',
    judul: 'Perbaikan Jalan Raya',
    pengirim: 'Bpk. Mamat',
    tanggalDibuat: '16/10/2025',
    status: 'Pending',
  ),
  PesanWarga(
    id: 'p005',
    judul: 'Pembuatan Pos Ronda',
    pengirim: 'Ibu Rina',
    tanggalDibuat: '17/10/25',
    status: 'Diterima',
  ),
];

class PesanWargaScreen extends StatefulWidget {
  const PesanWargaScreen({super.key});

  @override
  State<PesanWargaScreen> createState() => _PesanWargaScreenState();
}

class _PesanWargaScreenState extends State<PesanWargaScreen> {
  String? _selectedStatus;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  bool get _isFilterActive => _selectedStatus != null && _selectedStatus!.isNotEmpty;

  List<PesanWarga> get _filteredPesan {
    Iterable<PesanWarga> result = allPesan;

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
        color = Colors.deepPurple.shade700;
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
    
  Widget _buildPesanCard(PesanWarga pesan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPesanWargaScreen(
                pesan: {
                  'id': pesan.id,
                  'judul': pesan.judul,
                  'status': pesan.status,
                  'pengirim': pesan.pengirim,
                  'tanggalDibuat': pesan.tanggalDibuat,
                  'deskripsi': '...',
                },
              ),
            ),
          );

          if (result != null && result is Map<String, String>) {
            if (result['status'] == 'deleted') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pesan "${result['judul']}" telah dihapus.'),
                  backgroundColor: Colors.grey.shade800,
                  duration: const Duration(seconds: 2),
                ),
              );
              setState(() {
                allPesan.removeWhere((p) => p.judul == result['judul']);
              });
            } else if (result['type'] == 'updated') {
              setState(() {
                final index = allPesan.indexWhere((p) => p.id == result['id']);
                if (index != -1) {
                  allPesan[index].status =
                      result['status'] ?? allPesan[index].status;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Status pesan "${result['judul']}" berhasil diperbarui menjadi ${result['status']}.',
                  ),
                  backgroundColor: Colors.grey.shade800,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
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
                        'Tanggal dibuat: ${pesan.tanggalDibuat}',
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
    const Color focusColor = Color(0xFF4E46B4);

    return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(
      children: [
        // 🔵 SEARCH BAR 60%
        Flexible(
          flex: 6,
          child: SizedBox(
            height: 50,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value),
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
                  borderSide:
                      BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: focusColor, width: 1.5),
                ),
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),

        const SizedBox(width: 8),
        Flexible(
          flex: 4,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _isFilterActive ? Colors.grey.shade200 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _selectedStatus,
                hint: const Text('Semua Status',
                    style: TextStyle(fontSize: 14, color: Colors.black87)),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: _isFilterActive ? Colors.black54 : Colors.black87,
                  size: 24,
                ),
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Semua Status'),
                  ),
                  ...statusList.map(
                    (s) => DropdownMenuItem<String?>(
                      value: s,
                      child: Text(s),
                    ),
                  ),
                ],
                onChanged: (val) => setState(() => _selectedStatus = val),
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
    final List<PesanWarga> filteredList = _filteredPesan;

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
            child: filteredList.isEmpty
                ? Center(child: Text("Tidak ada pesan yang ditemukan."))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) =>
                        _buildPesanCard(filteredList[index]),
                  ),
          ),
        ],
      ),
    );
  }
}