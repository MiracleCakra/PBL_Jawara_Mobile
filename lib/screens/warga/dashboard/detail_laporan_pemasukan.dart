import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/transaksi_model.dart'; 
import 'package:jawara_pintar_kel_5/utils.dart' show formatDate, formatRupiah; 
import 'package:go_router/go_router.dart';

class LaporanDetailPemasukanScreen extends StatelessWidget {
  final TransaksiModel data;
  final bool isPemasukan; 

  LaporanDetailPemasukanScreen({
    super.key,
    required this.data,
  }) : isPemasukan = data.tipeTransaksi == 'Pemasukan';

  Color get _accentColor => isPemasukan ? Colors.blue.shade700 : Colors.red.shade700;
  Color get _lightColor => isPemasukan ? Colors.blue.shade50 : Colors.red.shade50;
  IconData get _primaryIcon => isPemasukan ? Icons.trending_up_rounded : Icons.trending_down_rounded;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: Text(
          'Detail ${isPemasukan ? 'Pemasukan' : 'Pengeluaran'}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(context),
            
            const SizedBox(height: 12),
            
            _infoTile(
              context,
              label: isPemasukan ? 'Nama Pembayar' : 'Keterangan Transaksi',
              value: data.namaSubjek,
              icon: Icons.description_outlined,
            ),
            const SizedBox(height: 8),

            _infoTile(
              context,
              label: isPemasukan ? 'Jenis Pemasukan' : 'Jenis Pengeluaran',
              value: data.jenisKategori,
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 8),

            _infoTile(
              context,
              label: 'Tanggal',
              value: formatDate(data.tanggal),
              icon: Icons.event_outlined,
            ),
            const SizedBox(height: 8),

            _infoTile(
              context,
              label: 'Nominal',
              value: formatRupiah(data.nominal.toInt()),
              icon: Icons.payments_outlined,
              valueStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: _accentColor,
              ),
            ),
            const SizedBox(height: 8),

            _infoTile(
              context,
              label: 'Verifikator',
              value: data.verifikator,
              icon: Icons.verified_user_outlined,
            ),
            
            const SizedBox(height: 8),
            _infoTile(
              context,
              label: 'Lingkup Dana',
              value: data.scope,
              icon: Icons.groups_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _lightColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _primaryIcon,
              color: _accentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.namaSubjek,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatDate(data.tanggal),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupiah(data.nominal.toInt()),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: _accentColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET INFO TILE ---
  Widget _infoTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    TextStyle? valueStyle,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle ??
                      const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}