import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogFilterScreen extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const LogFilterScreen({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<LogFilterScreen> createState() => _LogFilterScreenState();
}

class _LogFilterScreenState extends State<LogFilterScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    if (_startDate != null) {
      _startDateController.text = _dateFormat.format(_startDate!);
    }
    if (_endDate != null) {
      _endDateController.text = _dateFormat.format(_endDate!);
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = _dateFormat.format(picked);
        // Reset End Date if it becomes invalid (before start date)
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
          _endDateController.clear();
        }
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _startDateController.clear();
      _endDateController.clear();
    });
    Navigator.pop(context, {'startDate': null, 'endDate': null});
  }

  void _applyFilter() {
    final Map<String, dynamic> filterData = {
      'startDate': _startDate,
      'endDate': _endDate,
    };
    Navigator.pop(context, filterData);
  }

  Widget _buildDateField(String label, TextEditingController controller, VoidCallback onTap, VoidCallback onClear, bool isSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: '--/--/----',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)), borderSide: BorderSide(color: Colors.grey)),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: onClear),
                IconButton(icon: const Icon(Icons.calendar_month, color: Colors.grey), onPressed: onTap),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Filter Log Aktivitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Divider(height: 20),
          
          // Input Tanggal
          _buildDateField('Tanggal', _startDateController, () => _selectStartDate(context), () {
             setState(() { _startDate = null; _startDateController.clear(); });
          }, _startDate != null),

          const SizedBox(height: 24),

          const Spacer(),

          // Tombol Reset & Terapkan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))
                  ),
                  child: const Text('Reset Filter'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E46B4), // Hardcoded primary from other screens if context primary isn't set
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))
                  ),
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
