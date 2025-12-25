import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/kegiatan_model.dart';
import 'package:SapaWarga_kel_2/services/kegiatan_service.dart';

class DetailKegiatanScreen extends StatefulWidget {
  final KegiatanModel kegiatan;
  const DetailKegiatanScreen({super.key, required this.kegiatan});

  @override
  State<DetailKegiatanScreen> createState() => _DetailKegiatanScreenState();
}

class _DetailKegiatanScreenState extends State<DetailKegiatanScreen> {
  late KegiatanModel _currentKegiatan;
  final KegiatanService _kegiatanService = KegiatanService();
  bool _isLoading = false;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _currentKegiatan = widget.kegiatan;
    _fetchFullDetail(); // Fetch fresh data with images
  }

  Future<void> _fetchFullDetail() async {
    if (_currentKegiatan.id == null) return;
    
    setState(() => _isLoading = true);
    try {
      final fullData = await _kegiatanService.getKegiatanById(_currentKegiatan.id!);
      if (mounted) {
        setState(() {
          _currentKegiatan = fullData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Optional: Show error or just stick with initial data
        debugPrint("Error fetching full detail: $e");
      }
    }
  }

  Widget _buildDetailField(String label, String value, {int? maxLines = 1, Key? key}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          // Force rebuild when value changes by including it in the key
          key: key, 
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
    // Tunggu user selesai ngedit
    final result = await context.push<KegiatanModel>(
      '/admin/kegiatan/edit',
      extra: _currentKegiatan,
    );

    if (result != null) {
      if (mounted) {
        // Refresh data dari database agar dapat URL gambar terbaru & update lain
        await _fetchFullDetail();
        
        setState(() {
          _isChanged = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil diperbarui'),
            backgroundColor: Colors.grey.shade800,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    final judulKegiatan = _currentKegiatan.judul;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hapus Kegiatan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Apakah Anda yakin ingin menghapus kegiatan "$judulKegiatan"? Tindakan ini tidak dapat dibatalkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('confirm_delete_kegiatan_button'),
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await _kegiatanService.deleteKegiatan(
                              _currentKegiatan.id!,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Kegiatan "$judulKegiatan" telah dihapus.',
                                  ),
                                  backgroundColor: const Color(0xFF2E2B32),
                                ),
                              );
                              context.pop('refresh');
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menghapus kegiatan: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
                key: const Key('edit_kegiatan_button'),
                icon: Icons.edit_rounded,
                color: const Color(0xFF5E65C0),
                title: 'Edit Data',
                subtitle: 'Ubah detail kegiatan',
                onTap: () {
                  Navigator.pop(bc);
                  _navigateToEdit(context);
                },
              ),
              _buildOptionTile(
                key: const Key('delete_kegiatan_button'),
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
    Key? key,
  }) {
    return InkWell(
      key: key,
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
                    color: title.contains('Hapus') ? color : Colors.black,
                  ),
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
    final DateFormat detailDateFormat = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Jika data berubah, kirim 'refresh', jika tidak null saja
        context.pop(_isChanged ? 'refresh' : null);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          leading: IconButton(
            key: const Key('back_button'),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => context.pop(_isChanged ? 'refresh' : null),
          ),
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
              key: const Key('kegiatan_more_actions_button'),
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showActionBottomSheet(context),
              tooltip: 'Aksi Kegiatan',
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailField('Nama Kegiatan', _currentKegiatan.judul, key: const Key('detail_nama_kegiatan')),
                  _buildDetailField('Kategori', _currentKegiatan.kategori),
                  _buildDetailField(
                    'Deskripsi',
                    _currentKegiatan.deskripsi,
                    key: const Key('detail_deskripsi_kegiatan'),
                    maxLines: null,
                  ),
                  _buildDetailField(
                    'Tanggal',
                    detailDateFormat.format(_currentKegiatan.tanggal),
                  ),
                  _buildDetailField('Lokasi', _currentKegiatan.lokasi),
                  _buildDetailField('Penanggung Jawab', _currentKegiatan.pj),
                  _buildDetailField(
                    'Dibuat Oleh',
                    _currentKegiatan.dibuatOleh ?? 'Admin',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dokumentasi Event',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_currentKegiatan.images != null && _currentKegiatan.images!.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _currentKegiatan.images!.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final imgUrl = _currentKegiatan.images![index].img;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imgUrl,
                              width: 300,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 300,
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey.shade200,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          _currentKegiatan.gambarDokumentasi ??
                              'https://placehold.co/600x400/CCCCCC/333333?text=Tidak+Ada+Dokumentasi',
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
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
