import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/iuran_model.dart';
import 'package:moon_design/moon_design.dart';

class TagihIuranScreen extends StatefulWidget {
  const TagihIuranScreen({super.key});

  @override
  State<TagihIuranScreen> createState() => _TagihIuranScreenState();
}

class _TagihIuranScreenState extends State<TagihIuranScreen> {
  IuranOption? _selectedJenisIuran;
  DateTime _selectedDate = DateTime.now();
  List<IuranOption> _jenisIuranOptions =
      []; // Store fetched options as IuranOption
  IuranModel iuranModel = IuranModel(
    namaIuran: '',
    jenisIuran: '',
    nominal: 0.0,
  );

  @override
  void initState() {
    super.initState();
    _fetchJenisIuran();
  }

  // Fetch 'id' and 'nama' from Supabase
  Future<void> _fetchJenisIuran() async {
    List<IuranOption> options = await iuranModel.fetchNamaIuran();
    setState(() {
      _jenisIuranOptions = options;
      if (_jenisIuranOptions.isNotEmpty) {
        _selectedJenisIuran =
            _jenisIuranOptions[0]; // Set default selection if options are available
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedJenisIuran = null;
      _selectedDate = DateTime.now();
    });
  }

  void _tagihIuran() {
    if (_selectedJenisIuran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih jenis iuran terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    iuranModel.saveTagihanForAllFamilies(
      _selectedJenisIuran!.id.toString(),
      _selectedDate,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iuran $_selectedJenisIuran berhasil ditagihkan'),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );

    _resetForm();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: Text(
          "Tagihan Iuran",
          style: MoonTokens.light.typography.heading.text20.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Tagih Iuran ke Semua Keluarga Aktif',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Jenis Iuran Label
                  const Text(
                    'Jenis Iuran',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),

                  // Dropdown Jenis Iuran
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: _jenisIuranOptions.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(),
                          ) // Show loading until data is fetched
                        : DropdownButtonFormField<IuranOption>(
                            value: _selectedJenisIuran,
                            hint: Text(
                              '-- Pilih Iuran --',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                            ),
                            items: _jenisIuranOptions.map((IuranOption option) {
                              return DropdownMenuItem<IuranOption>(
                                value: option,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .category, // You can use different icons here
                                      color: Color(
                                        0xFF6366F1,
                                      ), // Use a default color for now
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      option.nama,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (IuranOption? newValue) {
                              setState(() {
                                _selectedJenisIuran = newValue;
                              });
                            },
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Tanggal Label
                  const Text(
                    'Tanggal',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),

                  // Date Picker
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetForm,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _tagihIuran,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Tagih Iuran',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
