import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PesanWarga {
  final String id;
  final String judul;
  final String tanggalDibuat;
  final String status;
  final String deskripsi; 

  PesanWarga({
    required this.id,
    required this.judul,
    required this.tanggalDibuat,
    required this.status,
    required this.deskripsi,
  });
}

class WargaPesanSayaScreen extends StatefulWidget {
  const WargaPesanSayaScreen({super.key});

  @override
  State<WargaPesanSayaScreen> createState() => _WargaPesanSayaScreenState();
}

class _WargaPesanSayaScreenState extends State<WargaPesanSayaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStatus;
  
  static const Color _primaryColor = Color(0xFF6366F1);

  final List<PesanWarga> _allPesan = [
    PesanWarga(id: 'p001', judul: 'Lampu Jalan Mati', tanggalDibuat: '25 November 2025', status: 'Pending', deskripsi: 'Lampu penerangan di depan Gang 3 mati total sejak kemarin malam.'),
    PesanWarga(id: 'p002', judul: 'Sampah Menumpuk', tanggalDibuat: '20 November 2025', status: 'Diterima', deskripsi: 'Tumpukan sampah di depan pos kamling belum diangkut selama 3 hari.'),
    PesanWarga(id: 'p003', judul: 'Usulan Lomba 17an', tanggalDibuat: '15 November 2025', status: 'Diterima', deskripsi: 'Saya mengusulkan agar tahun ini diadakan lomba makan kerupuk level pedas dan lomba balap karung pakai helm.'),
  ];

  List<PesanWarga> get _filteredPesan {
    Iterable<PesanWarga> result = _allPesan;
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      result = result.where((pesan) => pesan.status == _selectedStatus);
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((pesan) => pesan.judul.toLowerCase().contains(query));
    }
    return result.toList();
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Pending': color = Colors.orange; break;
      case 'Diterima': color = Colors.deepPurple; break;
      case 'Ditolak': color = Colors.red.shade700; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFilterBar() {
    final statusList = ['Pending', 'Diterima', 'Ditolak'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: SizedBox(
              height: 50,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Cari Judul...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedStatus,
                  isExpanded: true,
                  hint: const Text('Status', style: TextStyle(fontSize: 14)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Semua')),
                    ...statusList.map((s) => DropdownMenuItem(value: s, child: Text(s))),
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

  Widget _buildPesanCard(PesanWarga pesan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.pushNamed(
              'warga_kirimanDetail', 
              extra: {
                'judul': pesan.judul,
                'deskripsi': pesan.deskripsi,
                'status': pesan.status,
                'pengirim': 'Saya (Anda)',
                'tanggal': pesan.tanggalDibuat,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pesan.judul,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusChip(pesan.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(pesan.tanggalDibuat, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                  ],
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
    final filteredList = _filteredPesan;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Riwayat Kiriman Saya', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("Belum ada riwayat kiriman."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final pesan = filteredList[index];
                      return _buildPesanCard(pesan);
                    },
                  ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAspirasi = await context.pushNamed('warga_aspirasiForm');

          if (newAspirasi != null && newAspirasi is Map<String, dynamic>) {
            final newPesan = PesanWarga(
              id: newAspirasi['id'],
              judul: newAspirasi['judul'],
              tanggalDibuat: newAspirasi['tanggal'],
              status: newAspirasi['status'],
              deskripsi: newAspirasi['deskripsi'],
            );

            setState(() {
              _allPesan.insert(0, newPesan); 
            });
        
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pesan baru berhasil ditambahkan ke riwayat!'))
            );
          }
        },
        backgroundColor: _primaryColor, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}