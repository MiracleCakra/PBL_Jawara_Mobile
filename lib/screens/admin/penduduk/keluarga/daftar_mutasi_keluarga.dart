import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/keluarga/daftar_keluarga.dart';

// Model for Mutasi Keluarga Data
class MutasiKeluargaData {
  final String namaKeluarga;
  final String jenisMutasi; // Keluar Wilayah, Pindah Rumah
  final Keluarga keluarga; // Reference to Keluarga object

  const MutasiKeluargaData({
    required this.namaKeluarga,
    required this.jenisMutasi,
    required this.keluarga,
  });

  // Get jenis mutasi color
  Color get jenisMutasiColor {
    return const Color(0xFF4E46B4); // Primary color for both types
  }

  // Get jenis mutasi background color (outline vs solid)
  Color get jenisMutasiBackgroundColor {
    switch (jenisMutasi.toLowerCase()) {
      case 'keluar wilayah':
        return Colors.transparent; // Outline style
      case 'pindah rumah':
        return const Color(0xFF4E46B4); // Solid style
      default:
        return Colors.transparent;
    }
  }

  // Get jenis mutasi text color
  Color get jenisMutasiTextColor {
    switch (jenisMutasi.toLowerCase()) {
      case 'keluar wilayah':
        return const Color(0xFF4E46B4); // Primary color for outline
      case 'pindah rumah':
        return Colors.white; // White for solid
      default:
        return const Color(0xFF4E46B4);
    }
  }

  // Check if it's outline style
  bool get isOutlineStyle {
    return jenisMutasi.toLowerCase() == 'keluar wilayah';
  }
}

class DaftarMutasiKeluargaPage extends StatefulWidget {
  const DaftarMutasiKeluargaPage({super.key});

  @override
  State<DaftarMutasiKeluargaPage> createState() =>
      _DaftarMutasiKeluargaPageState();
}

class _DaftarMutasiKeluargaPageState extends State<DaftarMutasiKeluargaPage> {
  static const Color _primaryColor = Color(0xFF4E46B4);

  String? _selectedJenisMutasi;
  String? _selectedKeluarga;

  // Sample keluarga data for dropdown
  final List<Keluarga> _allKeluargaOptions = const [
    Keluarga(
      namaKeluarga: 'Keluarga Hidayat',
      kepalaKeluarga: 'Ahmad Hidayat',
      alamat: 'Blok A No. 1',
      status: 'Aktif',
    ),
    Keluarga(
      namaKeluarga: 'Keluarga Santoso',
      kepalaKeluarga: 'Budi Santoso',
      alamat: 'Blok A No. 5',
      status: 'Aktif',
    ),
    Keluarga(
      namaKeluarga: 'Keluarga Lestari',
      kepalaKeluarga: 'Dewi Lestari',
      alamat: 'Blok B No. 3',
      status: 'Nonaktif',
    ),
    Keluarga(
      namaKeluarga: 'Keluarga Ijat',
      kepalaKeluarga: 'Ijat',
      alamat: 'Keluar Wilayah',
      status: 'Nonaktif',
    ),
  ];

  // Sample mutasi data
  List<MutasiKeluargaData> get _allMutasi {
    return [
      MutasiKeluargaData(
        namaKeluarga: 'Keluarga Hidayat',
        jenisMutasi: 'Pindah Rumah',
        keluarga: _allKeluargaOptions[0],
      ),
      MutasiKeluargaData(
        namaKeluarga: 'Keluarga Santoso',
        jenisMutasi: 'Keluar Wilayah',
        keluarga: _allKeluargaOptions[1],
      ),
      MutasiKeluargaData(
        namaKeluarga: 'Keluarga Lestari',
        jenisMutasi: 'Pindah Rumah',
        keluarga: _allKeluargaOptions[2],
      ),
      MutasiKeluargaData(
        namaKeluarga: 'Keluarga Ijat',
        jenisMutasi: 'Keluar Wilayah',
        keluarga: _allKeluargaOptions[3],
      ),
    ];
  }

