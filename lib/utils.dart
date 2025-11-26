import 'package:flutter/material.dart';

Color getPrimaryColor(BuildContext context) =>
    Theme.of(context).colorScheme.primary;

Future<DateTime?> openDateTimePicker(BuildContext context) {
  final now = DateTime.now();
  final firstDate = DateTime(now.year - 100, now.month, now.day);
  final lastDate = DateTime(now.year + 100, now.month, now.day);
  return showDatePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDate: now,
  );
}

String formatDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final dd = d.day.toString().padLeft(2, '0');
  final mmm = months[d.month - 1];
  return '$dd $mmm ${d.year}';
}

String formatRupiah(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  int count = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    buf.write(s[i]);
    count++;
    if (count % 3 == 0 && i != 0) buf.write('.');
  }
  final withDots = buf.toString().split('').reversed.join();
  return 'Rp $withDots';
}
int unformatRupiah(String value) {
  final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');

  if (cleaned.isEmpty) return 0;

  return int.parse(cleaned);
}