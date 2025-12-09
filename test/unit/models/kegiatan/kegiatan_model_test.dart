import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/kegiatan_model.dart';

void main() {
  group('KegiatanModel Test', () {
    final mockMap = {
      'id': 10,
      'judul': 'Kerja Bakti',
      'pj': 'Budi',
      'tanggal': DateTime(2025, 1, 10).toIso8601String(),
      'kategori': 'Lingkungan',
      'lokasi': 'Balai RW',
      'deskripsi': 'Membersihkan selokan',
      'dibuat_oleh': 'Admin',
      'has_docs': 'true',
      'gambardokumentasi': 'img1.png',
      'created_at': DateTime(2025, 1, 1).toIso8601String(),
    };

    test('fromMap() parses correctly', () {
      final model = KegiatanModel.fromMap(mockMap);

      expect(model.id, 10);
      expect(model.judul, 'Kerja Bakti');
      expect(model.pj, 'Budi');
      expect(model.tanggal, DateTime(2025, 1, 10));
      expect(model.kategori, 'Lingkungan');
      expect(model.lokasi, 'Balai RW');
      expect(model.deskripsi, 'Membersihkan selokan');
      expect(model.dibuatOleh, 'Admin');
      expect(model.hasDocs, true);
      expect(model.gambarDokumentasi, 'img1.png');
      expect(model.createdAt, DateTime(2025, 1, 1));
    });

    test('toMap() converts correctly', () {
      final model = KegiatanModel.fromMap(mockMap);

      final map = model.toMap();

      expect(map['id'], 10);
      expect(map['judul'], 'Kerja Bakti');
      expect(map['pj'], 'Budi');
      expect(map['tanggal'], DateTime(2025, 1, 10).toIso8601String());
      expect(map['kategori'], 'Lingkungan');
      expect(map['lokasi'], 'Balai RW');
      expect(map['deskripsi'], 'Membersihkan selokan');
      expect(map['dibuat_oleh'], 'Admin');
      expect(map['has_docs'], true);
      expect(map['gambardokumentasi'], 'img1.png');
    });

    test('fromJson() works correctly', () {
      final jsonStr = KegiatanModel.fromMap(mockMap).toJson();
      final model = KegiatanModel.fromJson(jsonStr);

      expect(model.judul, 'Kerja Bakti');
      expect(model.pj, 'Budi');
      expect(model.hasDocs, true);
    });

    test('copyWith() returns updated values', () {
      final model = KegiatanModel.fromMap(mockMap);

      final updated = model.copyWith(
        judul: 'Rapat Warga',
        kategori: 'Organisasi',
        hasDocs: false,
      );

      expect(updated.judul, 'Rapat Warga');
      expect(updated.kategori, 'Organisasi');
      expect(updated.hasDocs, false);

      // field lain tetap sama
      expect(updated.pj, model.pj);
      expect(updated.lokasi, model.lokasi);
    });

    test('fromMap() handles null optional fields', () {
      final nullMap = {
        'judul': 'Tes',
        'pj': 'Aji',
        'tanggal': DateTime(2025, 1, 10).toIso8601String(),
        'kategori': 'Umum',
        'lokasi': 'Aula',
        'deskripsi': 'contoh'
      };

      final model = KegiatanModel.fromMap(nullMap);

      expect(model.id, null);
      expect(model.dibuatOleh, null);
      expect(model.hasDocs, false); // default (karena null -> false)
      expect(model.gambarDokumentasi, null);
      expect(model.createdAt, null);
    });
  });
}
