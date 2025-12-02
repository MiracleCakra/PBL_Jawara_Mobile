import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model for House Data
class Rumah {
  final String id;
  final String alamat;
  final String status;
  final String? pemilik;
  final String? pemilikId;
  final int residents;
  final String? kepalaKeluarga;

  const Rumah({
    required this.id,
    required this.alamat,
    required this.status,
    this.pemilik,
    this.pemilikId,
    required this.residents,
    this.kepalaKeluarga,
  });

  bool get isDitempati => status.toLowerCase() == 'ditempati';
}

class DaftarRumahPage extends StatefulWidget {
  const DaftarRumahPage({super.key});

  @override
  State<DaftarRumahPage> createState() => _DaftarRumahPageState();
}

class _DaftarRumahPageState extends State<DaftarRumahPage> {
  late final SupabaseClient supabase;
  static const Color _primaryColor = Color(0xFF4E46B4);

  final TextEditingController _addressController = TextEditingController();
  String? _selectedStatus;

  List<Rumah> _allRumah = [];

  @override
  void initState() {
    super.initState();
    // Fetch data when the page is initialized
    supabase = Supabase.instance.client;
    fetchDaftarRumah();
  }

  fetchDaftarRumah() async {
    try {
      // -- TAMBAHKAN PRINT UNTUK DEBUGGING --
      debugPrint(
        "Mencoba memuat data rumah. Status login: ${supabase.auth.currentUser?.email ?? 'Tidak Login'}",
      );
      // ------------------------------------
      final response = await Supabase.instance.client
          .from('rumah')
          .select('*, keluarga!keluarga_id(nama_keluarga, kepala_keluarga_id)');

      // Map data from Supabase to List<PenerimaanWarga>
      setState(() {
        _allRumah = response.map<Rumah>((item) {
          return Rumah(
            id: item['id'],
            alamat: item['alamat'] ?? '',
            status: item['status'] ?? '',
            // pemilik: item['keluarga'] ?? '',
            pemilik: item['keluarga'] != null
                ? item['keluarga']['nama_keluarga']
                : 'Tidak Diketahui', // Ambil nama dari tabel keluarga
            pemilikId: item['keluarga_id'],
            residents: item['jumlah_penghuni'] ?? 0,
          );
        }).toList();
      });
      print("Data fetched successfully: $_allRumah");
    } catch (e) {
      debugPrint("Gagal memuat data warga: $e");
    }
  }

  // Sample data
  // final List<Rumah> _allRumah = const [
  //   Rumah(
  //     alamat: 'Jl. Merbabu',
  //     status: 'Tersedia',
  //     pemilik: 'Keluarga Besar Mojokerto',
  //     residents: 4,
  //     type: 'Permanen',
  //   ),
  //   Rumah(
  //     alamat: 'Malang',
  //     status: 'Ditempati',
  //     pemilik: 'Keluarga Ahmad',
  //     residents: 5,
  //     type: 'Semi Permanen',
  //   ),
  //   Rumah(
  //     alamat: 'Griyashanta L.203',
  //     status: 'Tersedia',
  //     pemilik: 'Keluarga Santoso',
  //     residents: 0,
  //     type: 'Permanen',
  //   ),
  //   Rumah(
  //     alamat: 'werwer',
  //     status: 'Tersedia',
  //     pemilik: 'Tidak Ada',
  //     residents: 0,
  //     type: 'Darurat',
  //   ),
  //   Rumah(
  //     alamat: 'Jl. Baru bangun',
  //     status: 'Ditempati',
  //     pemilik: 'Keluarga Budi',
  //     residents: 6,
  //     type: 'Permanen',
  //   ),
  //   Rumah(
  //     alamat: 'fasda',
  //     status: 'Tersedia',
  //     pemilik: 'Tidak Ada',
  //     residents: 0,
  //     type: 'Semi Permanen',
  //   ),
  //   Rumah(
  //     alamat: 'Bogor Raya Permai FJ 2 no 11',
  //     status: 'Ditempati',
  //     pemilik: 'Keluarga Rahman',
  //     residents: 3,
  //     type: 'Permanen',
  //   ),
  //   Rumah(
  //     alamat: 'malang',
  //     status: 'Ditempati',
  //     pemilik: 'Keluarga Siti',
  //     residents: 4,
  //     type: 'Semi Permanen',
  //   ),
  //   Rumah(
  //     alamat: 'Quis consequatur nob',
  //     status: 'Tersedia',
  //     pemilik: 'Tidak Ada',
  //     residents: 0,
  //     type: 'Permanen',
  //   ),
  // ];

