import 'package:flutter/material.dart';
import 'edit_pesan_warga_screen.dart';

class DetailPesanWargaScreen extends StatelessWidget {
  final Map<String, String> pesan;

  const DetailPesanWargaScreen({super.key, required this.pesan});

  // Widget menampilkan setiap field data
  Widget _buildDetailField(String label, String value, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
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
                      // Warna merah untuk Hapus, hitam untuk Edit
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

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditPesanWargaScreen(pesan: pesan)),
    );

    if (result != null && result is Map<String, String>) {
      result['type'] = 'updated';
      if (context.mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  void _showActionBottomSheet(BuildContext context) {
    const Color editColor = Color(0xFF5E65C0); // Warna Ungu konsisten
    final Color deleteColor = Colors.red.shade600;

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
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Opsi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),

              //  OPSI EDIT DATA
              _buildOptionTile(
                icon: Icons.edit_rounded,
                color: editColor,
                title: 'Edit Data',
                subtitle: 'Ubah status atau detail pesan warga',
                onTap: () {
                  Navigator.pop(bc); // Tutup BS
                  _navigateToEdit(context);
                },
              ),
              //  OPSI HAPUS DATA
              _buildOptionTile(
                icon: Icons.delete_forever,
                color: deleteColor,
                title: 'Hapus Data',
                subtitle: 'Hapus pesan ini secara permanen',
                onTap: () {
                  Navigator.pop(bc); // Tutup BS
                  _showDeleteDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final judul = pesan['judul'] ?? 'Pesan Warga';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus pesan "$judul"? Aksi ini tidak dapat dibatalkan.',
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context, {'status': 'deleted', 'judul': judul});
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String judul = pesan['judul'] ?? 'Tidak Ada Judul';
    final String deskripsi = pesan['deskripsi'] ?? 'Tidak Ada Deskripsi';
    final String status = pesan['status'] ?? 'N/A';
    final String dibuatOleh = pesan['pengirim'] ?? 'N/A';
    final String tanggalDibuat = pesan['tanggalDibuat'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Detail Informasi / Aspirasi Warga',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showActionBottomSheet(context),
            tooltip: 'Aksi Pesan',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailField('Judul', judul),
            _buildDetailField('Deskripsi', deskripsi, maxLines: 5),
            _buildDetailField('Status', status),
            _buildDetailField('Dibuat Oleh', dibuatOleh),
            _buildDetailField('Tanggal Dibuat', tanggalDibuat),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

 