  List<MutasiKeluargaData> get _filteredMutasi {
    return _allMutasi.where((mutasi) {
      final matchesJenisMutasi =
          _selectedJenisMutasi == null ||
          mutasi.jenisMutasi == _selectedJenisMutasi;
      final matchesKeluarga =
          _selectedKeluarga == null || mutasi.namaKeluarga == _selectedKeluarga;
      return matchesJenisMutasi && matchesKeluarga;
    }).toList();
  }

  void _openFilterModal() {
    String? tempJenisMutasi = _selectedJenisMutasi;
    String? tempKeluarga = _selectedKeluarga;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModalHandle(),
                      const SizedBox(height: 12),
                      _buildModalTitle(),
                      const SizedBox(height: 20),
                      _buildJenisMutasiFilterDropdown(
                        tempJenisMutasi,
                        (value) => setModalState(() => tempJenisMutasi = value),
                      ),
                      const SizedBox(height: 16),
                      _buildKeluargaFilterDropdown(
                        tempKeluarga,
                        (value) => setModalState(() => tempKeluarga = value),
                      ),
                      const SizedBox(height: 24),
                      _buildFilterActions(
                        onReset: () => setModalState(() {
                          tempJenisMutasi = null;
                          tempKeluarga = null;
                        }),
                        onApply: () {
                          setState(() {
                            _selectedJenisMutasi = tempJenisMutasi;
                            _selectedKeluarga = tempKeluarga;
                          });
                          Navigator.pop(context);
                        },
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

  Widget _buildModalHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildModalTitle() {
    return const Text(
      'Filter Mutasi Keluarga',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildJenisMutasiFilterDropdown(
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Mutasi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _inputDecoration('Pilih jenis mutasi'),
          items: const [
            DropdownMenuItem(
              value: 'Keluar Wilayah',
              child: Text('Keluar Wilayah'),
            ),
            DropdownMenuItem(
              value: 'Pindah Rumah',
              child: Text('Pindah Rumah'),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildKeluargaFilterDropdown(
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Keluarga',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _inputDecoration('Pilih keluarga'),
          items: _allKeluargaOptions
              .map(
                (keluarga) => DropdownMenuItem(
                  value: keluarga.namaKeluarga,
                  child: Text(keluarga.namaKeluarga),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
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
        borderSide: const BorderSide(color: _primaryColor, width: 1.2),
      ),
    );
  }

  Widget _buildFilterActions({
    required VoidCallback onReset,
    required VoidCallback onApply,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReset,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Terapkan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Daftar Mutasi Keluarga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _FilterButton(onTap: _openFilterModal),
            Expanded(
              child: _filteredMutasi.isEmpty
                  ? _buildEmptyState()
                  : _buildMutasiList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('mutasiKeluargaAdd'),
        backgroundColor: const Color(0xFF4E46B4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sync_alt, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data mutasi keluarga',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMutasiList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _filteredMutasi.length,
      itemBuilder: (context, index) {
        return _MutasiCard(mutasi: _filteredMutasi[index]);
      },
    );
  }
}

// Filter Button Widget
class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FilterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: const Color(0xFF4E46B4),
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: const Color(0xFF4E46B4).withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tune, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Filter Mutasi Keluarga',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Mutasi Keluarga Card Widget
class _MutasiCard extends StatelessWidget {
  final MutasiKeluargaData mutasi;

  const _MutasiCard({required this.mutasi});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.pushNamed('keluargaDetail', extra: mutasi.keluarga);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mutasi.namaKeluarga,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kepala Keluarga: ${mutasi.keluarga.kepalaKeluarga}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _JenisMutasiBadge(mutasi: mutasi),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Jenis Mutasi Badge Widget
class _JenisMutasiBadge extends StatelessWidget {
  final MutasiKeluargaData mutasi;

  const _JenisMutasiBadge({required this.mutasi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: mutasi.jenisMutasiBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: mutasi.jenisMutasiColor,
          width: mutasi.isOutlineStyle ? 1.5 : 0,
        ),
      ),
      child: Text(
        mutasi.jenisMutasi,
        style: TextStyle(
          color: mutasi.jenisMutasiTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
