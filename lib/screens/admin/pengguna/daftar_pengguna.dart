import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DaftarPenggunaScreen extends StatefulWidget {
  const DaftarPenggunaScreen({super.key});

  @override
  State<DaftarPenggunaScreen> createState() => _DaftarPenggunaScreenState();
}

class _DaftarPenggunaScreenState extends State<DaftarPenggunaScreen> {
  final Color primary = const Color(0xFF4E46B4);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _query = '';
  String? _selectedRole;
  String? _selectedStatus;

  static const List<String> _allRoles = [
    'Admin',
    'Warga',
    'Ketua RT',
    'Ketua RW',
    'Sekretaris RW',
    'Sekretaris RT',
    'Bendahara RW',
    'Bendahara RT'
  ];

  final List<Map<String, String>> _users = [
    {
      'name': 'Pak Habibie',
      'role': 'Warga',
      'status': 'Diterima',
      'nik': '3573034501050004',
      'email': 'Habibie@gmail.com',
      'phone': '085850889729',
      'gender': 'Laki-Laki',
    },
    {
      'name': 'Fara',
      'role': 'Warga',
      'status': 'Diterima',
      'nik': '3573034501050005',
      'email': 'Fara@gmail.com',
      'phone': '081234567890',
      'gender': 'Perempuan',
    },
    {
      'name': 'Angela',
      'role': 'Warga',
      'status': 'Diterima',
      'nik': '3573034501050006',
      'email': 'Angela@gmail.com',
      'phone': '082345678901',
      'gender': 'Laki-Laki',
    },
  ];

  List<Map<String, String>> get _filtered {
    return _users.where((user) {
      final matchesQuery = _query.isEmpty ||
          user['name']!.toLowerCase().contains(_query.toLowerCase());
      final matchesRole = _selectedRole == null || user['role'] == _selectedRole;
      final matchesStatus =
          _selectedStatus == null || user['status'] == _selectedStatus;
      return matchesQuery && matchesRole && matchesStatus;
    }).toList();
  }

  void _openFilter() {
    String? tempRole = _selectedRole;
    String? tempStatus = _selectedStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (c) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Filter Pengguna',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  const Text('Role', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempRole,
                    decoration: _dropdownDecoration(),
                    items: _allRoles
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setModalState(() => tempRole = v),
                  ),
                  const SizedBox(height: 20),
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempStatus,
                    decoration: _dropdownDecoration(),
                    items: const [
                      DropdownMenuItem(value: 'Diterima', child: Text('Diterima')),
                      DropdownMenuItem(value: 'Menunggu', child: Text('Menunggu')),
                      DropdownMenuItem(value: 'Ditolak', child: Text('Ditolak')),
                    ],
                    onChanged: (v) => setModalState(() => tempStatus = v),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFBDBDBD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setModalState(() {
                              tempRole = null;
                              tempStatus = null;
                            });
                            setState(() {
                              _selectedRole = null;
                              _selectedStatus = null;
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedRole = tempRole;
                              _selectedStatus = tempStatus;
                            });
                            Navigator.pop(context);
                          },
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
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF4E46B4), width: 1.4),
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
    bool isFilterActive = _selectedRole != null || _selectedStatus != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Daftar Pengguna',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchFilterBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (v) => setState(() => _query = v),
              onFilterTap: _openFilter,
              isFilterActive: isFilterActive,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Data tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16, top: 8),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = _filtered[index];
                          return _UserCard(
                            user: user,
                            primary: primary,
                            onTap: () {
                              context.pushNamed('penggunaDetail', extra: user);
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('tambahPengguna');
        },
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool isFilterActive;

  const _SearchFilterBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFilterTap,
    required this.isFilterActive,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF4E46B4);
    final Color borderColor = Colors.grey.shade300;
    final Color searchIconColor = Colors.grey.shade500;
    const double tightRadius = 8.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Cari Berdasarkan Nama Pengguna...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(Icons.search, size: 24, color: searchIconColor),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tightRadius),
                    borderSide: BorderSide(color: borderColor, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tightRadius),
                    borderSide: BorderSide(color: borderColor, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tightRadius),
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(tightRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(tightRadius),
              onTap: onFilterTap,
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 1),
                  borderRadius: BorderRadius.circular(tightRadius),
                ),
                child: Icon(
                  Icons.tune,
                  size: 24,
                  color: isFilterActive ? Colors.grey : Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, String> user;
  final Color primary;
  final VoidCallback? onTap;

  const _UserCard({
    required this.user,
    required this.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBgColor;
    String status = user['status'] ?? 'Diterima';

    if (status == 'Diterima') {
      statusBgColor = primary;
    } else if (status == 'Menunggu') {
      statusBgColor = Colors.orange.shade600;
    } else {
      statusBgColor = Colors.red.shade600;
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
                      '${user['role'] ?? '-'} | NIK: ${user['nik'] ?? '-'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
