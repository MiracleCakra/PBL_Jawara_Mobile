import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailPenggunaScreen extends StatelessWidget {
  final Map<String, String> userData;

  const DetailPenggunaScreen({super.key, required this.userData});

  // Fungsi untuk mendapatkan warna status (disalin dari ManajemenPenggunaScreen)
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'diterima':
        return const Color(0xFF4E46B4); // Ungu
      case 'menunggu':
        return Colors.amber.shade700; // Kuning
      case 'ditolak':
        return Colors.red.shade600; // Merah
      default:
        return const Color(0xFF4E46B4);
    }
  }

  // --- FUNGSI BARU UNTUK BOTTOM SHEET & DIALOG ---

  void _navigateToEdit(BuildContext context) {
    // Navigasi ke EditPenggunaScreen (Diasumsikan rute sudah terdaftar)
    context.push('/admin/lainnya/manajemen-pengguna/edit', extra: userData);
  }

  void _showDeleteDialog(BuildContext context) {
    final namaPengguna = userData['name'] ?? 'Pengguna';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Konfirmasi Hapus',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus pengguna "$namaPengguna"? Aksi ini tidak dapat dibatalkan.',
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[500],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.pop(); // Kembali ke halaman Manajemen Pengguna
                
                // Logic hapus data pengguna di sini
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pengguna "$namaPengguna" telah dihapus.'),
                    backgroundColor: const Color(0xFF2E2B32),
                  ),
                );
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
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
              // Judul "Opsi"
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      // Handle Bar
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

              // OPSI EDIT DATA
              _buildOptionTile(
                icon: Icons.edit_rounded,
                color: const Color(0xFF4E46B4), // Warna ungu
                title: 'Edit Data',
                subtitle: 'Ubah detail pengguna',
                onTap: () {
                  Navigator.pop(bc);
                  _navigateToEdit(context);
                },
              ),
              // OPSI HAPUS DATA
              _buildOptionTile(
                icon: Icons.delete_forever,
                color: Colors.red.shade600,
                title: 'Hapus Data',
                subtitle: 'Hapus pengguna ini secara permanen',
                onTap: () {
                  Navigator.pop(bc);
                  _showDeleteDialog(context);
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
            // Ikon dengan latar belakang ringan
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
                      // Jika judul mengandung 'Hapus', gunakan warna ikon, jika tidak, gunakan hitam
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

  // --- WIDGET DETAIL STANDAR ---

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
          'Detail Pengguna',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // --- PENGGANTIAN DI SINI: IconButton memanggil BottomSheet ---
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
              // Detail Card
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
                    // Profile Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey.shade300,
                          // Image logic dibiarkan apa adanya, meskipun userData['imageUrl'] belum terdefinisi di data list Anda
                          backgroundImage: userData['imageUrl'] != null
                              ? NetworkImage(userData['imageUrl']!)
                              : null,
                          child: userData['imageUrl'] == null
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
                                userData['name'] ?? 'Nama Tidak Tersedia',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userData['role'] ?? 'Role Tidak Tersedia',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(userData['status']),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            userData['status'] ?? 'Aktif',
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
                    // Detail Information
                    _buildDetailItem(label: 'NIK', value: userData['nik'] ?? '-'),
                    const SizedBox(height: 16),
                    _buildDetailItem(label: 'Email', value: userData['email'] ?? '-'),
                    const SizedBox(height: 16),
                    _buildDetailItem(label: 'Nomor HP', value: userData['phone'] ?? '-'),
                    const SizedBox(height: 16),
                    _buildDetailItem(label: 'Jenis Kelamin', value: userData['gender'] ?? '-'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}