import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/aspirasi_model.dart';

void main() {
  group('AspirasiModel Tests', () {
    final now = DateTime.now();

    final mapData = {
      'id': 1,
      'pengirim': 'Budi',
      'judul': 'Lampu Jalan Mati',
      'tanggal': now.toIso8601String(),
      'isi': 'Mohon perbaikan lampu jalan di RT 02',
      'status': 'Pending',
      'user_id': 'user123',
      'created_at': now.toIso8601String(),
    };

    test('fromMap() harus membuat object yang benar', () {
      final model = AspirasiModel.fromMap(mapData);

      expect(model.id, 1);
      expect(model.pengirim, 'Budi');
      expect(model.judul, 'Lampu Jalan Mati');
      expect(model.tanggal.toIso8601String(), now.toIso8601String());
      expect(model.isi, 'Mohon perbaikan lampu jalan di RT 02');
      expect(model.status, 'Pending');
      expect(model.userId, 'user123');
      expect(model.createdAt!.toIso8601String(), now.toIso8601String());
    });

    test('toMap() harus mengubah object ke map yang benar', () {
      final model = AspirasiModel.fromMap(mapData);
      final result = model.toMap();

      expect(result['id'], 1);
      expect(result['pengirim'], 'Budi');
      expect(result['judul'], 'Lampu Jalan Mati');
      expect(result['tanggal'], now.toIso8601String());
      expect(result['isi'], 'Mohon perbaikan lampu jalan di RT 02');
      expect(result['status'], 'Pending');
      expect(result['user_id'], 'user123');

      /// createdAt sengaja tidak ada di toMap() → sesuai model kamu
      expect(result.containsKey('created_at'), false);
    });

    test('toJson() dan fromJson() harus konsisten', () {
      final model = AspirasiModel.fromMap(mapData);
      final jsonString = model.toJson();

      final fromJson = AspirasiModel.fromJson(jsonString);

      expect(fromJson.pengirim, model.pengirim);
      expect(fromJson.judul, model.judul);
      expect(fromJson.tanggal.toIso8601String(), model.tanggal.toIso8601String());
      expect(fromJson.isi, model.isi);
      expect(fromJson.status, model.status);
      expect(fromJson.userId, model.userId);
    });

    test('copyWith() harus menyalin data dengan perubahan yang benar', () {
      final model = AspirasiModel.fromMap(mapData);

      final updated = model.copyWith(
        status: 'Selesai',
        pengirim: 'Andi',
      );

      expect(updated.status, 'Selesai');
      expect(updated.pengirim, 'Andi');
      expect(updated.judul, model.judul); // tidak berubah
      expect(updated.id, model.id); // tidak berubah
    });

    test('fromMap() harus memberikan default value bila field tidak ada', () {
      final incompleteMap = {
        'tanggal': now.toIso8601String(),
      };

      final model = AspirasiModel.fromMap(incompleteMap);

      expect(model.pengirim, '');      // default
      expect(model.judul, '');         // default
      expect(model.isi, '');           // default
      expect(model.status, 'Pending'); // default
      expect(model.id, null);
      expect(model.userId, null);
    });
  });
}
