import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/logaktivitas_model.dart';

void main() {
  group('LogAktivitas Model Test', () {
    test('constructor assigns values correctly', () {
      final log = LogAktivitas(
        judul: 'Tambah Data',
        user: 'Admin',
        tanggal: '2025-01-10',
        type: 'CREATE',
      );

      expect(log.judul, 'Tambah Data');
      expect(log.user, 'Admin');
      expect(log.tanggal, '2025-01-10');
      expect(log.type, 'CREATE');
    });

    test('multiple instances should hold independent values', () {
      final log1 = LogAktivitas(
        judul: 'Login',
        user: 'User1',
        tanggal: '2025-01-01',
        type: 'AUTH',
      );

      final log2 = LogAktivitas(
        judul: 'Logout',
        user: 'User2',
        tanggal: '2025-01-02',
        type: 'AUTH',
      );

      expect(log1.judul, isNot(equals(log2.judul)));
      expect(log1.user, isNot(equals(log2.user)));
    });

    test('can be added to list and read back correctly', () {
      final logs = [
        LogAktivitas(
          judul: 'Edit Profil',
          user: 'Farah',
          tanggal: '2025-01-05',
          type: 'UPDATE',
        )
      ];

      expect(logs.length, 1);
      expect(logs.first.user, 'Farah');
    });

    test('can be serialized into map manually (if needed)', () {
      final log = LogAktivitas(
        judul: 'Hapus Data',
        user: 'Admin2',
        tanggal: '2025-01-12',
        type: 'DELETE',
      );

      final map = {
        'judul': log.judul,
        'user': log.user,
        'tanggal': log.tanggal,
        'type': log.type,
      };

      expect(map['judul'], 'Hapus Data');
      expect(map['user'], 'Admin2');
      expect(map['tanggal'], '2025-01-12');
      expect(map['type'], 'DELETE');
    });
  });
}
