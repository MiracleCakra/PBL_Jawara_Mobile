import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KegiatanFilterScreen extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialKategori;

  const KegiatanFilterScreen({
    super.key,
    this.initialDate,
    this.initialKategori,
  });

  @override
  State<KegiatanFilterScreen> createState() => _KegiatanFilterScreenState();
}

class _KegiatanFilterScreenState extends State<KegiatanFilterScreen> {
  DateTime? _selectedDate;
  String? _selectedKategori;

  final TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  final List<String> _kategoriList = [
    'Komunitas & Sosial',
    'Kebersihan dan Keamanan',
    'Keagamaan',
    'Pendidikan',
    'Kesehatan & Olahraga',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedKategori = widget.initialKategori;
    
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
      helpText: 'Pilih Tanggal Pelaksanaan',
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
      _selectedKategori = null;
      _dateController.clear();
    });
    Navigator.pop(context, {'date': null, 'kategori': null}); 
  }

  void _applyFilter() {
    final Map<String, dynamic> filterData = {
      'date': _selectedDate,
      'kategori': _selectedKategori,
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
          const Text('Filter Kegiatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Divider(height: 20),
           _buildDateField('Tanggal Pelaksanaan'),

          const Text('Kategori', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedKategori,
            hint: const Text('-- Pilih Kategori --'),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
            ),
            items: [null, ..._kategoriList].map((String? kategori) {
              return DropdownMenuItem<String>(
                value: kategori,
                child: Text(kategori ?? 'Semua Kategori'),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedKategori = (newValue == 'Semua Kategori') ? null : newValue;
              });
            },
          ),
          const SizedBox(height: 24),

          const Spacer(),

          //  Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(onPressed: _resetFilter, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))), child: const Text('Reset Filter')),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(onPressed: _applyFilter, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))), child: const Text('Terapkan')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}