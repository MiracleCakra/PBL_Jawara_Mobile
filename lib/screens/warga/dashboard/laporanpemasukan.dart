import 'package:flutter/material.dart';
import 'package:SapaWarga_kel_2/models/keuangan/transaksi_model.dart';
import 'package:SapaWarga_kel_2/utils.dart'
    show formatDate, formatRupiah, openDateTimePicker;
import 'package:go_router/go_router.dart';

class SemuaPemasukanWargaScreen extends StatefulWidget {
  final String type = 'Pemasukan';

  const SemuaPemasukanWargaScreen({super.key});

  @override
  State<SemuaPemasukanWargaScreen> createState() =>
      _SemuaPemasukanWargaScreenState();
}

class _SemuaPemasukanWargaScreenState extends State<SemuaPemasukanWargaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _scopes = ['RT 05', 'RW 05'];

  DateTime? _startDate;
  DateTime? _endDate;
  String _currentScope = 'RT 05';
  String _query = '';
  late final TextEditingController _textController;

  List<TransaksiModel> _allTransactions = [];
  List<TransaksiModel> _filteredList = [];

  final Color _primaryColor = const Color(0xFF6366F1); 
  final Color _iconColor = const Color(0xFF8B5CF6);
  final Color _lightBg = const Color(0xFFF3F0FF);
  final Color _nominalColor = const Color(0xFF4ADE80);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _scopes.length, vsync: this);
    _textController = TextEditingController();
    _tabController.addListener(_handleTabChange);

    _allTransactions = TransaksiModel.getSampleData();
    _filterTransactions();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentScope = _scopes[_tabController.index];
        _filterTransactions();
      });
    }
  }

  void _filterTransactions() {
    final q = _query.trim().toLowerCase();
    final filtered = _allTransactions.where((t) {
      if (t.tipeTransaksi != widget.type) return false;
      if (t.scope != _currentScope) return false;
      if (t.status != 'Diterima') return false;
      if (!t.namaSubjek.toLowerCase().contains(q)) return false;

      final dateOnly = DateTime(t.tanggal.year, t.tanggal.month, t.tanggal.day);
      final afterStart = _startDate == null || !dateOnly.isBefore(_startDate!);
      final beforeEnd = _endDate == null || !dateOnly.isAfter(_endDate!);
      return afterStart && beforeEnd;
    }).toList();

    filtered.sort((a, b) => b.tanggal.compareTo(a.tanggal));

    setState(() => _filteredList = filtered);
  }

  double get _totalNominal =>
      _filteredList.fold(0.0, (sum, item) => sum + item.nominal);


  Widget _buildTransactionCard(TransaksiModel item) {
    return InkWell(
      onTap: () => context.push('/warga/dashboard/pemasukan/detailpemasukan',
          extra: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _lightBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_circle_up, color: _iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.namaSubjek,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(item.jenisKategori,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                    Text(formatDate(item.tanggal),
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Text(formatRupiah(item.nominal.toInt()),
                  style: TextStyle(
                      color: _nominalColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _textController,
                onChanged: (v) {
                  setState(() {
                    _query = v;
                    _filterTransactions();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon:
                      Icon(Icons.search, size: 20, color: Colors.grey[600]),
                  hintText: 'Cari nama subjek...',
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: IconButton(
              onPressed: _showDateFilterSheet,
              icon: Icon(Icons.tune, color: Colors.grey.shade600),
              padding: const EdgeInsets.all(10.0), 
            ),
          ),
        ],
      ),
    );
  }

  void _showDateFilterSheet() {
    DateTime? tempStart = _startDate;
    DateTime? tempEnd = _endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate({required bool isStart}) async {
              final res = await openDateTimePicker(context);
              if (res != null) {
                setModalState(() {
                  if (isStart) tempStart = DateTime(res.year, res.month, res.day);
                  else tempEnd = DateTime(res.year, res.month, res.day);
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                      child: Text('Pilih Rentang Tanggal',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => pickDate(isStart: true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                                tempStart != null
                                    ? formatDate(tempStart!)
                                    : 'Dari Tanggal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: tempStart != null
                                        ? Colors.black
                                        : Colors.grey)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => pickDate(isStart: false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                                tempEnd != null
                                    ? formatDate(tempEnd!)
                                    : 'Sampai Tanggal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: tempEnd != null
                                        ? Colors.black
                                        : Colors.grey)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                              _filterTransactions();
                            });
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.grey.shade300)),
                          child: Text('Reset',
                              style: TextStyle(color: Colors.grey.shade700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _startDate = tempStart;
                              _endDate = tempEnd;
                              _filterTransactions();
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _iconColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('Terapkan Filter',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Laporan ${widget.type}",
            style:
                const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200, 
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: _primaryColor, 
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabs: _scopes.map((s) => Tab(text: s)).toList(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildDateFilter(),
          /*
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _lightBg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total ${_filteredList.length} Transaksi $_currentScope", style: TextStyle(fontSize: 14, color: _iconColor, fontWeight: FontWeight.w600)),
                Text(formatRupiah(_totalNominal.toInt()), style: TextStyle(fontSize: 16, color: _nominalColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          */
          const SizedBox(height: 8),
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          "Tidak ada data ${widget.type.toLowerCase()} yang dikonfirmasi untuk $_currentScope dalam rentang waktu ini.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        )))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) =>
                        _buildTransactionCard(_filteredList[index]),
                  ),
          )
        ],
      ),
    );
  }
}