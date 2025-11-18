import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/pengeluaran_model.dart';
import 'package:jawara_pintar_kel_5/screens/admin/pengeluaran/detail_pengeluaran_screen.dart';

class DaftarPengeluaranScreen extends StatefulWidget {
  const DaftarPengeluaranScreen({super.key});

  @override
  State<DaftarPengeluaranScreen> createState() =>
      _DaftarPengeluaranScreenState();
}

class _DaftarPengeluaranScreenState extends State<DaftarPengeluaranScreen> {
  List<PengeluaranModel> _pengeluaranList = [];
  List<PengeluaranModel> _filteredPengeluaranList = [];

  final TextEditingController _namaFilterController = TextEditingController();
  String? _selectedKategori;
  DateTime? _dariTanggal;
  DateTime? _sampaiTanggal;

  final List<String> _kategoriList = [
    'Operasional RT/RW',
    'Kegiatan Sosial',
    'Pemeliharaan Fasilitas',
    'Pembangunan',
    'Kegiatan Warga',
  ];

  @override
  void initState() {
    super.initState();
    _pengeluaranList = PengeluaranModel.getSampleData();
    _filteredPengeluaranList = _pengeluaranList;
  }

  @override
  void dispose() {
    _namaFilterController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    setState(() {
      _filteredPengeluaranList = _pengeluaranList.where((pengeluaran) {
        // Filter by nama
        if (_namaFilterController.text.isNotEmpty) {
          if (!pengeluaran.nama.toLowerCase().contains(
            _namaFilterController.text.toLowerCase(),
          )) {
            return false;
          }
        }

        // Filter by kategori
        if (_selectedKategori != null && _selectedKategori!.isNotEmpty) {
          if (pengeluaran.jenisPengeluaran != _selectedKategori) {
            return false;
          }
        }

        // Filter by dari tanggal
        if (_dariTanggal != null) {
          if (pengeluaran.tanggal.isBefore(_dariTanggal!)) {
            return false;
          }
        }

        // Filter by sampai tanggal
        if (_sampaiTanggal != null) {
          if (pengeluaran.tanggal.isAfter(_sampaiTanggal!)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _resetFilter() {
    setState(() {
      _namaFilterController.clear();
      _selectedKategori = null;
      _dariTanggal = null;
      _sampaiTanggal = null;
      _filteredPengeluaranList = _pengeluaranList;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isDariTanggal) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDariTanggal) {
          _dariTanggal = picked;
        } else {
          _sampaiTanggal = picked;
        }
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxHeight: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Pengeluaran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama
                            const Text(
                              'Nama',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _namaFilterController,
                              decoration: InputDecoration(
                                hintText: 'Cari nama...',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6366F1),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Kategori
                            const Text(
                              'Kategori',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedKategori,
                              decoration: InputDecoration(
                                hintText: '-- Pilih Kategori --',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6366F1),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items: _kategoriList.map((String kategori) {
                                return DropdownMenuItem<String>(
                                  value: kategori,
                                  child: Text(kategori),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setDialogState(() {
                                  _selectedKategori = newValue;
                                });
                              },
                            ),
                            const SizedBox(height: 20),

                            // Dari Tanggal
                            const Text(
                              'Dari Tanggal',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                await _selectDate(context, true);
                                setDialogState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _dariTanggal == null
                                          ? '--/--/----'
                                          : '${_dariTanggal!.day}/${_dariTanggal!.month}/${_dariTanggal!.year}',
                                      style: TextStyle(
                                        color: _dariTanggal == null
                                            ? Colors.grey[400]
                                            : Colors.black87,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (_dariTanggal != null)
                                          InkWell(
                                            onTap: () {
                                              setDialogState(() {
                                                _dariTanggal = null;
                                              });
                                            },
                                            child: const Icon(
                                              Icons.close,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Sampai Tanggal
                            const Text(
                              'Sampai Tanggal',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                await _selectDate(context, false);
                                setDialogState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _sampaiTanggal == null
                                          ? '--/--/----'
                                          : '${_sampaiTanggal!.day}/${_sampaiTanggal!.month}/${_sampaiTanggal!.year}',
                                      style: TextStyle(
                                        color: _sampaiTanggal == null
                                            ? Colors.grey[400]
                                            : Colors.black87,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (_sampaiTanggal != null)
                                          InkWell(
                                            onTap: () {
                                              setDialogState(() {
                                                _sampaiTanggal = null;
                                              });
                                            },
                                            child: const Icon(
                                              Icons.close,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 1),

                    // Footer Buttons
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _resetFilter();
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey[300]!),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Reset Filter',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _applyFilter();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Terapkan',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
      appBar: AppBar(
        title: const Text(
          'Daftar Pengeluaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _namaFilterController,
                    onChanged: (value) => _applyFilter(),
                    decoration: InputDecoration(
                      hintText: 'Cari daftar Pengeluaran',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.black87),
                    onPressed: _showFilterDialog,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),

          // Card List Section
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredPengeluaranList.length,
                itemBuilder: (context, index) {
                  final pengeluaran = _filteredPengeluaranList[index];
                  return _buildPengeluaranCard(pengeluaran);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengeluaranCard(PengeluaranModel pengeluaran) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailPengeluaranScreen(pengeluaran: pengeluaran),
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
            // Header Row - #ID dan Nama
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nomor ID
                Text(
                  '#${pengeluaran.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),

                // Nama
                Expanded(
                  child: Text(
                    pengeluaran.nama,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Chevron icon
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
              ],
            ),
            const SizedBox(height: 16),

            // Content Row dengan 2 kolom
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom Kiri - Info dengan Icons
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Jenis Pengeluaran dengan icon
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 18,
                            color: Colors.teal[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pengeluaran.jenisPengeluaran,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Nominal dengan icon
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pengeluaran.getFormattedNominal(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Kolom Kanan - Info Tanggal
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tanggal dengan icon
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              pengeluaran.getShortTanggal(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
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
}