  List<Rumah> get _filteredRumah {
    return _allRumah.where((rumah) {
      final matchesAddress =
          _addressController.text.isEmpty ||
          rumah.alamat.toLowerCase().contains(
            _addressController.text.toLowerCase(),
          );
      final matchesStatus =
          _selectedStatus == null || rumah.status == _selectedStatus;
      return matchesAddress && matchesStatus;
    }).toList();
  }

  void _openFilterModal() {
    final tempAddressController = TextEditingController(
      text: _addressController.text,
    );
    String? tempStatus = _selectedStatus;

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
                      _buildAddressFilterField(tempAddressController),
                      const SizedBox(height: 16),
                      _buildStatusFilterDropdown(
                        tempStatus,
                        (value) => setModalState(() => tempStatus = value),
                      ),
                      const SizedBox(height: 24),
                      _buildFilterActions(
                        onReset: () => setModalState(() {
                          tempAddressController.clear();
                          tempStatus = null;
                        }),
                        onApply: () {
                          setState(() {
                            _addressController.text =
                                tempAddressController.text;
                            _selectedStatus = tempStatus;
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
      'Filter Rumah',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildAddressFilterField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alamat', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: _inputDecoration('Cari alamat...'),
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
        const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _inputDecoration('Pilih status'),
          items: const [
            DropdownMenuItem(value: 'Tersedia', child: Text('Tersedia')),
            DropdownMenuItem(value: 'Ditempati', child: Text('Ditempati')),
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
    _addressController.dispose();
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
          'Daftar Rumah',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _FilterButton(onTap: _openFilterModal),
            Expanded(
              child: _filteredRumah.isEmpty
                  ? _buildEmptyState()
                  : _buildRumahList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryColor,
        onPressed: () => context.pushNamed('rumahAdd'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada rumah ditemukan',
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

  Widget _buildRumahList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: _filteredRumah.length,
      itemBuilder: (context, index) {
        return _RumahCard(rumah: _filteredRumah[index], index: index);
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
                  'Filter Rumah',
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

// Rumah Card Widget with Gradient
class _RumahCard extends StatelessWidget {
  final Rumah rumah;
  final int index;

  const _RumahCard({required this.rumah, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDitempati = rumah.isDitempati;

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
          onTap: () async {
            // Await the result from detail route; refresh list if item deleted (returned true)
            final result = await context.pushNamed('rumahDetail', extra: rumah);
            if (result == true) {
              // Call parent's fetch function by finding ancestor state and invoking it,
              // or if you prefer, use a state management solution; simple approach below:
              // findState is the page State and call fetchDaftarRumah.
              final state = context
                  .findAncestorStateOfType<_DaftarRumahPageState>();
              state?.fetchDaftarRumah();
            }
          }, // modified
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        rumah.alamat,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(
                      status: rumah.status,
                      isDitempati: isDitempati,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.people_outline,
                  label: 'Penghuni',
                  value: '${rumah.residents} orang',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Pemilik',
                  value: rumah.pemilik ?? '-',
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
  final String status;
  final bool isDitempati;

  const _StatusBadge({required this.status, required this.isDitempati});

  @override
  Widget build(BuildContext context) {
    // Gradient purple for Tersedia, Primary solid for Ditempati
    final backgroundColor = isDitempati
        ? const Color(0xFF0a0985) // Primary color
        : const Color(0xff7176fe); // Will use gradient

    final borderColor = isDitempati
        ? const Color(0xFF4E46B4).withOpacity(0.3)
        : const Color(0xFFB794F6).withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Info Row Widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
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
    );
  }
}
