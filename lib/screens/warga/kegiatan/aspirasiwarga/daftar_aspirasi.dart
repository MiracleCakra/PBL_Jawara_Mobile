import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class WargaDaftarAspirasiScreen extends StatefulWidget {
  const WargaDaftarAspirasiScreen({super.key});

  @override
  State<WargaDaftarAspirasiScreen> createState() => _WargaDaftarAspirasiScreenState();
}

class _WargaDaftarAspirasiScreenState extends State<WargaDaftarAspirasiScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  final List<Map<String, dynamic>> _aspirasiList = [
    {
      'id': '1',
      'pengirim': 'Budi Santoso (Blok A1)',
      'judul': 'Lampu Jalan Mati',
      'tanggal': DateTime.now().subtract(const Duration(days: 1)),
      'isi': 'Lampu di gang 3 mati total mohon diperbaiki.',
      'status': 'Diterima',
    },
    {
      'id': '2',
      'pengirim': 'Siti Aminah (Blok B5)',
      'judul': 'Sampah Menumpuk',
      'tanggal': DateTime.now().subtract(const Duration(days: 3)),
      'isi': 'Sampah di depan pos kamling sudah 3 hari tidak diangkut.',
      'status': 'Diterima',
    },
    {
      'id': '3',
      'pengirim': 'Ahmad Dhani (Blok C2)',
      'judul': 'Usulan Lomba 17an',
      'tanggal': DateTime.now().subtract(const Duration(days: 5)),
      'isi': 'Saya mengusulkan lomba makan kerupuk level pedas hehe.',
      'status': 'Pending',
    },
  ];

  List<Map<String, dynamic>> _filterAspirasi() {
  final accepted = _aspirasiList.where((item) {
    final status = item['status']?.toString().toLowerCase() ?? '';
    return status == 'approved' || status == 'selesai' || status == 'diterima';
  }).toList();

  if (_searchQuery.isEmpty) return accepted;

  final query = _searchQuery.toLowerCase();

  return accepted.where((item) {
    final judul = item['judul'].toString().toLowerCase();
    return judul.contains(query);
  }).toList();
}

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SizedBox(
        height: 50,
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Cari judul aspirasi...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(
              Icons.search,
              size: 24,
              color: Colors.grey.shade500,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            ),
          ),
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filterAspirasi();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Daftar Aspirasi Warga',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),

          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          "Tidak ada aspirasi ditemukan.",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20, top: 8),
                    itemCount: filteredList.length,
                    itemBuilder: (_, index) {
                      final item = filteredList[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman detail
                          context.pushNamed('warga_aspirasiDetail', extra: item);
                        },
                        child: AspirasiCard(data: item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class AspirasiCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const AspirasiCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String dateStr = DateFormat('dd MMM yyyy').format(data['tanggal']);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pengirim
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.person, size: 12, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['pengirim'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Judul
            Text(
              data['judul'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),

            // Tanggal & Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
