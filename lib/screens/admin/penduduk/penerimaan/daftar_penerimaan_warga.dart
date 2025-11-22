import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model for Penerimaan Warga Data
class PenerimaanWarga {
  final String nama;
  final String nik;
  final String jenisKelamin;
  final String status; // diterima, nonaktif, pending, ditolak
  final String? email;
  final String? foto;

  const PenerimaanWarga({
    required this.nama,
    required this.nik,
    required this.jenisKelamin,
    required this.status,
    this.email,
    this.foto,
  });

  // Get status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'diterima':
        return const Color(0xFF16A34A); // Green
      case 'pending':
        return const Color(0xFFF59E0B); // Orange/Amber
      case 'ditolak':
        return const Color(0xFFEF4444); // Red
      case 'nonaktif':
        return const Color(0xFF6B7280); // Grey
      default:
        return const Color(0xFF6B7280);
    }
  }

  // Get status background color
  Color get statusBackgroundColor {
    switch (status.toLowerCase()) {
      case 'diterima':
        return const Color(0xFFDCFCE7); // Light green
      case 'pending':
        return const Color(0xFFFEF3C7); // Light amber
      case 'ditolak':
        return const Color(0xFFFEE2E2); // Light red
      case 'nonaktif':
        return const Color(0xFFF3F4F6); // Light grey
      default:
        return const Color(0xFFF3F4F6);
    }
  }
}

class DaftarPenerimaanWargaPage extends StatefulWidget {
  const DaftarPenerimaanWargaPage({super.key});

  @override
  State<DaftarPenerimaanWargaPage> createState() =>
      _DaftarPenerimaanWargaPageState();
}

class _DaftarPenerimaanWargaPageState extends State<DaftarPenerimaanWargaPage> {
  late final SupabaseClient supabase;
  static const Color _primaryColor = Color(0xFF4E46B4);

  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedJenisKelamin;

  List<PenerimaanWarga> _allPenerimaan = [];

  @override
  void initState() {
    super.initState();
    // Fetch data when the page is initialized
    supabase = Supabase.instance.client;
    fetchPenerimaanWarga();
  }

