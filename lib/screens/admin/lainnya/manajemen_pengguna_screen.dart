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
  String? _filterRole;
  String? _filterStatus;
  
  List<Warga> _allUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Workaround: Use stream.first to get a snapshot without modifying service
      final users = await _penggunaService.streamAllUsers().first;
      if (mounted) {
        setState(() {
          _allUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data: $e';
        });
      }
    }
  }

  void _refreshData() {
    _fetchData();
  }

  List<Warga> _applyFilters(List<Warga> data) {
    return data.where((warga) {
      final matchesQuery =
          _query.isEmpty ||
          warga.nama.toLowerCase().contains(_query.toLowerCase());

      final matchesRole = _filterRole == null || warga.role == _filterRole;

      final matchesStatus =
          _filterStatus == null ||
          (warga.statusPenduduk?.value ?? 'Nonaktif') == _filterStatus;

      return matchesQuery && matchesRole && matchesStatus;
    }).toList();
  }

  Map<String, Color> _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return {'color': const Color(0xFF673AB7), 'bgColor': const Color(0xFFEDE7F6)};
      case 'RW':
      case 'Ketua RW':
        return {'color': const Color(0xFF3B82F6), 'bgColor': const Color(0xFFDBEAFE)};
      case 'RT':
      case 'Ketua RT':
        return {'color': const Color(0xFF10B981), 'bgColor': const Color(0xFFD1FAE5)};
      case 'Bendahara':
      case 'Bendahara RT':
      case 'Bendahara RW':
        return {'color': const Color(0xFFF59E0B), 'bgColor': const Color(0xFFFEF3C7)};
      case 'Sekretaris':
      case 'Sekretaris RT':
      case 'Sekretaris RW':
        return {'color': const Color(0xFF06B6D4), 'bgColor': const Color(0xFFCFFAFE)};
      case 'Warga':
        return {'color': primary, 'bgColor': const Color(0xFFF4F3FF)};
      default:
        return {'color': Colors.grey.shade600, 'bgColor': Colors.grey.shade200};
    }
  }

  void _openFilter() {
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
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('Filter Pengguna', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      const Text('Role', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: tempRole,
                        hint: const Text('Semua Role'),
                        items: const [
                          DropdownMenuItem(value: 'Warga', child: Text('Warga')),
                          DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'Bendahara', child: Text('Bendahara')),
                        ],
                        onChanged: (v) => setModalState(() => tempRole = v),
                        decoration: _dropdownDecoration(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: tempStatus,
                        hint: const Text('Semua Status'),
                        items: const [
                          DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                          DropdownMenuItem(value: 'Nonaktif', child: Text('Nonaktif')),
                        ],
                        onChanged: (v) => setModalState(() => tempStatus = v),
                        decoration: _dropdownDecoration(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setModalState(() { tempRole = null; tempStatus = null; }),
                              child: const Text('Reset Filter'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
                              onPressed: () {
                                setState(() { _filterRole = tempRole; _filterStatus = tempStatus; });
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

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
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
      body: SafeArea(
        child: Column(
          children: [
            _SearchFilterBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (v) => setState(() => _query = v),
              onFilterTap: _openFilter,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : RefreshIndicator(
                          onRefresh: _fetchData,
                          child: Builder(
                            builder: (context) {
                              final filtered = _applyFilters(_allUsers);
                              if (filtered.isEmpty) {
                                return const Center(child: Text('Data tidak ditemukan.'));
                              }
                              return ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final warga = filtered[index];
                                  final userMap = {
                                    'id': warga.id,
                                    'name': warga.nama,
                                    'role': warga.role ?? '-',
                                    'status': warga.statusPenduduk?.value ?? 'Nonaktif',
                                    'nik': warga.id,
                                    'email': warga.email ?? '-',
                                    'phone': warga.telepon ?? '-',
                                    'gender': warga.gender?.value ?? '-',
                                    'imageUrl': warga.fotoProfil,
                                  };
                                  return _UserCard(
                                    user: userMap,
                                    primary: primary,
                                    onTap: () async {
                                      final result = await context.push('/admin/lainnya/manajemen-pengguna/detail', extra: userMap);
                                      if (result == true) {
                                        _refreshData();
                                      }
                                    },
                                    getRoleColor: _getRoleColor,
                                  );
                                },
                              );
                            },
                          ),
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
    final roleData = getRoleColor(user['role'] ?? '-');
    final color = roleData['color'] ?? Colors.grey;
    final bgColor = roleData['bgColor'] ?? Colors.grey.shade200;

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