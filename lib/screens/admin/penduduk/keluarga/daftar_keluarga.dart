import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:SapaWarga_kel_2/utils.dart' show getPrimaryColor;

// Model for Keluarga Data
class Keluarga {
  final String namaKeluarga;
  final String kepalaKeluarga;
  final String alamat;
  final String status; // aktif, nonaktif
  final String? alasanMutasi;
  final String? jenisMutasi;
  final String? tanggalMutasi;
  final String? statusKepemiikan;
  final String pemilik;
  final String? alamatLama;

  const Keluarga({
    required this.namaKeluarga,
    required this.kepalaKeluarga,
    required this.alamat,
    required this.status,
    required this.pemilik,
    this.alasanMutasi,
    this.jenisMutasi,
    this.tanggalMutasi,
    this.statusKepemiikan,
    this.alamatLama,
  });

  static fetchKeluarga(supabase) async {
    try {
      // -- TAMBAHKAN PRINT UNTUK DEBUGGING --
      debugPrint(
        "Mencoba memuat data Keluarga. Status login: ${supabase.auth.currentUser?.email ?? 'Tidak Login'}",
      );
      // ------------------------------------
      final response = await Supabase.instance.client
          .from('keluarga')
          .select('*, rumah!alamat_rumah(*), warga!kepala_keluarga_id(nama)');

      // print("Data fetched successfully: $response");
      return response;
    } catch (e) {
      debugPrint("Gagal memuat data warga: $e");
    }
  }

  // Get status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'aktif':
        return const Color(0xFF673AB7); // Deep purple
      case 'nonaktif':
        return const Color(0xFF6B7280); // Grey
      default:
        return const Color(0xFF6B7280);
    }
  }

  // Get status background color
  Color get statusBackgroundColor {
    switch (status.toLowerCase()) {
      case 'aktif':
        return const Color(0xFFEDE7F6); // Light purple
      case 'nonaktif':
        return const Color(0xFFF3F4F6); // Light grey
      default:
        return const Color(0xFFF3F4F6);
    }
  }
}

class DaftarKeluargaPage extends StatefulWidget {
  const DaftarKeluargaPage({super.key});

  @override
  State<DaftarKeluargaPage> createState() => _DaftarKeluargaPageState();
}

class _DaftarKeluargaPageState extends State<DaftarKeluargaPage> {
  static const Color _primaryColor = Color(0xFF4E46B4);
  late final SupabaseClient supabase;
  late Keluarga keluarga;

  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedRumah;

  List<Keluarga> _allKeluarga = [];

  @override
  void initState() {
    super.initState();
    // Fetch data when the page is initialized
    supabase = Supabase.instance.client;
    _loadKeluargaData();
  }

  _loadKeluargaData() async {
    final response = await Keluarga.fetchKeluarga(supabase);
    setState(() {
      _allKeluarga = response.map<Keluarga>((item) {
        return Keluarga(
          namaKeluarga: item['nama_keluarga'],
          kepalaKeluarga: item['warga']['nama'],
          alamat: item['rumah']['alamat'] ?? '',
          status: item['status_keluarga'] ?? '',
          pemilik: item['status_kepemilikan'] ?? '',
          alasanMutasi: item['alasan_mutasi'] ?? '',
          jenisMutasi: item['jenis_mutasi'] ?? '',
          tanggalMutasi: item['tanggal_mutasi'] ?? '',
          statusKepemiikan: item['status_kepemilikan'] ?? '',
          alamatLama: item['alamat_lama'] ?? '',
        );
      }).toList();
    });
  }
  // Sample data
  // final List<Keluarga> _allKeluarga = const [
  //   Keluarga(
  //     namaKeluarga: 'Keluarga Hidayat',
  //     kepalaKeluarga: 'Ahmad Hidayat',
  //     alamat: 'Blok A No. 1',
  //     status: 'Aktif',
  //   ),
  //   Keluarga(
  //     namaKeluarga: 'Keluarga Santoso',
  //     kepalaKeluarga: 'Budi Santoso',
  //     alamat: 'Blok A No. 5',
  //     status: 'Aktif',
  //   ),
  //   Keluarga(
  //     namaKeluarga: 'Keluarga Lestari',
  //     kepalaKeluarga: 'Dewi Lestari',
  //     alamat: 'Blok B No. 3',
  //     status: 'Nonaktif',
  //   ),
  //   Keluarga(
  //     namaKeluarga: 'Keluarga Hartono',
  //     kepalaKeluarga: 'Rudi Hartono',
  //     alamat: 'Blok B No. 7',
  //     status: 'Aktif',
  //   ),
  //   Keluarga(
  //     namaKeluarga: 'Keluarga Kartika',
  //     kepalaKeluarga: 'Maya Kartika',
  //     alamat: 'Blok C No. 2',
  //     status: 'Aktif',
  //   ),
  //   Keluarga(
  //     namaKeluarga: 'Keluarga Wijaya',
  //     kepalaKeluarga: 'Andi Wijaya',
  //     alamat: 'Blok C No. 8',
  //     status: 'Nonaktif',
  //   ),
  //   Keluarga(
  //     namaKeluarga: 'Keluarga Susanti',
  //     kepalaKeluarga: 'Rina Susanti',
  //     alamat: 'Blok D No. 4',
  //     status: 'Aktif',
  //   ),
  //   Keluarga(
  //     namaKeluarga: 'Keluarga Pratama',
  //     kepalaKeluarga: 'Dodi Pratama',
  //     alamat: 'Blok D No. 6',
  //     status: 'Aktif',
  //   ),
  // ];

