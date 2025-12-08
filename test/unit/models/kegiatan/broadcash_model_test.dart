import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/broadcast_model.dart';

void main() {
  group('BroadcastModel Tests', () {
    final now = DateTime.now();

    final mapData = {
      'id': 10,
      'judul': 'Pemberitahuan Penting',
      'pengirim': 'Admin RW',
      'tanggal': now.toIso8601String(),
      'kategori': 'Informasi',
      'konten': 'Besok akan ada pemadaman listrik.',
      'lampiranGambarUrl': 'https://image.com/gambar.png',
      'lampiranDokumen': 'https://docs.com/dokumen.pdf',
      'created_at': now.toIso8601String(),
    };

    test('fromMap harus menghasilkan model yang benar', () {
      final model = BroadcastModel.fromMap(mapData);

      expect(model.id, 10);
      expect(model.judul, 'Pemberitahuan Penting');
      expect(model.pengirim, 'Admin RW');
      expect(model.tanggal.toIso8601String(), now.toIso8601String());
      expect(model.kategori, 'Informasi');
      expect(model.konten, 'Besok akan ada pemadaman listrik.');
      expect(model.lampiranGambarUrl, 'https://image.com/gambar.png');
      expect(model.lampiranDokumenUrl, 'https://docs.com/dokumen.pdf');
      expect(model.createdAt!.toIso8601String(), now.toIso8601String());
    });

    test('fromMap harus handle lampiranDokumen null atau empty', () {
      final map1 = {
        'judul': 'Info',
        'pengirim': 'Admin',
        'tanggal': now.toIso8601String(),
        'kategori': 'Test',
        'konten': 'Konten',
        'lampiranDokumen': null,
      };

      final map2 = {
        'judul': 'Info',
        'pengirim': 'Admin',
        'tanggal': now.toIso8601String(),
        'kategori': 'Test',
        'konten': 'Konten',
        'lampiranDokumen': '',
      };

      final model1 = BroadcastModel.fromMap(map1);
      final model2 = BroadcastModel.fromMap(map2);

      expect(model1.lampiranDokumenUrl, null);
      expect(model2.lampiranDokumenUrl, null);
    });

    test('toMap harus menghasilkan map yang benar', () {
      final model = BroadcastModel.fromMap(mapData);
      final result = model.toMap();

      expect(result['id'], 10);
      expect(result['judul'], 'Pemberitahuan Penting');
      expect(result['pengirim'], 'Admin RW');
      expect(result['tanggal'], now.toIso8601String());
      expect(result['kategori'], 'Informasi');
      expect(result['konten'], 'Besok akan ada pemadaman listrik.');
      expect(result['lampiranGambarUrl'], 'https://image.com/gambar.png');
      expect(result['lampiranDokumen'], 'https://docs.com/dokumen.pdf');

      // createdAt memang tidak ikut dimapping → sesuai model
      expect(result.containsKey('created_at'), false);
    });

    test('toJson dan fromJson harus konsisten', () {
      final model = BroadcastModel.fromMap(mapData);

      final jsonString = model.toJson();
      final newModel = BroadcastModel.fromJson(jsonString);

      expect(newModel.judul, model.judul);
      expect(newModel.konten, model.konten);
      expect(newModel.kategori, model.kategori);
      expect(newModel.lampiranGambarUrl, model.lampiranGambarUrl);
      expect(newModel.lampiranDokumenUrl, model.lampiranDokumenUrl);
    });

    test('copyWith harus menyalin dan mengubah data tertentu saja', () {
      final model = BroadcastModel.fromMap(mapData);

      final updated = model.copyWith(
        judul: 'Update Baru',
        kategori: 'Darurat',
      );

      expect(updated.judul, 'Update Baru');
      expect(updated.kategori, 'Darurat');

      // Field lain tetap
      expect(updated.pengirim, model.pengirim);
      expect(updated.konten, model.konten);
      expect(updated.tanggal, model.tanggal);
    });

    test('fromMap harus memberikan default value yang benar jika field hilang', () {
      final incompleteMap = {
        'tanggal': now.toIso8601String(),
      };

      final model = BroadcastModel.fromMap(incompleteMap);

      expect(model.judul, '');     // default
      expect(model.pengirim, '');  // default
      expect(model.kategori, '');  // default
      expect(model.konten, '');    // default

      expect(model.lampiranDokumenUrl, null);
      expect(model.lampiranGambarUrl, null);
      expect(model.id, null);
    });
  });
}
