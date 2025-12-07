import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/laporan_keuangan_model.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah, formatDate;
import 'package:moon_design/moon_design.dart';

class LaporanDetailScreen extends StatelessWidget {
  final LaporanKeuanganModel data;
  final bool isPemasukkan;
  const LaporanDetailScreen({
    super.key,
    required this.data,
    this.isPemasukkan = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors ?? MoonTokens.light.colors;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: Text(
          'Detail ${isPemasukkan ? 'Pemasukan' : 'Pengeluaran'}',
          style: MoonTokens.light.typography.heading.text20.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(context, colors),
            const SizedBox(height: 12),
            _infoTile(
              context,
              label: 'Nama',
              value: data.nama,
              icon: Icons.description_outlined,
            ),
            const SizedBox(height: 8),
            _infoTile(
              context,
              label: isPemasukkan
                  ? 'Kategori Pemasukan'
                  : 'Kategori Pengeluaran',
              value: isPemasukkan
                  ? (data.kategoriPemasukan ?? '-')
                  : (data.kategoriPengeluaran ?? '-'),
              icon: Icons.label_outlined,
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
              value: formatRupiah(data.nominal),
              icon: Icons.payments_outlined,
              valueStyle: MoonTokens.light.typography.body.text16.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            _infoTile(
              context,
              label: 'Verifikator',
              value: data.verifikator ?? 'Admin Jawara',
              icon: Icons.verified_user_outlined,
            ),
            if (data.buktiFoto != null && data.buktiFoto!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buktiSection(context, isPemasukkan),
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerCard(BuildContext context, MoonColors colors) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: MoonSquircleBorder(
          borderRadius: BorderRadius.circular(18).squircleBorderRadius(context),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
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
              color: colors.piccolo.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: colors.piccolo,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MoonTokens.light.typography.heading.text18.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatDate(data.tanggal),
                  style: MoonTokens.light.typography.body.text12.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupiah(data.nominal),
            textAlign: TextAlign.right,
            style: MoonTokens.light.typography.heading.text18.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    TextStyle? valueStyle,
  }) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: MoonSquircleBorder(
          borderRadius: BorderRadius.circular(14).squircleBorderRadius(context),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                  style: MoonTokens.light.typography.body.text12.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style:
                      valueStyle ??
                      MoonTokens.light.typography.body.text14.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buktiSection(BuildContext context, bool isPemasukkan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: MoonSquircleBorder(
          borderRadius: BorderRadius.circular(14).squircleBorderRadius(context),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPemasukkan ? 'Bukti Pemasukan' : 'Bukti Pengeluaran',
            style: MoonTokens.light.typography.body.text14.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: data.buktiFoto!.startsWith('http')
                ? Image.network(
                    data.buktiFoto!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gagal memuat gambar',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Image.file(
                    File(data.buktiFoto!),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gambar Bukti ${isPemasukkan ? 'Pemasukan' : 'Pengeluaran'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
