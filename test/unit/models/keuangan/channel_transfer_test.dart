import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/models/keuangan/channel_transfer_model.dart';

void main() {
  group('ChannelTransferModel Test', () {
    test('fromMap parses correctly', () {
      final map = {
        "id": 1,
        "nama": "BCA",
        "tipe": "Bank",
        "norek": "123456789",
        "pemilik": "Budi",
        "catatan": "Transfer rutin",
        "qris_img": "https://example.com/qris.png",
        "created_at": "2024-01-20T00:00:00.000Z",
      };

      final channel = ChannelTransferModel.fromMap(map);

      expect(channel.id, 1);
      expect(channel.nama, "BCA");
      expect(channel.tipe, "Bank");
      expect(channel.norek, "123456789");
      expect(channel.pemilik, "Budi");
      expect(channel.catatan, "Transfer rutin");
      expect(channel.qrisImg, "https://example.com/qris.png");
      expect(channel.createdAt?.year, 2024);
      expect(channel.createdAt?.month, 1);
      expect(channel.createdAt?.day, 20);
    });

    test('toMap returns correct map', () {
      final channel = ChannelTransferModel(
        id: 1,
        nama: "BCA",
        tipe: "Bank",
        norek: "123456789",
        pemilik: "Budi",
        catatan: "Transfer rutin",
        qrisImg: "https://example.com/qris.png",
      );

      final map = channel.toMap();

      expect(map['id'], 1);
      expect(map['nama'], "BCA");
      expect(map['tipe'], "Bank");
      expect(map['norek'], "123456789");
      expect(map['pemilik'], "Budi");
      expect(map['catatan'], "Transfer rutin");
      expect(map['qris_img'], "https://example.com/qris.png");
    });

    test('copyWith returns modified object', () {
      final channel = ChannelTransferModel(
        id: 1,
        nama: "BCA",
        tipe: "Bank",
        norek: "123456789",
        pemilik: "Budi",
        catatan: "Transfer rutin",
      );

      final updated = channel.copyWith(nama: "Mandiri", norek: "987654321");

      expect(updated.id, 1);
      expect(updated.nama, "Mandiri");
      expect(updated.norek, "987654321");
      expect(updated.pemilik, "Budi"); // tidak berubah
    });

    test('fromJson and toJson work correctly', () {
      final jsonString = '''
      {
        "id": 1,
        "nama": "BCA",
        "tipe": "Bank",
        "norek": "123456789",
        "pemilik": "Budi",
        "catatan": "Transfer rutin",
        "qris_img": "https://example.com/qris.png"
      }
      ''';

      final channel = ChannelTransferModel.fromJson(jsonString);
      expect(channel.nama, "BCA");
      expect(channel.tipe, "Bank");

      final jsonOutput = channel.toJson();
      expect(jsonOutput.contains('"nama":"BCA"'), true);
      expect(jsonOutput.contains('"tipe":"Bank"'), true);
    });
  });
}
