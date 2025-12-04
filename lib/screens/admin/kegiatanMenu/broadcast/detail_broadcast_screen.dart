import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/broadcast_model.dart';
import 'package:jawara_pintar_kel_5/services/broadcast_service.dart';
import 'edit_broadcast_screen.dart';

class DetailBroadcastScreen extends StatefulWidget {
  final BroadcastModel broadcastModel;
  const DetailBroadcastScreen({super.key, required this.broadcastModel});

  @override
  State<DetailBroadcastScreen> createState() => _DetailBroadcastScreenState();
}

class _DetailBroadcastScreenState extends State<DetailBroadcastScreen> {
  final BroadcastService _broadcastService = BroadcastService();
  late BroadcastModel _displayData;
  bool _isDeleting = false;
  bool _isRefreshing = false;

  @override initState(){
    super.initState();
    _displayData = widget.broadcastModel;
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    try {
      // Ambil data fresh berdasarkan ID
      final freshData = await _broadcastService.getBroadcastById(_displayData.id!);
      if (mounted) {
        setState(() {
          _displayData = freshData; // Update tampilan dengan data baru
        });
      }
    } catch (e) {
      debugPrint("Gagal refresh data: $e");
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka file')),
        );
      }
    }
  }

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

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditBroadcastScreen(broadcast: _displayData), // Kirim data yg skrg
      ),
    );

    // 4. Cek hasil balikan: Kalau true (berhasil edit), kita refresh
    if (result == true && mounted) {
      _refreshData(); // <--- INI KUNCINYA
      
      // Opsional: Kalau mau tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil diperbarui"), backgroundColor: Colors.green),
      );
    }
  }

  void _deleteBroadcast() async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus broadcast "${widget.broadcastModel.judul}"?',
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); 
              setState(() {
                _isDeleting = true;
              });
              try {
                await _broadcastService.deleteBroadcast(widget.broadcastModel.id!);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Broadcast "${widget.broadcastModel.judul}" berhasil dihapus.'),
                    backgroundColor: Colors.green,
                  ),
                );
                if (context.canPop()) {
                  context.pop(true);
                }
              } catch (e) {
                setState(() {
                  _isDeleting = false;
                });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus broadcast: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('Opsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              _buildOptionTile(
                icon: Icons.edit_rounded,
                color: editColor,
                title: 'Edit Data',
                subtitle: 'Ubah detail broadcast',
                onTap: () {
                  Navigator.pop(bc);
                  _navigateToEdit(context);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete_forever,
                color: deleteColor,
                title: 'Hapus Data',
                subtitle: 'Hapus broadcast secara permanen',
                onTap: () {
                  Navigator.pop(bc);
                  _deleteBroadcast();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final data = _displayData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Detail Broadcast',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: Divider(height: 1, color: Colors.grey),
        ),
        actions: [
          if (_isRefreshing)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showActionBottomSheet(context),
            tooltip: 'Aksi Lain',
          ),
        ],
      ),
      body: _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator( // Tambahin fitur tarik buat refresh manual juga
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailField('Judul Broadcast', data.judul),
                    _buildDetailArea('Isi Broadcast', data.konten),
                    _buildDetailField('Tanggal Publikasi', dateFormat.format(data.tanggal)),
                    _buildDetailField('Dibuat oleh', data.pengirim),
                    
                    if (data.lampiranGambarUrl != null) ...[
                      const Text('Lampiran Gambar',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data.lampiranGambarUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text('Gagal memuat gambar'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (data.lampiranDokumenUrl != null) ...[
                      const Text('Lampiran Dokumen',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _launchUrl(data.lampiranDokumenUrl!),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue.shade200),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blue.shade50,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, color: Colors.red),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Lihat Dokumen PDF",
                                  style: TextStyle(
                                      color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.open_in_new, color: Colors.blue, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}