import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatanMenu/kegiatan/edit_kegiatan_screen.dart';

class DetailKegiatanScreen extends StatelessWidget {
  final Map<String, String> kegiatan;
  const DetailKegiatanScreen({super.key, required this.kegiatan});

  Widget _buildDetailField(String label, String value, {int? maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value.isEmpty ? '-' : value,
          readOnly: true,
          style: const TextStyle(color: Colors.black87),
          maxLines: maxLines,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            fillColor: Color(0xFFF5F5F5),
            filled: true,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditKegiatanScreen(kegiatan: kegiatan)),
    );

    if (result != null && result is Map<String, String>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kegiatan "${result['judul']}" berhasil diperbarui!'),
          backgroundColor: Colors.blue.shade600,
        ),
      );
      Navigator.pop(context, result);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    final judulKegiatan = kegiatan['judul'] ?? 'Kegiatan';

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
            'Apakah kamu yakin ingin menghapus kegiatan "$judulKegiatan"? Aksi ini tidak dapat dibatalkan.',
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
                context.pop('deleted');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kegiatan "$judulKegiatan" telah dihapus.'),
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
                color: const Color(0xFF5E65C0), // Warna ungu kustom/deep purple
                title: 'Edit Data',
                subtitle: 'Ubah detail kegiatan',
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
                subtitle: 'Hapus kegiatan ini secara permanen',
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
            // Ikon dengan latar belakang ringan (seperti di gambar)
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

  @override
  Widget build(BuildContext context) {
    final String namaKegiatan = kegiatan['judul'] ?? 'Nama Kegiatan Tidak Ada';
    final String kategori = kegiatan['kategori'] ?? 'Lainnya';
    final String deskripsi =
        kegiatan['deskripsi'] ?? 'Deskripsi Belum Tersedia';
    final String tanggal = kegiatan['tanggal'] ?? '-';
    final String lokasi = kegiatan['lokasi'] ?? 'Belum Ditentukan';
    final String pj = kegiatan['pj'] ?? '-';
    final String dibuatOleh = kegiatan['dibuat_oleh'] ?? 'Admin Jawara';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Detail Kegiatan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: Divider(height: 1, color: Colors.grey),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showActionBottomSheet(context),
            tooltip: 'Aksi Kegiatan',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailField('Nama Kegiatan', namaKegiatan),
            _buildDetailField('Kategori', kategori),
            _buildDetailField('Deskripsi', deskripsi, maxLines: null),
            _buildDetailField('Tanggal', tanggal),
            _buildDetailField('Lokasi', lokasi),
            _buildDetailField('Penanggung Jawab', pj),
            _buildDetailField('Dibuat Oleh', dibuatOleh),

            const SizedBox(height: 16),

            // dokumentasi
            const Text(
              'Dokumentasi Event',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey.shade200,
              ),
              child: Image.network(
                // Placeholder Image URL
                'https://placehold.co/600x400/CCCCCC/333333?text=FOTO+DOKUMENTASI',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Gagal memuat gambar',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
