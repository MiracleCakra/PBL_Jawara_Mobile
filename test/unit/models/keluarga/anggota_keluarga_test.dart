import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/models/keluarga/anggota_keluarga_model.dart';

void main() {
  group("Anggota Model Test", () {
    test("constructor assigns values correctly", () {
      final anggota = Anggota(
        nik: "123",
        nama: "Test User",
        jenisKelamin: "Pria",
      );

      expect(anggota.nik, "123");
      expect(anggota.nama, "Test User");
      expect(anggota.jenisKelamin, "Pria");

      // nullable fields
      expect(anggota.tempatLahir, isNull);
      expect(anggota.tanggalLahir, isNull);
      expect(anggota.email, isNull);
      expect(anggota.status, "Aktif"); // default value
    });

    test("fromJson parses correctly", () {
      final json = {
        "nik": "001",
        "nama": "Joko",
        "tempat_lahir": "Malang",
        "tanggal_lahir": "2000-01-10",
        "jenis_kelamin": "Pria",
        "agama": "Islam",
        "golongan_darah": "O",
        "telepon": "0811",
        "email": "test@mail.com",
        "pendidikan_terakhir": "SMA",
        "pekerjaan": "Pelajar",
        "peran_keluaga": "Anak",
        "status_penduduk": "Tetap",
        "status_hidup": "Hidup",
        "nama_keluarga": "Keluarga A",
        "status": "Aktif",
        "foto_ktp": "image.png",
        "rumah_saat_ini": "Jl Mawar",
      };

      final anggota = Anggota.fromJson(json);

      expect(anggota.nik, "001");
      expect(anggota.nama, "Joko");
      expect(anggota.tempatLahir, "Malang");
      expect(anggota.tanggalLahir, DateTime(2000, 1, 10));
      expect(anggota.jenisKelamin, "Pria");
      expect(anggota.agama, "Islam");
      expect(anggota.golonganDarah, "O");
      expect(anggota.telepon, "0811");
      expect(anggota.email, "test@mail.com");
      expect(anggota.fotoKtp, "image.png");
      expect(anggota.rumahSaatIni, "Jl Mawar");
    });

    test("toJson outputs correct keys", () {
      final anggota = Anggota(
        nik: "555",
        nama: "Ani",
        agama: "Islam",
        jenisKelamin: "Wanita",
      );

      final json = anggota.toJson();

      expect(json["nik"], "555");
      expect(json["nama"], "Ani");
      expect(json["agama"], "Islam");
      expect(json["jenis_kelamin"], "Wanita");
    });

    test("copyWith modifies only specified fields", () {
      final anggota = Anggota(
        nik: "100",
        nama: "Original",
      );

      final copy = anggota.copyWith(
        nama: "Updated",
        telepon: "08123",
      );

      expect(copy.nik, "100"); // tidak berubah
      expect(copy.nama, "Updated");
      expect(copy.telepon, "08123");
    });

    test("dummyAnggota should contain valid data", () {
      expect(dummyAnggota.length, greaterThan(0));

      final first = dummyAnggota.first;

      expect(first.nik, isNotEmpty);
      expect(first.nama, isNotEmpty);
      expect(first.status, isNotNull);
    });

    test("tanggal lahir should parse null safely", () {
      final json = {
        "nik": "100",
        "nama": "Tanpa Tanggal",
        "tanggal_lahir": null,
      };

      final anggota = Anggota.fromJson(json);

      expect(anggota.tanggalLahir, isNull);
    });
  });
}
