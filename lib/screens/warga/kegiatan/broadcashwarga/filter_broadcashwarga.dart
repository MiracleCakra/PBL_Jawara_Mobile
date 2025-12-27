import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BroadcastFilterScreen extends StatefulWidget {
  final DateTime? initialDate;

  const BroadcastFilterScreen({super.key, this.initialDate});

  @override
  State<BroadcastFilterScreen> createState() => _BroadcastFilterScreenState();
}

class _BroadcastFilterScreenState extends State<BroadcastFilterScreen> {
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    if (_selectedDate != null) {
      _dateController.text = _dateFormat.format(_selectedDate!);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Dibuat',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _dateFormat.format(picked);
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _selectedDate = null;
      _dateController.clear();
    });
    Navigator.pop(context, {'date': null});
  }

  void _applyFilter() {
    final Map<String, dynamic> filterData = {
      'date': _selectedDate,
    };
    Navigator.pop(context, filterData);
  }

  Widget _buildDateField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            hintText: '--/--/----',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)), borderSide: BorderSide(color: Colors.grey)),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () { setState(() { _selectedDate = null; _dateController.clear(); }); }),
                IconButton(icon: const Icon(Icons.calendar_month, color: Colors.grey), onPressed: () => _selectDate(context)),
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
          const Text('Filter Broadcast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Divider(height: 20),
          
          // Input Tanggal
          _buildDateField('Tanggal Dibuat'),
          const SizedBox(height: 24),

          const Spacer(),

          // Tombol Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  key: const Key('filter_reset_button'),
                  onPressed: _resetFilter, 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))), child: const Text('Reset Filter')),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  key: const Key('filter_apply_button'),
                  onPressed: _applyFilter, 
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))), child: const Text('Terapkan')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}