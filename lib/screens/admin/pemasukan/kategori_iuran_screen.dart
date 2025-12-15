import 'package:flutter/material.dart';
import 'package:SapaWarga_kel_2/models/keuangan/iuran_model.dart';
import 'package:SapaWarga_kel_2/screens/admin/pemasukan/detail_iuran_screen.dart';
import 'package:SapaWarga_kel_2/screens/admin/pemasukan/tambah_iuran_screen.dart';
import 'package:moon_design/moon_design.dart';
import 'package:SapaWarga_kel_2/utils.dart' show getPrimaryColor;

class KategoriIuranScreen extends StatefulWidget {
  const KategoriIuranScreen({super.key});

  @override
  State<KategoriIuranScreen> createState() => _KategoriIuranScreenState();
}

class _KategoriIuranScreenState extends State<KategoriIuranScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<IuranModel> _iuranList = [];
  List<IuranModel> _filteredIuranList = [];
  String? _selectedJenisFilter;

  final List<String> _jenisIuranOptions = [
    'Semua',
    'Iuran Bulanan',
    'Iuran Khusus',
  ];

  @override
  void initState() {
    super.initState();
    _fetchIuranData();
  }

  // Fetch Iuran data by creating an instance of IuranModel
  void _fetchIuranData() async {
    IuranModel iuranModel = IuranModel(
      namaIuran: '',
      jenisIuran: '',
      nominal: 0.0,
    );
    _iuranList = await iuranModel.fetchIuran();
    _filteredIuranList = _iuranList;
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterIuran(String query) {
    setState(() {
      var filtered = _iuranList;

      // Filter by jenis iuran
      if (_selectedJenisFilter != null && _selectedJenisFilter != 'Semua') {
        filtered = filtered
            .where((iuran) => iuran.jenisIuran == _selectedJenisFilter)
            .toList();
      }

      // Filter by search query
      if (query.isNotEmpty) {
        filtered = filtered
            .where(
              (iuran) =>
                  iuran.namaIuran.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }

      _filteredIuranList = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: Text(
          "Kategori Iuran",
          style: MoonTokens.light.typography.heading.text20.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterIuran,
                        decoration: InputDecoration(
                          hintText: 'Cari Data Iuran',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {
                          _showFilterDialog();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // List Content
              Expanded(
                child: _filteredIuranList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada data',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredIuranList.length,
                        itemBuilder: (context, index) {
                          final iuran = _filteredIuranList[index];
                          return _buildIuranCard(iuran);
                        },
                      ),
              ),
            ],
          ),
          // Floating Action Button - Add
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () {
                _showAddIuranDialog();
              },
              backgroundColor: const Color(0xFF6366F1),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIuranCard(IuranModel iuran) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailIuranScreen(iuran: iuran),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    iuran.namaIuran,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  iuran.jenisIuran,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  'Rp ${_formatCurrency(iuran.nominal)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showFilterDialog() {
    String tempSelected = _selectedJenisFilter ?? 'Semua';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Filter Kategori Iuran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Jenis Iuran',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        key: const Key('dropdown_filter_jenis_iuran'),
                        value: tempSelected,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4E46B4),
                              width: 1.2,
                            ),
                          ),
                        ),
                        items: _jenisIuranOptions
                            .map(
                              (option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setModalState(() => tempSelected = v ?? 'Semua'),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedJenisFilter = 'Semua';
                                  _filterIuran(_searchController.text);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: getPrimaryColor(context),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedJenisFilter = tempSelected;
                                  _filterIuran(_searchController.text);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Terapkan'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getJenisIcon(String jenis) {
    switch (jenis) {
      case 'Semua':
        return Icons.apps;
      case 'Iuran Bulanan':
        return Icons.calendar_month;
      case 'Iuran Khusus':
        return Icons.star_outline;
      default:
        return Icons.category;
    }
  }

  void _showAddIuranDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahIuranScreen()),
    );
  }
}
