import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/models/pie_card_model.dart';

void main() {
  group('PieCardModel', () {
    test('should create PieCardModel with correct data and label', () {
      final sectionData = PieChartSectionData(
        value: 40,
        color: const Color(0xFF4E46B4),
        title: '40%',
        radius: 50,
      );
      final model = PieCardModel(data: sectionData, label: 'Pemasukan');

      expect(model.data.value, 40);
      expect(model.data.title, '40%');
      expect(model.data.radius, 50);
      expect(model.label, 'Pemasukan');
    });

    test('should allow different labels and values', () {
      final sectionData = PieChartSectionData(
        value: 60,
        color: const Color(0xFFEF4444),
        title: '60%',
        radius: 40,
      );
      final model = PieCardModel(data: sectionData, label: 'Pengeluaran');

      expect(model.data.value, 60);
      expect(model.data.title, '60%');
      expect(model.data.radius, 40);
      expect(model.label, 'Pengeluaran');
    });
  });
}
