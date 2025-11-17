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

  // Fungsi  Date Picker
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      helpText: isStart ? 'Pilih Tanggal Mulai' : 'Pilih Tanggal Selesai',
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = _dateFormat.format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = _dateFormat.format(picked);
        }
      });
    }
  }

  // Fungsi reset filter
  void _resetFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _startDateController.clear();
      _endDateController.clear();
    });
    
    Navigator.pop(context, {'startDate': null, 'endDate': null}); 
  }

  // Fungsi filter
  void _applyFilter() {
    if (_startDate != null && _endDate != null && _startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal Mulai tidak boleh setelah Tanggal Selesai!')),
      );
      return;
    }
    final Map<String, dynamic> filterData = {
      'startDate': _startDate,
      'endDate': _endDate,
    };

    Navigator.pop(context, filterData);
  }

  // Widget pembantu input tanggal
  Widget _buildDateField(String label, TextEditingController controller, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true, 
          onTap: () => _selectDate(context, isStart), 
          decoration: InputDecoration(
            hintText: '--/--/----',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Hapus
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      if (isStart) {
                        _startDate = null;
                      } else {
                        _endDate = null;
                      }
                      controller.clear();
                    });
                  },
                ),
                // Tombol Kalender
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.grey),
                  onPressed: () => _selectDate(context, isStart),
                ),
                const SizedBox(width: 8), 
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
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
          // Header Judul
          const Text(
            'Filter Berdasarkan Rentang Tanggal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 20),
          _buildDateField('Dari Tanggal', _startDateController, true),
          _buildDateField('Sampai Tanggal', _endDateController, false),
          const Spacer(),
          // Tombol Reset dan Terapkan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Reset Filter
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text('Reset Filter'),
                ),
              ),
              const SizedBox(width: 16),
              // Tombol Terapkan
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
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