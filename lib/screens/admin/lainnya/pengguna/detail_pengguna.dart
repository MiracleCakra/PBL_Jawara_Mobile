import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'package:jawara_pintar_kel_5/services/pengguna_service.dart';

class DetailPenggunaScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DetailPenggunaScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final PenggunaService penggunaService = PenggunaService();
    final String userId = userData['id'];

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
        title: const Text('Detail Pengguna', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showActionBottomSheet(context, userId, userData['name'] ?? 'Pengguna'),
            tooltip: 'Opsi Aksi',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<Warga>(
          stream: penggunaService.streamUserById(userId),
          builder: (context, snapshot) {
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text('Data pengguna tidak ditemukan (mungkin sudah dihapus).'));
            }

            final warga = snapshot.data!;
            
            final displayData = {
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

            return SingleChildScrollView(
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
                              backgroundImage: displayData['imageUrl'] != null
                                  ? NetworkImage(displayData['imageUrl']! as String)
                                  : null,
                              child: displayData['imageUrl'] == null
                                  ? Icon(Icons.person, size: 32, color: Colors.grey.shade600)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayData['name'] as String,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    displayData['role'] as String,
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(displayData['status'] as String),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                displayData['status'] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Detail Information
                        _buildDetailItem(label: 'NIK', value: displayData['nik'] as String),
                        const SizedBox(height: 16),
                        _buildDetailItem(label: 'Email', value: displayData['email'] as String),
                        const SizedBox(height: 16),
                        _buildDetailItem(label: 'Nomor HP', value: displayData['phone'] as String),
                        const SizedBox(height: 16),
                        _buildDetailItem(label: 'Jenis Kelamin', value: displayData['gender'] as String),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'diterima':
      case 'aktif': return const Color(0xFF4E46B4);
      case 'menunggu': return Colors.amber.shade700;
      case 'ditolak':
      case 'nonaktif': return Colors.red.shade600;
      default: return const Color(0xFF4E46B4);
    }
  }

  Widget _buildDetailItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.black)),
      ],
    );
  }

  void _showActionBottomSheet(BuildContext context, String id, String nama) {

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ... Decoration bar ...
               const SizedBox(height: 20), // Placeholder
               _buildOptionTile(
                icon: Icons.edit_rounded,
                color: const Color(0xFF4E46B4),
                title: 'Edit Data',
                subtitle: 'Ubah detail pengguna',
                onTap: () {
                  Navigator.pop(bc);
                  // Kirim data lengkap ke edit (bisa ambil dari widget.userData buat inisial)
                  context.push('/admin/lainnya/manajemen-pengguna/edit', extra: userData);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete_forever,
                color: Colors.red.shade600,
                title: 'Hapus Data',
                subtitle: 'Hapus pengguna ini secara permanen',
                onTap: () {
                   Navigator.pop(bc);
                   _showDeleteDialog(context, id, nama);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildOptionTile({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
     return InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(icon, color: color), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), Text(subtitle)])])));
  }

  void _showDeleteDialog(BuildContext context, String id, String nama) {
     // nu uh.
  }
}