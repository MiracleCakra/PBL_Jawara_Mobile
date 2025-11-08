import 'package:flutter/material.dart';
import 'input_decoration.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final Color accentColor;

  const DatePickerField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder = 'Pilih Tanggal',
    this.accentColor = const Color(0xFF4E46B4),
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 80);
    final last = DateTime(now.year + 1);

    // Ambil initial date dari controller jika ada.
    DateTime initial = _parseDate(controller.text) ?? now;
    DateTime selected = initial;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return Theme(
          data: Theme.of(sheetCtx).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            datePickerTheme: DatePickerThemeData(
              dayShape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
                (states) => const CircleBorder(),
              ),
              dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) =>
                    states.contains(WidgetState.selected) ? accentColor : null,
              ),
              dayForegroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) =>
                    states.contains(WidgetState.selected) ? Colors.white : null,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: FractionallySizedBox(
              heightFactor: 0.75,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pilih Tanggal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: CalendarDatePicker(
                        initialDate:
                            initial.isBefore(first) || initial.isAfter(last)
                            ? now
                            : initial,
                        firstDate: first,
                        lastDate: last,
                        onDateChanged: (d) => selected = d,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetCtx).pop(),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              controller.text = _formatDate(selected);
                              Navigator.of(sheetCtx).pop();
                            },
                            child: const Text('Pilih'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day/$month/$year';
  }

  DateTime? _parseDate(String text) {
    if (text.isEmpty) return null;
    try {
      final parts = text.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(context),
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              readOnly: true,
              decoration: appInputDecoration(
                hintText: placeholder,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
