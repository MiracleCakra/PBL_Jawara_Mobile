import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/utils.dart';

void main() {
  group('Utils - formatDate', () {
    test('formatDate formats date correctly', () {
      final date = DateTime(2024, 1, 5);
      final result = formatDate(date);

      expect(result, '05 Jan 2024');
    });

    test('formatDate pads single digit day', () {
      final date = DateTime(2023, 12, 1);
      expect(formatDate(date), '01 Des 2023');
    });
  });

  group('Utils - formatRupiah', () {
    test('formatRupiah formats thousands correctly', () {
      expect(formatRupiah(1000), 'Rp 1.000');
      expect(formatRupiah(15000), 'Rp 15.000');
      expect(formatRupiah(1500000), 'Rp 1.500.000');
    });

    test('formatRupiah handles zero', () {
      expect(formatRupiah(0), 'Rp 0');
    });
  });

  group('Utils - unformatRupiah', () {
    test('unformatRupiah removes symbols and dots', () {
      expect(unformatRupiah('Rp 1.000'), 1000);
      expect(unformatRupiah('Rp 15.000'), 15000);
      expect(unformatRupiah('Rp 1.500.000'), 1500000);
    });

    test('unformatRupiah handles empty string', () {
      expect(unformatRupiah(''), 0);
    });

    test('unformatRupiah handles non-numeric input', () {
      expect(unformatRupiah('Rp abc'), 0);
    });
  });
}
