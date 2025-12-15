import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/services/pengguna_service.dart';

class DetailPenggunaScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DetailPenggunaScreen({super.key, required this.userData});

  @override
  State<DetailPenggunaScreen> createState() => _DetailPenggunaScreenState();
}

class _DetailPenggunaScreenState extends State<DetailPenggunaScreen> {
  final PenggunaService _penggunaService = PenggunaService();
  late Map<String, dynamic> _currentUserData;
  bool _hasChanged = false; // Track if data has changed

  @override
  void initState() {
    super.initState();
    _currentUserData = widget.userData;
    // Fetch latest data immediately to ensure sync
    _fetchLatestData();
  }

  Future<void> _fetchLatestData() async {
    try {
      final id = _currentUserData['id'];
      if (id != null) {
        // Use stream.first to get a fresh snapshot
        final updatedWarga = await _penggunaService.streamUserById(id).first;
        if (mounted) {
          setState(() {
            _currentUserData = {
              'id': updatedWarga.id,
              'name': updatedWarga.nama,
              'role': updatedWarga.role ?? '-',
              'status': updatedWarga.statusPenduduk?.value ?? 'Nonaktif',
              'nik': updatedWarga.id,
              'email': updatedWarga.email ?? '-',
              'phone': updatedWarga.telepon ?? '-',
              'gender': updatedWarga.gender?.value ?? '-',
              'imageUrl': updatedWarga.fotoProfil,
            };
          });
        }
      }
    } catch (e) {
      debugPrint('Error refreshing user details: $e');
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'diterima':
      case 'aktif':
        return const Color(0xFF4E46B4); // Ungu
      case 'menunggu':
        return Colors.amber.shade700; // Kuning
      case 'ditolak':
      case 'nonaktif':
        return Colors.red.shade600; // Merah
      default:
        return const Color(0xFF4E46B4);
    }
  }

  void _navigateToEdit(BuildContext context) async {
    final result = await context.push('/admin/lainnya/manajemen-pengguna/edit', extra: _currentUserData);
    if (result == true) {
      setState(() {
        _hasChanged = true; // Mark as changed
      });
      _fetchLatestData();
    }
  }

  void _showActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Opsi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),

              _buildOptionTile(
                icon: Icons.edit_rounded,
                color: const Color(0xFF4E46B4), 
                title: 'Edit Data',
                subtitle: 'Ubah detail pengguna',
                onTap: () {
                  Navigator.pop(bc);
                  _navigateToEdit(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: title.contains('Hapus') ? color : Colors.black), 
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Return _hasChanged status to parent
        context.pop(_hasChanged);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7FB),
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          leading: IconButton(
            onPressed: () => context.pop(_hasChanged),
            icon: const Icon(Icons.chevron_left, color: Colors.black),
          ),
          title: const Text(
            'Detail Pengguna',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () => _showActionBottomSheet(context),
              tooltip: 'Opsi Aksi',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _currentUserData['imageUrl'] != null
                                ? NetworkImage(_currentUserData['imageUrl']!)
                                : null,
                            child: _currentUserData['imageUrl'] == null
                                ? Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Colors.grey.shade600,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentUserData['name'] ?? 'Nama Tidak Tersedia',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currentUserData['role'] ?? 'Role Tidak Tersedia',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_currentUserData['status']),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _currentUserData['status'] ?? 'Aktif',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDetailItem(label: 'NIK', value: _currentUserData['nik'] ?? '-'),
                      const SizedBox(height: 16),
                      _buildDetailItem(label: 'Email', value: _currentUserData['email'] ?? '-'),
                      const SizedBox(height: 16),
                      _buildDetailItem(label: 'Nomor HP', value: _currentUserData['phone'] ?? '-'),
                      const SizedBox(height: 16),
                      _buildDetailItem(label: 'Jenis Kelamin', value: _currentUserData['gender'] ?? '-'),
                    ],
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