  // Sample rumah options for dropdown
  final List<String> _rumahOptions = [
    'Blok A No. 1',
    'Blok A No. 5',
    'Blok B No. 3',
    'Blok B No. 7',
    'Blok C No. 2',
    'Blok C No. 8',
    'Blok D No. 4',
    'Blok D No. 6',
  ];

  List<Keluarga> get _filteredKeluarga {
    return _allKeluarga.where((keluarga) {
      final matchesSearch =
          _searchController.text.isEmpty ||
          keluarga.namaKeluarga.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          keluarga.kepalaKeluarga.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      final matchesStatus =
          _selectedStatus == null || keluarga.status == _selectedStatus;
      final matchesRumah =
          _selectedRumah == null || keluarga.alamat == _selectedRumah;
      return matchesSearch && matchesStatus && matchesRumah;
    }).toList();
  }

  void _openFilterModal() {
    final tempSearchController = TextEditingController(
      text: _searchController.text,
    );
    String? tempStatus = _selectedStatus;
    String? tempRumah = _selectedRumah;

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
                      _buildSearchFilterField(tempSearchController),
                      const SizedBox(height: 16),
                      _buildStatusFilterDropdown(
                        tempStatus,
                        (value) => setModalState(() => tempStatus = value),
                      ),
                      const SizedBox(height: 16),
                      _buildRumahFilterDropdown(
                        tempRumah,
                        (value) => setModalState(() => tempRumah = value),
                      ),
                      const SizedBox(height: 24),
                      _buildFilterActions(
                        onReset: () => setModalState(() {
                          tempSearchController.clear();
                          tempStatus = null;
                          tempRumah = null;
                        }),
                        onApply: () {
                          setState(() {
                            _searchController.text = tempSearchController.text;
                            _selectedStatus = tempStatus;
                            _selectedRumah = tempRumah;
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
      'Filter Keluarga',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildSearchFilterField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cari Nama Keluarga',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: _inputDecoration(
            'Cari nama keluarga atau kepala keluarga...',
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterDropdown(
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Keluarga',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _inputDecoration('Pilih status'),
          items: const [
            DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
            DropdownMenuItem(value: 'Nonaktif', child: Text('Nonaktif')),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildRumahFilterDropdown(
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alamat Rumah',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _inputDecoration('Pilih alamat rumah'),
          items: _rumahOptions
              .map(
                (rumah) => DropdownMenuItem(value: rumah, child: Text(rumah)),
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
              backgroundColor: getPrimaryColor(context),
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Daftar Keluarga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _FilterButton(onTap: _openFilterModal),
            Expanded(
              child: _filteredKeluarga.isEmpty
                  ? _buildEmptyState()
                  : _buildKeluargaList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data keluarga',
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

  Widget _buildKeluargaList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _filteredKeluarga.length,
      itemBuilder: (context, index) {
        return _KeluargaCard(keluarga: _filteredKeluarga[index]);
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
        color: getPrimaryColor(context),
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: getPrimaryColor(context), //.withOpacity(0.3),
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
                  'Filter Keluarga',
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

// Keluarga Card Widget
class _KeluargaCard extends StatelessWidget {
  final Keluarga keluarga;

  const _KeluargaCard({required this.keluarga});

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
            context.pushNamed('keluargaDetail', extra: keluarga);
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            keluarga.namaKeluarga,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'KK: ${keluarga.kepalaKeluarga}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(keluarga: keluarga),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Alamat: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        keluarga.alamat,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final Keluarga keluarga;

  const _StatusBadge({required this.keluarga});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: keluarga.statusBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: keluarga.statusColor.withOpacity(0.3)),
      ),
      child: Text(
        keluarga.status,
        style: TextStyle(
          color: keluarga.statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
