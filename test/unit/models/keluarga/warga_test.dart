import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/models/keluarga/warga_model.dart';

void main() {
  group('Warga Model Test', () {
    test('fromJson parses correctly', () {
      final json = {
        "id": "W001",
        "nama": "Budi",
        "gender": "Pria",
        "gol_darah": "A+",
        "status_penduduk": "Aktif",
        "status_hidup_wafat": "Hidup",
        "keluarga": {
          "id": "K123",
          "nama_keluarga": "Keluarga Budi",
          "kepala_keluarga_id": "W001",
          "alamat_rumah": "Jl. Mawar",
          "status_kepemilikan": "Milik Sendiri",
          "status_keluarga": "Aktif"
        }
      };

      final warga = Warga.fromJson(json);

      expect(warga.id, "W001");
      expect(warga.nama, "Budi");
      expect(warga.gender?.value, "Pria");
      expect(warga.golDarah?.value, "A+");
      expect(warga.statusPenduduk?.value, "Aktif");
      expect(warga.statusHidupWafat?.value, "Hidup");

      // Cek nested keluarga
      expect(warga.keluarga?.id, "K123");
      expect(warga.keluarga?.namaKeluarga, "Keluarga Budi");
    });

    test('toJson outputs correct map', () {
      final warga = Warga(
        id: "W001",
        nama: "Budi",
        gender: Gender.lakilaki,
        golDarah: GolonganDarah.aPositif,
        statusPenduduk: StatusPenduduk.aktif,
        statusHidupWafat: StatusHidup.hidup,
      );

      final map = warga.toJson();

      expect(map['id'], "W001");
      expect(map['nama'], "Budi");
      expect(map['gender'], "Pria");
      expect(map['gol_darah'], "A+");
      expect(map['status_penduduk'], "Aktif");
      expect(map['status_hidup_wafat'], "Hidup");
    });
  });
}
