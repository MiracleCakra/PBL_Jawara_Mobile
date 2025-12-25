import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:SapaWarga_kel_2/models/log/activity_log_model.dart';
import 'package:SapaWarga_kel_2/screens/admin/kegiatanMenu/logaktivitas/log_filter_screen.dart';
import 'package:SapaWarga_kel_2/services/activity_log_service.dart';

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
          key: const Key('log_back_button'),
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
  final ActivityLogService _logService = ActivityLogService();
  String _searchText = '';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  bool isFilterActive = false;

  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  final DateFormat logDateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

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
              height: MediaQuery.of(context).size.height * 0.6, // Adjust height as needed
              child: LogFilterScreen(
                initialStartDate: _filterStartDate,
                initialEndDate: _filterEndDate,
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _filterStartDate = result['startDate'] as DateTime?;
        _filterEndDate = result['endDate'] as DateTime?;
        isFilterActive = _filterStartDate != null || _filterEndDate != null;
      });
    }
  }

  Widget _buildLogItem(ActivityLogModel log) {
    return Container(
      key: log.id != null ? Key('log_item_${log.id}') : null,
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
          Text("Tanggal : ${logDateFormat.format(log.tanggal)}",
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Text(
              log.type,
              style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
            ),
          ),
        ],
      ),
    );
  }

  List<ActivityLogModel> _applyFilters(List<ActivityLogModel> logs) {
    return logs.where((log) {
      final query = _searchText.toLowerCase();
      final matchesSearch =
          _searchText.isEmpty ||
          log.judul.toLowerCase().contains(query) ||
          log.user.toLowerCase().contains(query);

      final logDate = log.tanggal;
      bool matchesDate = true;

      if (_filterStartDate != null) {
        // Normalize to start of day
        final start = DateTime(_filterStartDate!.year, _filterStartDate!.month, _filterStartDate!.day);
        matchesDate = matchesDate && (logDate.isAtSameMomentAs(start) || logDate.isAfter(start));
      }

      if (_filterEndDate != null) {
        // Normalize to end of day
        final end = DateTime(_filterEndDate!.year, _filterEndDate!.month, _filterEndDate!.day, 23, 59, 59);
        matchesDate = matchesDate && (logDate.isBefore(end));
      }

      return matchesSearch && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                    key: const Key('log_search_field'),
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
                  key: const Key('log_filter_button'),
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
                    ),
                    child: Icon(
                      isFilterActive ? Icons.filter_alt_off : Icons.tune,
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
          child: StreamBuilder<List<ActivityLogModel>>(
            stream: _logService.getLogsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text(
                  "Tidak ada aktivitas yang tercatat.",
                  key: Key('log_empty_state_text'),
                ));
              }

              final filteredLogs = _applyFilters(snapshot.data!);

              if (filteredLogs.isEmpty) {
                return const Center(
                    child: Text(
                  "Data tidak ditemukan.",
                  key: Key('log_no_data_found_text'),
                ));
              }

              return ListView.builder(
                key: const Key('log_list_view'),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: filteredLogs.length,
                itemBuilder: (context, index) =>
                    _buildLogItem(filteredLogs[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
