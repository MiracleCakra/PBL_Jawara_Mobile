import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/warga_tagihan_model.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keluarga/detail_tagihan.dart';

class DaftarTagihanWargaScreen extends StatefulWidget {
  const DaftarTagihanWargaScreen({super.key});

  @override
  State<DaftarTagihanWargaScreen> createState() => _DaftarTagihanWargaScreenState();
}

class _DaftarTagihanWargaScreenState extends State<DaftarTagihanWargaScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<WargaTagihanModel> _allTagihan = [];
  List<WargaTagihanModel> _filteredList = [];
  String _selectedFilterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _allTagihan = WargaTagihanModel.getSampleData();
    _filteredList = _allTagihan;
  }

  // --- FILTER LOGIC ---
  void _runFilter() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredList = _allTagihan.where((tagihan) {
        final matchQuery = tagihan.iuran.toLowerCase().contains(query) ||
                           tagihan.kodeTagihan.toLowerCase().contains(query);

        bool matchStatus = true;
        if (_selectedFilterStatus == 'Belum Bayar') {
          matchStatus = tagihan.status == 'Belum Dibayar' || tagihan.status == 'Ditolak';
        } else if (_selectedFilterStatus == 'Lunas') {
          matchStatus = tagihan.status == 'Diterima';
        } else if (_selectedFilterStatus == 'Proses') {
          matchStatus = tagihan.status.contains('Menunggu');
        }

        return matchQuery && matchStatus;
      }).toList();
    });
  }

  // --- MODAL FILTER ---
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String tempStatus = _selectedFilterStatus;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300], 
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Filter Status', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tempStatus,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['Semua', 'Belum Bayar', 'Proses', 'Lunas']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setModalState(() => tempStatus = val!),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E46B4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedFilterStatus = tempStatus;
                          _runFilter();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Terapkan", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- STATUS HELPER ---
  Map<String, dynamic> _getStatusStyle(String status) {
    if (status == 'Diterima') {
      return {'color': Colors.green, 'bg': Colors.green.shade50, 'icon': Icons.check_circle};
    } else if (status == 'Belum Dibayar' || status == 'Ditolak') {
      return {'color': Colors.red, 'bg': Colors.red.shade50, 'icon': Icons.warning};
    } else {
      return {'color': Colors.orange, 'bg': Colors.orange.shade50, 'icon': Icons.access_time};
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Daftar Tagihan", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _runFilter(),
                    decoration: InputDecoration(
                      hintText: 'Cari kode atau jenis iuran...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showFilterDialog,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Icon(Icons.tune, color: Color(0xFF4E46B4)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                final item = _filteredList[index];
                final statusStyle = _getStatusStyle(item.status);

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: InkWell(
                    onTap: () => context.pushNamed(
                      'DetailTagihanWarga',
                      extra: item,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4E46B4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item.iuran == 'Agustusan' ? Icons.flag : Icons.receipt_long,
                                  color: const Color(0xFF4E46B4),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.iuran,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd MMMM yyyy', 'id_ID').format(item.periode),
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                    Text(
                                      item.kodeTagihan,
                                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currencyFormatter.format(item.nominal * 1000),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusStyle['bg'],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(statusStyle['icon'], size: 14, color: statusStyle['color']),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.status,
                                      style: TextStyle(
                                        color: statusStyle['color'],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
