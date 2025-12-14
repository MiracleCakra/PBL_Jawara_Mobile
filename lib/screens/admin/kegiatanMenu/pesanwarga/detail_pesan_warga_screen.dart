import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/aspirasi_model.dart';
import 'package:jawara_pintar_kel_5/services/aspirasi_service.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show getPrimaryColor;

class DetailPesanWargaScreen extends StatefulWidget {
  final AspirasiModel pesan;

  const DetailPesanWargaScreen({super.key, required this.pesan});

  @override
  State<DetailPesanWargaScreen> createState() => _DetailPesanWargaScreenState();
}

class _DetailPesanWargaScreenState extends State<DetailPesanWargaScreen> {
  bool _isLoading = false;

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

  void _updateStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    final aspirasiService = AspirasiService();
    try {
      await aspirasiService.updateAspiration(
        widget.pesan.copyWith(status: newStatus),
      );
      if (mounted) {
        Navigator.pop(context, true); // Go back with a success flag
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: $e'),
            backgroundColor: Colors.grey.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showActionBottomSheet() {
    final primaryColor = getPrimaryColor(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aksi Pesan Warga',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, color: Colors.red, size: 24),
                  ),
                  title: const Text(
                    'Tolak',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    'Tolak aspirasi ini',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  onTap: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                          _showConfirmationDialog('Ditolak');
                        },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.check, color: primaryColor, size: 24),
                  ),
                  title: Text(
                    'Terima',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  subtitle: const Text(
                    'Terima aspirasi ini',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  onTap: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                          _showConfirmationDialog('Diterima');
                        },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(String newStatus) {
    final primaryColor = getPrimaryColor(context);
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: newStatus == 'Diterima'
                      ? primaryColor.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  newStatus == 'Diterima' ? Icons.check : Icons.close,
                  color: newStatus == 'Diterima' ? primaryColor : Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                newStatus == 'Diterima'
                    ? 'Terima Aspirasi?'
                    : 'Tolak Aspirasi?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Anda yakin ingin ${newStatus == 'Diterima' ? 'menerima' : 'menolak'} aspirasi ini?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _updateStatus(newStatus);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: newStatus == 'Diterima'
                            ? primaryColor
                            : Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        newStatus == 'Diterima' ? 'Terima' : 'Tolak',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String judul = widget.pesan.judul;
    final String deskripsi = widget.pesan.isi;
    final String status = widget.pesan.status;
    final String dibuatOleh = widget.pesan.pengirim;
    final String tanggalDibuat = widget.pesan.tanggal.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Detail Pesan Warga',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          if (status == 'Pending')
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              tooltip: 'Aksi Pesan',
              onPressed: _isLoading ? null : _showActionBottomSheet,
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
