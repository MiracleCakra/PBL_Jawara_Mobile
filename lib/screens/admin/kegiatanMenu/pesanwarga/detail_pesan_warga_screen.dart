import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/aspirasi_model.dart';
import 'package:jawara_pintar_kel_5/services/aspirasi_service.dart';
import 'edit_pesan_warga_screen.dart';

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
          SnackBar(content: Text('Gagal memperbarui status: $e')),
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

  void _showConfirmationDialog(String newStatus) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Konfirmasi ${newStatus == 'Diterima' ? 'Penerimaan' : 'Penolakan'}'),
        content: Text(
            'Anda yakin ingin ${newStatus == 'Diterima' ? 'menerima' : 'menolak'} aspirasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _updateStatus(newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'Diterima' ? Colors.green : Colors.red,
            ),
            child: Text(newStatus == 'Diterima' ? 'Terima' : 'Tolak'),
          ),
        ],
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
          'Detail Informasi / Aspirasi Warga',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
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
      bottomNavigationBar: status == 'Pending'
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _showConfirmationDialog('Ditolak'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _showConfirmationDialog('Diterima'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Terima'),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

 