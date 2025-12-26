import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:SapaWarga_kel_2/constants/constant_colors.dart';

void main() {
  group('ConstantColors', () {
    test('separatorColor should have correct value', () {
      expect(
        ConstantColors.separatorColor,
        const Color(0xff595D62),
      );
    });

    test('foreground2 should have correct value', () {
      expect(
        ConstantColors.foreground2,
        const Color(0xff57525F),
      );
    });

    test('primary should have correct value', () {
      expect(
        ConstantColors.primary,
        const Color(0xff6162E9),
      );
    });
  });
}
