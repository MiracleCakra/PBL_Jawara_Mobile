import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/pengeluaran_model.dart';

class DetailPengeluaranScreen extends StatelessWidget {
  final PengeluaranModel pengeluaran;

  const DetailPengeluaranScreen({super.key, required this.pengeluaran});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Pengeluaran',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Detail Pengeluaran',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),

                // Nama Pengeluaran
                _buildDetailItem(
                  label: 'Nama Pengeluaran',
                  value: pengeluaran.nama,
                  valueColor: Colors.black87,
                ),
                const SizedBox(height: 24),

                // Kategori
                _buildDetailItem(
                  label: 'Kategori',
                  value: pengeluaran.jenisPengeluaran,
                  valueColor: Colors.black87,
                ),
                const SizedBox(height: 24),

                // Tanggal Transaksi
                _buildDetailItem(
                  label: 'Tanggal Transaksi',
                  value: pengeluaran.getFormattedTanggal(),
                  valueColor: Colors.black87,
                ),
                const SizedBox(height: 24),

                // Nominal
                _buildDetailItem(
                  label: 'Nominal',
                  value: pengeluaran.getFormattedNominal(),
                  valueColor: const Color(0xFFDC2626),
                  valueWeight: FontWeight.bold,
                ),
                const SizedBox(height: 24),

                // Tanggal Terverifikasi
                _buildDetailItem(
                  label: 'Tanggal Terverifikasi',
                  value: pengeluaran.getFormattedVerifikasi(),
                  valueColor: Colors.black87,
                ),
                const SizedBox(height: 24),

                // Verifikator
                _buildDetailItem(
                  label: 'Verifikator',
                  value: pengeluaran.verifikator ?? '-',
                  valueColor: Colors.black87,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    required Color valueColor,
    FontWeight? valueWeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6366F1),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: valueColor,
            fontWeight: valueWeight ?? FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
