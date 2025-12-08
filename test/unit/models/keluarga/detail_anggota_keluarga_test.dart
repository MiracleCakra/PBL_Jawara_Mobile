import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/anggota_detail_model.dart';

void main() {
  group('AnggotaDetail Model Test', () {
    test('should assign required values correctly', () {
      final anggota = AnggotaDetail(
        nik: '1234567890123456',
        nama: 'Siti Aisyah',
      );

      expect(anggota.nik, '1234567890123456');
      expect(anggota.nama, 'Siti Aisyah');

      // nullable fields should be null by default
      expect(anggota.tempatLahir, isNull);
      expect(anggota.tanggalLahir, isNull);
      expect(anggota.jenisKelamin, isNull);
      expect(anggota.agama, isNull);
      expect(anggota.golonganDarah, isNull);
      expect(anggota.telepon, isNull);
      expect(anggota.pendidikanTerakhir, isNull);
      expect(anggota.pekerjaan, isNull);
      expect(anggota.peranKeluarga, isNull);
      expect(anggota.statusPenduduk, isNull);
      expect(anggota.namaKeluarga, isNull);
    });

    test('should assign all optional fields correctly', () {
      final anggota = AnggotaDetail(
        nik: '1112223334445556',
        nama: 'Budi Santoso',
        tempatLahir: 'Bandung',
        tanggalLahir: DateTime(2000, 5, 20),
        jenisKelamin: 'Laki-Laki',
        agama: 'Islam',
        golonganDarah: 'O',
        telepon: '081234567890',
        pendidikanTerakhir: 'S1',
        pekerjaan: 'Programmer',
        peranKeluarga: 'Anak',
        statusPenduduk: 'Tetap',
        namaKeluarga: 'Keluarga Santoso',
      );

      expect(anggota.tempatLahir, 'Bandung');
      expect(anggota.tanggalLahir, DateTime(2000, 5, 20));
      expect(anggota.jenisKelamin, 'Laki-Laki');
      expect(anggota.agama, 'Islam');
      expect(anggota.golonganDarah, 'O');
      expect(anggota.telepon, '081234567890');
      expect(anggota.pendidikanTerakhir, 'S1');
      expect(anggota.pekerjaan, 'Programmer');
      expect(anggota.peranKeluarga, 'Anak');
      expect(anggota.statusPenduduk, 'Tetap');
      expect(anggota.namaKeluarga, 'Keluarga Santoso');
    });

    test('two different instances should not be equal', () {
      final a = AnggotaDetail(nik: '1001', nama: 'A');
      final b = AnggotaDetail(nik: '1002', nama: 'B');

      expect(a == b, false);
    });

    test('model can be stored in a list', () {
      final anggota = AnggotaDetail(nik: '999', nama: 'Test User');

      final list = [anggota];

      expect(list.length, 1);
      expect(list.first.nik, '999');
    });
  });
}
