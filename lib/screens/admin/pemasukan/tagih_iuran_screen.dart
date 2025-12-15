import 'package:flutter/material.dart';
import 'package:SapaWarga_kel_2/models/keuangan/iuran_model.dart';
import 'package:moon_design/moon_design.dart';

class TagihIuranScreen extends StatefulWidget {
  const TagihIuranScreen({super.key});

  @override
  State<TagihIuranScreen> createState() => _TagihIuranScreenState();
}

class _TagihIuranScreenState extends State<TagihIuranScreen> {
  IuranOption? _selectedJenisIuran;
  DateTime _selectedDate = DateTime.now();
  List<IuranOption> _jenisIuranOptions = []; 
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

  // --- FUNGSI MODAL DIALOG BERHASIL BARU ---
  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Centang Hijau
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Judul
                const Text(
                  'Berhasil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Pesan Sesuai Gambar
                const Text(
                  'Tagihan Iuran berhasil dibuat untuk semua keluarga aktif.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Tombol Selesai
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup Dialog
                      Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // FUNGSI INI KINI MEMANGGIL MODAL
  void _tagihIuran() async {
    if (_selectedJenisIuran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih jenis iuran terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // 1. Proses Penagihan Data
    iuranModel.saveTagihanForAllFamilies(
      _selectedJenisIuran!.id.toString(),
      _selectedDate,
    );

    // 2. Tampilkan Modal Sukses dan Navigasi
    await _showSuccessDialog();

    // 3. Reset form setelah proses penagihan (opsional, tergantung UX)
    _resetForm();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // ... (kode build method Anda tetap sama)
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
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF6366F1),
                              ),
                            ),
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
                                      Icons.category, 
                                      color: const Color(
                                        0xFF6366F1,
                                      ), 
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

                  // Buttons (dibuat di luar SingleChildScrollView agar tetap di bawah)
                ],
              ),
            ),
          ),
          
          // Bottom Buttons (ditarik keluar dari SingleChildScrollView)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
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
            ),
          ),
        ],
      ),
    );
  }
}