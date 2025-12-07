import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'package:jawara_pintar_kel_5/services/pengguna_service.dart';

class ManajemenPenggunaScreen extends StatefulWidget {
  const ManajemenPenggunaScreen({super.key});

  @override
  State<ManajemenPenggunaScreen> createState() =>
      _ManajemenPenggunaScreenState();
}

class _ManajemenPenggunaScreenState extends State<ManajemenPenggunaScreen> {
  final Color primary = const Color(0xFF4E46B4);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final PenggunaService _penggunaService = PenggunaService();

  String _query = '';
  // Variabel filter
  String? _filterRole;
  String? _filterStatus;

  // Gak butuh initState buat fetch data lagi!

  // Logic filter lokal di sisi aplikasi
  List<Warga> _applyFilters(List<Warga> data) {
    return data.where((warga) {
      // 1. Filter Search Nama
      final matchesQuery =
          _query.isEmpty ||
          warga.nama.toLowerCase().contains(_query.toLowerCase());

      // 2. Filter Role (Dropdown)
      final matchesRole = _filterRole == null || warga.role == _filterRole;

      // 3. Filter Status (Dropdown)
      final matchesStatus =
          _filterStatus == null ||
          (warga.statusPenduduk?.value ?? 'Nonaktif') == _filterStatus;

      return matchesQuery && matchesRole && matchesStatus;
    }).toList();
  }

  Map<String, Color> _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return {
          'color': const Color(0xFF673AB7),
          'bgColor': const Color(0xFFEDE7F6),
        };
      case 'Ketua RW':
        // Biru
        return {
          'color': const Color(0xFF3B82F6),
          'bgColor': const Color(0xFFDBEAFE),
        };
      case 'Ketua RT':
        // Hijau
        return {
          'color': const Color(0xFF10B981),
          'bgColor': const Color(0xFFD1FAE5),
        };
      case 'Bendahara':
        // Orange
        return {
          'color': const Color(0xFFF59E0B),
          'bgColor': const Color(0xFFFEF3C7),
        };
      case 'Sekretaris':
        // Teal/Cyan
        return {
          'color': const Color(0xFF06B6D4),
          'bgColor': const Color(0xFFCFFAFE),
        };
      case 'Warga':
        // Warna utama/primary
        return {
          'color': primary, // Primary Blue-Purple
          'bgColor': const Color(0xFFF4F3FF),
        };
      default:
        return {'color': Colors.grey.shade600, 'bgColor': Colors.grey.shade200};
    }
  }

  void _openFilter() {
    // Kita pakai variabel temp biar user harus klik "Terapkan" baru filter berubah
    String? tempRole = _filterRole;
    String? tempStatus = _filterStatus;

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
                        'Filter Pengguna',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Filter Role
                      const Text(
                        'Role',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: tempRole,
                        hint: const Text('Semua Role'), // Tambahkan hint
                        isExpanded: true,
                        decoration: _dropdownDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Warga',
                            child: Text('Warga'),
                          ),
                          DropdownMenuItem(
                            value: 'Admin',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: 'Bendahara',
                            child: Text('Bendahara'),
                          ),
                          // Tambahin role lain sesuai kebutuhan
                        ],
                        onChanged: (v) => setModalState(() => tempRole = v),
                      ),

                      const SizedBox(height: 16),

                      // Filter Status Pendaftaran
                      const Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: tempStatus,
                        hint: const Text('Semua Status'), // Tambahkan hint
                        isExpanded: true,
                        decoration: _dropdownDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Aktif',
                            child: Text('Aktif'),
                          ),
                          DropdownMenuItem(
                            value: 'Nonaktif',
                            child: Text('Nonaktif'),
                          ),
                        ],
                        onChanged: (v) => setModalState(() => tempStatus = v),
                      ),

                      const SizedBox(height: 20),
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
                                  tempRole = null;
                                  tempStatus = null;
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
                                // Update state utama screen
                                setState(() {
                                  _filterRole = tempRole;
                                  _filterStatus = tempStatus;
                                });
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

  @override
  void dispose() {
    _searchFocusNode.dispose();
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
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Manajemen Pengguna',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/admin/lainnya/manajemen-pengguna/tambah');
          // Gak perlu refresh manual, stream otomatis update!
        },
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: const Text(
                'Daftar Pengguna',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            // Search and filter component (tetap sama)
            _SearchFilterBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (v) => setState(() => _query = v),
              onFilterTap: _openFilter,
            ),
            // User list dengan StreamBuilder
            Expanded(
              child: StreamBuilder<List<Warga>>(
                stream: _penggunaService.streamAllUsers(),
                builder: (context, snapshot) {
                  // 1. Loading State
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. Error State
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // 3. Empty Data
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Belum ada data pengguna.'),
                    );
                  }

                  // 4. Data Ada -> Filter dulu sebelum ditampilkan
                  final filteredList = _applyFilters(snapshot.data!);

                  if (filteredList.isEmpty) {
                    return const Center(child: Text('Data tidak ditemukan.'));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final warga = filteredList[index];

                        // Map data untuk dikirim ke detail
                        final userMap = {
                          'id': warga.id,
                          'name': warga.nama,
                          'role': warga.role ?? '-',
                          'status': warga.statusPenduduk?.value ?? 'Nonaktif',
                          'nik': warga.id,
                          'email': warga.email ?? '-',
                          'phone': warga.telepon ?? '-',
                          'gender': warga.gender?.value ?? '-',
                          'imageUrl': warga.fotoProfil, // Bawa URL foto
                        };

                        return _UserCard(
                          user: userMap,
                          primary: primary,
                          onTap: () async {
                            // Kirim ID-nya, detail screen nanti listen ke stream ID ini
                            context.push(
                              '/admin/lainnya/manajemen-pengguna/detail',
                              extra: userMap,
                            );
                          },
                          getRoleColor: _getRoleColor,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const _SearchFilterBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color.fromRGBO(0, 0, 0, 0.2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                onTap: () => focusNode.requestFocus(),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  hintText: 'Cari Berdasarkan Nama Pengguna...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.03),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.tune, color: Colors.black, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final Color primary;
  final VoidCallback? onTap;
  final Map<String, Color> Function(String) getRoleColor;

  const _UserCard({
    required this.user,
    required this.primary,
    this.onTap,
    required this.getRoleColor,
  });

  @override
  Widget build(BuildContext context) {
    final roleColorMap = getRoleColor(user['role'] ?? '-');
    final color = roleColorMap['color'] ?? Colors.grey;
    final bgColor = roleColorMap['bgColor'] ?? Colors.grey.shade200;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email'] ?? '-',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  user['role'] ?? '-',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