  fetchPenerimaanWarga() async {
    try {
      // -- TAMBAHKAN PRINT UNTUK DEBUGGING --
      debugPrint(
        "Mencoba memuat data warga. Status login: ${Supabase.instance.client.auth.currentUser?.email ?? 'Tidak Login'}",
      );
      // ------------------------------------

      final data = await supabase
          .from('warga')
          .select('id, nama, gender, status_penerimaan, email, foto_ktp');

      // Map data from Supabase to List<PenerimaanWarga>
      setState(() {
        _allPenerimaan = data.map<PenerimaanWarga>((item) {
          return PenerimaanWarga(
            nama: item['nama'] ?? '',
            nik: item['id'] ?? '',
            jenisKelamin: item['gender'] ?? '',
            status: item['status_penerimaan'] ?? '',
            email: item['email'] ?? '',
            foto: item['foto_ktp'] ?? '',
          );
        }).toList();
      });
      print("Data fetched successfully: $_allPenerimaan");
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  // Sample data
  // final List<PenerimaanWarga> _allPenerimaan = const [
  //   PenerimaanWarga(
  //     nama: 'Ahmad Hidayat',
  //     nik: '3201012501950001',
  //     jenisKelamin: 'Laki-laki',
  //     status: 'Pending',
  //     email: 'ahmad.hidayat@gmail.com',
  //   ),
  //   PenerimaanWarga(
  //     nama: 'Siti Nurhaliza',
  //     nik: '3201012502960002',
  //     jenisKelamin: 'Perempuan',
  //     status: 'Diterima',
  //     email: 'siti.nurhaliza@gmail.com',
  //   ),
  //   PenerimaanWarga(
  //     nama: 'Budi Santoso',
  //     nik: '3201012503970003',
  //     jenisKelamin: 'Laki-laki',
  //     status: 'Ditolak',
  //     email: 'budi.santoso@gmail.com',
  //   ),
  //   PenerimaanWarga(
  //     nama: 'Dewi Lestari',
  //     nik: '3201012504980004',
  //     jenisKelamin: 'Perempuan',
  //     status: 'Pending',
  //     email: 'dewi.lestari@gmail.com',
  //   ),
  //   PenerimaanWarga(
  //     nama: 'Rudi Hartono',
  //     nik: '3201012505990005',
  //     jenisKelamin: 'Laki-laki',
  //     status: 'Diterima',
  //     email: 'rudi.hartono@gmail.com',
  //   ),
  //   PenerimaanWarga(
  //     nama: 'Maya Kartika',
  //     nik: '3201012506000006',
  //     jenisKelamin: 'Perempuan',
  //     status: 'Nonaktif',
  //     email: 'maya.kartika@gmail.com',
  //   ),
  //   PenerimaanWarga(
  //     nama: 'Andi Wijaya',
  //     nik: '3201012507010007',
  //     jenisKelamin: 'Laki-laki',
  //     status: 'Pending',
  //     email: 'andi.wijaya@gmail.com',
  //   ),
  //   PenerimaanWarga(
  //     nama: 'Rina Susanti',
  //     nik: '3201012508020008',
  //     jenisKelamin: 'Perempuan',
  //     status: 'Diterima',
  //     email: 'rina.susanti@gmail.com',
  //   ),
  // ];

  List<PenerimaanWarga> get _filteredPenerimaan {
    return _allPenerimaan.where((penerimaan) {
      final matchesSearch =
          _searchController.text.isEmpty ||
          penerimaan.nama.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          penerimaan.nik.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      final matchesStatus =
          _selectedStatus == null || penerimaan.status == _selectedStatus;
      final matchesJenisKelamin =
          _selectedJenisKelamin == null ||
          penerimaan.jenisKelamin == _selectedJenisKelamin;
      return matchesSearch && matchesStatus && matchesJenisKelamin;
    }).toList();
  }

  void _openFilterModal() {
    final tempSearchController = TextEditingController(
      text: _searchController.text,
    );
    String? tempStatus = _selectedStatus;
    String? tempJenisKelamin = _selectedJenisKelamin;

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
                      _buildJenisKelaminFilterDropdown(
                        tempJenisKelamin,
                        (value) =>
                            setModalState(() => tempJenisKelamin = value),
                      ),
                      const SizedBox(height: 16),
                      _buildStatusFilterDropdown(
                        tempStatus,
                        (value) => setModalState(() => tempStatus = value),
                      ),
                      const SizedBox(height: 24),
                      _buildFilterActions(
                        onReset: () => setModalState(() {
                          tempSearchController.clear();
                          tempStatus = null;
                          tempJenisKelamin = null;
                        }),
                        onApply: () {
                          setState(() {
                            _searchController.text = tempSearchController.text;
                            _selectedStatus = tempStatus;
                            _selectedJenisKelamin = tempJenisKelamin;
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
      'Filter Penerimaan Warga',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildSearchFilterField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cari Nama/NIK',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: _inputDecoration('Cari nama atau NIK...'),
        ),
      ],
    );
  }

  Widget _buildJenisKelaminFilterDropdown(
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Kelamin',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _inputDecoration('Pilih jenis kelamin'),
          items: const [
            DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
          ],
          onChanged: onChanged,
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
          'Status Penerimaan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _inputDecoration('Pilih status'),
          items: const [
            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
            DropdownMenuItem(value: 'Diterima', child: Text('Diterima')),
            DropdownMenuItem(value: 'Ditolak', child: Text('Ditolak')),
            DropdownMenuItem(value: 'Nonaktif', child: Text('Nonaktif')),
          ],
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
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Daftar Penerimaan Warga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _FilterButton(onTap: _openFilterModal),
            Expanded(
              child: _filteredPenerimaan.isEmpty
                  ? _buildEmptyState()
                  : _buildPenerimaanList(),
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
          Icon(Icons.person_add_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data penerimaan warga',
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

  Widget _buildPenerimaanList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _filteredPenerimaan.length,
      itemBuilder: (context, index) {
        return _PenerimaanCard(penerimaan: _filteredPenerimaan[index]);
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
                  'Filter Penerimaan Warga',
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

// Penerimaan Warga Card Widget
class _PenerimaanCard extends StatelessWidget {
  final PenerimaanWarga penerimaan;

  const _PenerimaanCard({required this.penerimaan});

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
            context.pushNamed('penerimaanDetail', extra: penerimaan);
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
                            penerimaan.nama,
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
                            'NIK: ${penerimaan.nik}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(penerimaan: penerimaan),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      penerimaan.jenisKelamin.toLowerCase() == 'laki-laki'
                          ? Icons.male
                          : Icons.female,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Jenis Kelamin: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        penerimaan.jenisKelamin,
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
  final PenerimaanWarga penerimaan;

  const _StatusBadge({required this.penerimaan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: penerimaan.statusBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: penerimaan.statusColor.withOpacity(0.3)),
      ),
      child: Text(
        penerimaan.status,
        style: TextStyle(
          color: penerimaan.statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
