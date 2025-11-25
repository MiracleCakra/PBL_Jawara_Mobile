import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/penerimaan/daftar_penerimaan_warga.dart';

void main() {
  group('PenerimaanWarga Model Test', () {
    test('Status color should match correct status', () {
      expect(
        const PenerimaanWarga(
          nama: '',
          nik: '',
          jenisKelamin: '',
          status: 'diterima',
        ).statusColor,
        const Color(0xFF16A34A),
      );

      expect(
        const PenerimaanWarga(
          nama: '',
          nik: '',
          jenisKelamin: '',
          status: 'pending',
        ).statusColor,
        const Color(0xFFF59E0B),
      );

      expect(
        const PenerimaanWarga(
          nama: '',
          nik: '',
          jenisKelamin: '',
          status: 'ditolak',
        ).statusColor,
        const Color(0xFFEF4444),
      );

      expect(
        const PenerimaanWarga(
          nama: '',
          nik: '',
          jenisKelamin: '',
          status: 'nonaktif',
        ).statusColor,
        const Color(0xFF6B7280),
      );
    });

    test('Status background color should match correct status', () {
      expect(
        const PenerimaanWarga(
          nama: '',
          nik: '',
          jenisKelamin: '',
          status: 'diterima',
        ).statusBackgroundColor,
        const Color(0xFFDCFCE7),
      );
    });
  });
}
