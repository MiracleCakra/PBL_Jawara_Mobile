import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'input_decoration.dart';

class DatePickerField extends StatefulWidget {
  final String label;
  final String placeholder;
  final Color accentColor;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;

  const DatePickerField({
    super.key,
    required this.label,
    this.placeholder = 'Pilih Tanggal',
    this.accentColor = const Color(0xFF4E46B4),
    this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.selectedDate != null) {
      _controller.text = _formatDate(widget.selectedDate!);
    }
  }

  @override
  void didUpdateWidget(covariant DatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      if (widget.selectedDate != null) {
        _controller.text = _formatDate(widget.selectedDate!);
      } else {
        _controller.clear();
      }
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 80);
    final last = DateTime(now.year + 1);

    DateTime initial = widget.selectedDate ?? now;
    DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) || initial.isAfter(last) ? now : initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.accentColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      widget.onDateSelected(selected);
    }
  }

  String _formatDate(DateTime d) {
    return DateFormat('dd/MM/yyyy').format(d);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(context),
          child: AbsorbPointer(
            child: TextField(
              controller: _controller,
              readOnly: true,
              decoration: appInputDecoration(
                hintText: widget.placeholder,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
