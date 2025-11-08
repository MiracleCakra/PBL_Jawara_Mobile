import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'edit_broadcast_screen.dart';
import 'daftar_broadcast.dart';

class DetailBroadcastScreen extends StatelessWidget {
  final KegiatanBroadcast broadcastData;

  const DetailBroadcastScreen({super.key, required this.broadcastData});

  Widget _buildDetailField(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value),
          ),
          const SizedBox(height: 16),
        ],
      );

  Widget _buildDetailArea(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: const TextStyle(height: 1.5)),
          ),
          const SizedBox(height: 16),
        ],
      );

  void _showDeleteDialog(BuildContext context) {
    final judul = broadcastData.judul;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus broadcast "$judul"? Aksi ini tidak dapat dibatalkan.',
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
              Navigator.pop(context, {
                'status': 'deleted',
                'judul': judul,
              });
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditBroadcastScreen(initialBroadcastData: broadcastData),
      ),
    );

    if (result != null && result is Map<String, String>) {
      Navigator.pop(context, result);
    }
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

  void _showActionBottomSheet(BuildContext context) {
    const Color editColor = Color(0xFF5E65C0);
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

              // oPSI EDIT DATA
              _buildOptionTile(
                icon: Icons.edit_rounded,
                color: editColor,
                title: 'Edit Data',
                subtitle: 'Ubah detail broadcast',
                onTap: () {
                  Navigator.pop(bc); // Tutup BS
                  _navigateToEdit(context);
                },
              ),
              // 2. OPSI HAPUS DATA
              _buildOptionTile(
                icon: Icons.delete_forever,
                color: deleteColor,
                title: 'Hapus Data',
                subtitle: 'Hapus broadcast secara permanen',
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          title: const Text('Detail Broadcast',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(0.0),
            child: Divider(height: 1, color: Colors.grey),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () => _showActionBottomSheet(context),
              tooltip: 'Aksi Lain',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailField('Judul Broadcast', broadcastData.judul),
              _buildDetailArea('Isi Broadcast', broadcastData.konten),
              _buildDetailField('Tanggal Publikasi', broadcastData.tanggal),
              _buildDetailField('Dibuat oleh', broadcastData.pengirim),
              if (broadcastData.lampiranGambarUrl != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lampiran Gambar',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      // Asumsi Anda menggunakan asset local, bukan network
                      child: Image.asset(broadcastData.lampiranGambarUrl!,
                          height: 200, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              if (broadcastData.lampiranDokumen.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lampiran Dokumen',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...broadcastData.lampiranDokumen.map(
                    (dokumen) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dokumen,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      );
}