import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/keluarga_model.dart'
    as keluarga_model;

void main() {
  group('Keluarga Model Test', () {
    test('fromJson parses correctly', () {
      final json = {
        "id": "K001",
        "nama_keluarga": "Keluarga Wijaya",
        "kepala_keluarga_id": "W001",
        "alamat_rumah": "Jl. Melati",
        "status_kepemilikan": "Milik Sendiri",
        "status_keluarga": "Aktif",
        "jenis_mutasi": "Masuk",
        "alasan_mutasi": "Pindah kota",
        "tanggal_mutasi": "2024-01-20T00:00:00.000Z",
        "warga": {"id": "W001", "nama": "Andi"},
      };

      final keluarga = keluarga_model.Keluarga.fromJson(json);

      expect(keluarga.id, "K001");
      expect(keluarga.namaKeluarga, "Keluarga Wijaya");
      expect(keluarga.kepalaKeluargaId, "W001");
      expect(keluarga.alamatRumah, "Jl. Melati");
      expect(keluarga.statusKepemilikan, "Milik Sendiri");
      expect(keluarga.statusKeluarga, "Aktif");

      // Mutasi
      expect(keluarga.jenisMutasi, "Masuk");
      expect(keluarga.alasanMutasi, "Pindah kota");
      expect(keluarga.tanggalMutasi?.year, 2024);

      // Nested kepala keluarga
      expect(keluarga.kepalaKeluarga?.id, "W001");
      expect(keluarga.kepalaKeluarga?.nama, "Andi");
    });

    test('toJson outputs correct map', () {
      final keluarga = keluarga_model.Keluarga(
        id: "K001",
        namaKeluarga: "Keluarga Wijaya",
        kepalaKeluargaId: "W001",
        alamatRumah: "Jl. Melati",
        statusKepemilikan: "Milik Sendiri",
        statusKeluarga: "Aktif",
        jenisMutasi: "Masuk",
        alasanMutasi: "Pindah",
        tanggalMutasi: DateTime(2024, 02, 10),
      );

      final map = keluarga.toJson();

      expect(map['id'], "K001");
      expect(map['nama_keluarga'], "Keluarga Wijaya");
      expect(map['kepala_keluarga_id'], "W001");
      expect(map['alamat_rumah'], "Jl. Melati");
      expect(map['status_kepemilikan'], "Milik Sendiri");
      expect(map['status_keluarga'], "Aktif");
      expect(map['jenis_mutasi'], "Masuk");
      expect(map['alasan_mutasi'], "Pindah");
      expect(map['tanggal_mutasi'], "2024-02-10T00:00:00.000");
    });
  });
}
