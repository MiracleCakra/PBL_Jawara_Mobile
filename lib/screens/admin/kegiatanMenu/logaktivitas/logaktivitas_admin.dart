import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'log_filter_screen.dart';
import 'dart:async';
import 'package:jawara_pintar_kel_5/models/logaktivitas_model.dart';

final List<LogAktivitas> allLogs = [
  LogAktivitas(judul: 'Menghapus data rumah dengan alamat: Jl. Merpati', user: 'Admin Jawara', tanggal: '13 Oktober 2025', type: 'Hapus'),
  LogAktivitas(judul: 'Mengedit data penduduk: Ahmad Dani', user: 'Admin Jawara', tanggal: '13 Oktober 2025', type: 'Edit'),
  LogAktivitas(judul: 'Menambahkan data penduduk baru: Budi Santoso', user: 'Pak RT', tanggal: '13 Oktober 2025', type: 'Tambah'),
  LogAktivitas(judul: 'Mengedit status iuran rumah: Jl. Mawar No. 5', user: 'Bendahara', tanggal: '14 Oktober 2025', type: 'Edit'),
  LogAktivitas(judul: 'Memposting pengumuman: Kerjabakti Minggu Ini', user: 'Admin Jawara', tanggal: '15 Oktober 2025', type: 'Tambah'),
  LogAktivitas(judul: 'Data Keuangan berhasil di-backup ke cloud', user: 'Admin Jawara', tanggal: '16 Oktober 2025', type: 'Lainnya'),
];

class LogAktivitasScreenAdmin extends StatelessWidget {
  const LogAktivitasScreenAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
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

  bool isFilterActive = false;

  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  final DateFormat logDateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  List<LogAktivitas> get _filteredLogs {
    Iterable<LogAktivitas> result = allLogs;

    final query = _searchText.toLowerCase();
    if (_searchText.isNotEmpty) {
      result = result.where((log) {
        return log.judul.toLowerCase().contains(query) ||
            log.user.toLowerCase().contains(query);
      });
    }

    if (_filterStartDate != null) {
      result = result.where((log) {
        final logDate = logDateFormat.parse(log.tanggal);
        return logDate.isAtSameMomentAs(_filterStartDate!) ||
            logDate.isAfter(_filterStartDate!);
      });
    }

    if (_filterEndDate != null) {
      final end = _filterEndDate!.add(const Duration(days: 1));
      result = result.where((log) {
        final logDate = logDateFormat.parse(log.tanggal);
        return logDate.isBefore(end);
      });
    }

    return result.toList();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      setState(() {
        _searchText = query;
      });
    });
  }

  void _showFilterModal(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
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
        isFilterActive =
            _filterStartDate != null || _filterEndDate != null;
      });
    }
  }

  Widget _buildLogItem(LogAktivitas log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            log.judul,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(log.user,
              style:
                  TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          Text("Tanggal : ${log.tanggal}",
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredLogs;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      
                      hintText: 'Cari Berdasarkan Nama Aktivitas atau Pengguna...',
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
                            BorderSide(color: Colors.grey.shade300, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1.0),
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
                color: isFilterActive ? Colors.grey.shade200 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      isFilterActive = true;
                    });
                    _showFilterModal(context);
                  },
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
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredList.isEmpty
              ? const Center(
                  child: Text("Tidak ada aktivitas yang tercatat."))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) =>
                      _buildLogItem(filteredList[index]),
                ),
        ),
      ],
    );
  }
}
