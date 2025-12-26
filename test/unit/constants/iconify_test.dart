import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/constants/iconify.dart';

void main() {
  group('IconifyConstants', () {
    test('fluentPeopleLight should contain valid svg', () {
      expect(IconifyConstants.fluentPeopleLight, isNotEmpty);
      expect(IconifyConstants.fluentPeopleLight.startsWith('<svg'), true);
    });

    test('letsIconMoneyLight should contain valid svg', () {
      expect(IconifyConstants.letsIconMoneyLight, isNotEmpty);
      expect(IconifyConstants.letsIconMoneyLight.startsWith('<svg'), true);
    });

    test('arcticonActiviyManager should contain valid svg', () {
      expect(IconifyConstants.arcticonActiviyManager, isNotEmpty);
      expect(
        IconifyConstants.arcticonActiviyManager.startsWith('<svg'),
        true,
      );
    });

    test('fluentMoreHorizontalREG should contain valid svg', () {
      expect(IconifyConstants.fluentMoreHorizontalREG, isNotEmpty);
      expect(
        IconifyConstants.fluentMoreHorizontalREG.startsWith('<svg'),
        true,
      );
    });

    test('fluentArrowUp should contain valid svg', () {
      expect(IconifyConstants.fluentArrowUp, isNotEmpty);
      expect(IconifyConstants.fluentArrowUp.startsWith('<svg'), true);
    });

    test('fluentArrowDown should contain valid svg', () {
      expect(IconifyConstants.fluentArrowDown, isNotEmpty);
      expect(IconifyConstants.fluentArrowDown.startsWith('<svg'), true);
    });

    test('storeIconFlat should contain valid svg', () {
      expect(IconifyConstants.storeIconFlat, isNotEmpty);
      expect(IconifyConstants.storeIconFlat.startsWith('<svg'), true);
    });
  });
}
