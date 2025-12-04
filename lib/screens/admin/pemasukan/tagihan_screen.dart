import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/tagihan_model.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pemasukan/detail_tagihan_screen.dart';
import 'package:moon_design/moon_design.dart';

class TagihanScreen extends StatefulWidget {
  const TagihanScreen({super.key});

  @override
  State<TagihanScreen> createState() => _TagihanScreenState();
}

class _TagihanScreenState extends State<TagihanScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<TagihanModel> _tagihanList = [];
  List<TagihanModel> _filteredTagihanList = [];

  TagihanModel tagihanModel = TagihanModel(
    namaKeluarga: '',
    statusKeluarga: '',
    iuran: '',
    kodeTagihan: '',
    nominal: 0.0,
    periode: DateTime.now(),
    status: '',
  );

  // Filter state
  String? _selectedStatusPembayaran;
  String? _selectedStatusKeluarga;
  String? _selectedKeluarga;
  String? _selectedIuran;
  DateTime? _selectedPeriode;

  @override
  void initState() {
    super.initState();
    _loadTagihan();
    _filteredTagihanList = _tagihanList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTagihan() async {
    final fetchedTagihan = await tagihanModel.fetchTagihan();
    setState(() {
      _tagihanList = fetchedTagihan;
      _filteredTagihanList = fetchedTagihan;
    });
  }

  void _filterTagihan(String query) {
    setState(() {
      List<TagihanModel> filtered = _tagihanList;

      // Apply search query
      if (query.isNotEmpty) {
        filtered = filtered
            .where(
              (tagihan) =>
                  tagihan.namaKeluarga.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  tagihan.kodeTagihan.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  tagihan.iuran.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }

      // Apply status pembayaran filter
      if (_selectedStatusPembayaran != null) {
        filtered = filtered
            .where((tagihan) => tagihan.status == _selectedStatusPembayaran)
            .toList();
      }

      // Apply status keluarga filter
      if (_selectedStatusKeluarga != null) {
        filtered = filtered
            .where(
              (tagihan) => tagihan.statusKeluarga == _selectedStatusKeluarga,
            )
            .toList();
      }

      // Apply keluarga filter
      if (_selectedKeluarga != null) {
        filtered = filtered
            .where((tagihan) => tagihan.namaKeluarga == _selectedKeluarga)
            .toList();
      }

      // Apply iuran filter
      if (_selectedIuran != null) {
        filtered = filtered
            .where((tagihan) => tagihan.iuran == _selectedIuran)
            .toList();
      }

      // Apply periode filter
      if (_selectedPeriode != null) {
        filtered = filtered
            .where(
              (tagihan) =>
                  tagihan.periode.year == _selectedPeriode!.year &&
                  tagihan.periode.month == _selectedPeriode!.month,
            )
            .toList();
      }

      _filteredTagihanList = filtered;
    });
  }

  void _applyFilters() {
    _filterTagihan(_searchController.text);
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getIuranColor(String iuran) {
    switch (iuran) {
      case 'Agustusan':
        return const Color(0xFFEF4444);
      case 'Mingguan':
        return const Color(0xFF3B82F6);
      case 'Bersih Desa':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  IconData _getIuranIcon(String iuran) {
    switch (iuran) {
      case 'Agustusan':
        return Icons.flag_outlined;
      case 'Mingguan':
        return Icons.calendar_today;
      case 'Bersih Desa':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.payment;
    }
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
          "Tagihan",
          style: MoonTokens.light.typography.heading.text20.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar and Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterTagihan,
                        decoration: InputDecoration(
                          hintText: 'Search Name',
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
                        onPressed: _showFilterDialog,
                      ),
                    ),
                  ],
                ),
              ),

              // List Content
              Expanded(
                child: _filteredTagihanList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada tagihan ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredTagihanList.length,
                        itemBuilder: (context, index) {
                          final tagihan = _filteredTagihanList[index];
                          return _buildTagihanCard(tagihan, index + 1);
                        },
                      ),
              ),
            ],
          ),
          // Floating Action Button for PDF Export
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: _exportToPDF,
              backgroundColor: const Color(0xFFEF4444),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text(
                'Cetak PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagihanCard(TagihanModel tagihan, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTagihanScreen(tagihan: tagihan),
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
            // Header Row
            Row(
              children: [
                // Index Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nama Keluarga
                Expanded(
                  child: Text(
                    tagihan.namaKeluarga,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Chevron icon
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
              ],
            ),
            const SizedBox(height: 12),

            // Status Badge Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tagihan.status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tagihan.statusKeluarga,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details Grid
            Row(
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kode Tagihan
                      _buildDetailRow(
                        Icons.tag,
                        'Kode',
                        tagihan.kodeTagihan,
                        Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      // Nominal
                      _buildDetailRow(
                        Icons.payments_outlined,
                        'Nominal',
                        'Rp ${_formatCurrency(tagihan.nominal)}',
                        const Color(0xFF6366F1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Iuran
                      Row(
                        children: [
                          Icon(
                            _getIuranIcon(tagihan.iuran),
                            size: 16,
                            color: _getIuranColor(tagihan.iuran),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tagihan.iuran,
                              style: TextStyle(
                                fontSize: 13,
                                color: _getIuranColor(tagihan.iuran),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Periode
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'Periode',
                        _formatDate(tagihan.periode),
                        Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (c) {
        final bottom = MediaQuery.of(c).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
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

                        // Title
                        const Text(
                          'Filter Tagihan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Status Pembayaran
                        const Text(
                          'Status Pembayaran',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedStatusPembayaran,
                          isExpanded: true,
                          decoration: _dropdownDecoration(),
                          hint: const Text('-- Pilih Status --'),
                          items:
                              [
                                    'Belum Dibayar',
                                    'Menunggu Bukti',
                                    'Menunggu Verifikasi',
                                    'Diterima',
                                    'Ditolak',
                                  ]
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setModalState(() {
                              _selectedStatusPembayaran = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Status Keluarga
                        const Text(
                          'Status Keluarga',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedStatusKeluarga,
                          isExpanded: true,
                          decoration: _dropdownDecoration(),
                          hint: const Text('-- Pilih Status --'),
                          items: ['Aktif', 'Tidak Aktif']
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setModalState(() {
                              _selectedStatusKeluarga = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Keluarga
                        const Text(
                          'Keluarga',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedKeluarga,
                          isExpanded: true,
                          decoration: _dropdownDecoration(),
                          hint: const Text('-- Pilih Keluarga --'),
                          items:
                              (_tagihanList
                                      .map((e) => e.namaKeluarga)
                                      .toSet()
                                      .toList()
                                    ..sort())
                                  .map(
                                    (keluarga) => DropdownMenuItem(
                                      value: keluarga,
                                      child: Text(keluarga),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setModalState(() {
                              _selectedKeluarga = value;
                            });
                          },
                          menuMaxHeight: 200,
                        ),
                        const SizedBox(height: 16),

                        // Iuran
                        const Text(
                          'Iuran',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedIuran,
                          isExpanded: true,
                          decoration: _dropdownDecoration(),
                          hint: const Text('-- Pilih Iuran --'),
                          items:
                              (_tagihanList.map((e) => e.iuran).toSet().toList()
                                    ..sort())
                                  .map(
                                    (iuran) => DropdownMenuItem(
                                      value: iuran,
                                      child: Text(iuran),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setModalState(() {
                              _selectedIuran = value;
                            });
                          },
                          menuMaxHeight: 200,
                        ),
                        const SizedBox(height: 16),

                        // Periode
                        const Text(
                          'Periode (Bulan & Tahun)',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedPeriode ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              helpText: 'Pilih Periode',
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF4E46B4),
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black87,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() {
                                _selectedPeriode = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedPeriode != null
                                        ? '${_selectedPeriode!.month}/${_selectedPeriode!.year}'
                                        : '-- Pilih Periode --',
                                    style: TextStyle(
                                      color: _selectedPeriode != null
                                          ? Colors.black87
                                          : Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: const BorderSide(
                                    color: Color.fromRGBO(78, 70, 180, 0.12),
                                  ),
                                  backgroundColor: const Color(0xFFF4F3FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    _selectedStatusPembayaran = null;
                                    _selectedStatusKeluarga = null;
                                    _selectedKeluarga = null;
                                    _selectedIuran = null;
                                    _selectedPeriode = null;
                                  });
                                },
                                child: const Text(
                                  'Reset Filter',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4E46B4),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    // Apply filters to parent state
                                  });
                                  _applyFilters();
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Terapkan',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        borderSide: const BorderSide(color: Color(0xFF4E46B4), width: 1.2),
      ),
    );
  }

  void _exportToPDF() {
    // TODO: Implement PDF export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur cetak PDF sedang dalam pengembangan'),
        backgroundColor: Color(0xFF6366F1),
      ),
    );
  }
}
