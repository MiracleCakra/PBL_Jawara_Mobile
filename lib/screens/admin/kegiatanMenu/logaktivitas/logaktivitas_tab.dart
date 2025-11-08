import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'log_filter_screen.dart';

class LogAktivitas {
  final String judul;
  final String user;
  final String tanggal;
  final String type;
  LogAktivitas({
    required this.judul,
    required this.user,
    required this.tanggal,
    required this.type,
  });
}

final List<LogAktivitas> allLogs = [
  LogAktivitas(judul: 'Menghapus data rumah dengan alamat: Jl. Merpati', user: 'Admin Jawara', tanggal: '13 Oktober 2025', type: 'Hapus'),
  LogAktivitas(judul: 'Mengedit data penduduk: Ahmad Dani', user: 'Admin Jawara', tanggal: '13 Oktober 2025', type: 'Edit'),
  LogAktivitas(judul: 'Menambahkan data penduduk baru: Budi Santoso', user: 'Pak RT', tanggal: '13 Oktober 2025', type: 'Tambah'),
  LogAktivitas(judul: 'Mengedit status iuran rumah: Jl. Mawar No. 5', user: 'Bendahara', tanggal: '14 Oktober 2025', type: 'Edit'),
  LogAktivitas(judul: 'Memposting pengumuman: Kerjabakti Minggu Ini', user: 'Admin Jawara', tanggal: '15 Oktober 2025', type: 'Tambah'),
  LogAktivitas(judul: 'Data Keuangan berhasil di-backup ke cloud', user: 'Admin Jawara', tanggal: '16 Oktober 2025', type: 'Lainnya'),
];

class LogAktivitasScreen extends StatelessWidget {
  const LogAktivitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, 
        backgroundColor: Colors.white, 
        centerTitle: false, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black), 
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Log Aktivitas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20, 
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
      ),
      
      body: const LogAktivitasContent(), 
    );
  }
}

class LogAktivitasContent extends StatefulWidget {
  const LogAktivitasContent({super.key});

  @override
  State<LogAktivitasContent> createState() => _LogAktivitasContentState();
}

class _LogAktivitasContentState extends State<LogAktivitasContent> {
  String _searchText = '';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  final DateFormat logDateFormat = DateFormat(
    'dd MMMM yyyy',
    'id_ID', 
  );

  // Filter Judul/User DAN Rentang Tanggal
  List<LogAktivitas> get _filteredLogs {
    Iterable<LogAktivitas> result = allLogs;
    final query = _searchText.toLowerCase();
    if (_searchText.isNotEmpty) {
      result = result.where((log) {
        final judul = log.judul.toLowerCase();
        final user = log.user.toLowerCase();
        return judul.contains(query) || user.contains(query);
      });
    }

    // Filter Tanggal (Start Date)
    if (_filterStartDate != null) {
      final filterStart = DateTime(_filterStartDate!.year, _filterStartDate!.month, _filterStartDate!.day);
      result = result.where((log) {
        try {
          final logDateWithTime = logDateFormat.parse(log.tanggal);
          final logDate = DateTime(logDateWithTime.year, logDateWithTime.month, logDateWithTime.day);
          return logDate.isAtSameMomentAs(filterStart) || logDate.isAfter(filterStart);
        } catch (e) { return false; }
      });
    }

    // Filter Tanggal (End Date)
    if (_filterEndDate != null) {
      final adjustedEndDate = DateTime(_filterEndDate!.year, _filterEndDate!.month, _filterEndDate!.day).add(const Duration(days: 1));
      result = result.where((log) {
        try {
          final logDateWithTime = logDateFormat.parse(log.tanggal);
          final logDate = DateTime(logDateWithTime.year, logDateWithTime.month, logDateWithTime.day);
          return logDate.isBefore(adjustedEndDate);
        } catch (e) { return false; }
      });
    }

    return result.toList();
  }

  // Nav Modal Bottom Sheet
  void _showFilterModal(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext modalContext) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: LogFilterScreen(
            initialStartDate: _filterStartDate,
            initialEndDate: _filterEndDate,
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _filterStartDate = result['startDate'] as DateTime?;
        _filterEndDate = result['endDate'] as DateTime?;
      });
    }
  }

  // Widget Item Log
  Widget _buildLogItem(LogAktivitas log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [ 
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2), 
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Log
          Text(
            log.judul,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Detail User dan Tanggal
          Text(
            log.user, 
            style: TextStyle(fontSize: 14.0, color: Colors.grey.shade700),
          ),
          Text(
            'Tanggal : ${log.tanggal}', 
            style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredLogs;
    final iconColor = Colors.grey.shade700;

    return Column(
      children: [
        // Header Cari dan Filter
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
          child: Row(
            children: [
              // Search Bar
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search Name', 
                      prefixIcon: Icon(Icons.search, color: iconColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white, 
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      isDense: true,
                      // Penyesuaian shadow/elevation pada TextField
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Filter Button (Icon)
             Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: IconButton(
                  icon: Icon(Icons.tune, color: iconColor, size: 24), // <- GANTI DI SINI
                  onPressed: () => _showFilterModal(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),

        // Daftar Log
        Expanded(
          child: filteredList.isEmpty
              ? const Center(child: Text("Tidak ada aktivitas yang tercatat."))
              : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final log = filteredList[index];
                      return _buildLogItem(log);
                    },
                  ),
        ),
      ],
    );
  }
}