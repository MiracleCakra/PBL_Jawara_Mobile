import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/keluarga_model.dart' as k_model;
import 'package:jawara_pintar_kel_5/services/keluarga_service.dart';
import 'package:jawara_pintar_kel_5/widget/moon_result_modal.dart';

class TambahMutasiKeluargaPage extends StatefulWidget {
  const TambahMutasiKeluargaPage({super.key});

  @override
  State<TambahMutasiKeluargaPage> createState() =>
      _TambahMutasiKeluargaPageState();
}

class _TambahMutasiKeluargaPageState extends State<TambahMutasiKeluargaPage> {
  static const Color _primaryColor = Color(0xFF4E46B4);

  final _formKey = GlobalKey<FormState>();
  final _alasanMutasiController = TextEditingController();
  final _tanggalMutasiController = TextEditingController();
  final _alamatBaruController = TextEditingController();
  final _keluargaService = KeluargaService();

  String? _selectedJenisMutasi;
  k_model.Keluarga? _selectedKeluarga;

  late Future<List<k_model.Keluarga>> _keluargaListFuture;

  final List<String> _jenisMutasiOptions = ['Keluar Wilayah', 'Pindah Rumah'];

  @override
  void initState() {
    super.initState();
    _keluargaListFuture = _keluargaService.getAllKeluarga();
  }

  @override
  void dispose() {
    _alasanMutasiController.dispose();
    _tanggalMutasiController.dispose();
    _alamatBaruController.dispose();
    super.dispose();
  }

  Future<void> _selectTanggalMutasi() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 5);
    final last = DateTime(now.year + 5);

    DateTime initial = _parseDate(_tanggalMutasiController.text) ?? now;
    DateTime selected = initial;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: Colors.black.withOpacity(0.4),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return Theme(
          data: Theme.of(sheetCtx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            datePickerTheme: DatePickerThemeData(
              dayShape: WidgetStateProperty.resolveWith<OutlinedBorder?>(
                (states) => const CircleBorder(),
              ),
              dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) => states.contains(WidgetState.selected)
                    ? _primaryColor
                    : null,
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
                      'Pilih Tanggal Mutasi',
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
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _tanggalMutasiController.text = _formatDate(
                                  selected,
                                );
                              });
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

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_tanggalMutasiController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal mutasi harus dipilih'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      String newAlamat = _selectedKeluarga!.alamatRumah;
      String newStatus = _selectedKeluarga!.statusKeluarga;

      if (_selectedJenisMutasi == 'Pindah Rumah') {
        newAlamat = _alamatBaruController.text;
      } else if (_selectedJenisMutasi == 'Keluar Wilayah') {
        newStatus = 'Nonaktif';
      }

      final updatedKeluarga = k_model.Keluarga(
        id: _selectedKeluarga!.id,
        namaKeluarga: _selectedKeluarga!.namaKeluarga,
        kepalaKeluargaId: _selectedKeluarga!.kepalaKeluargaId,
        alamatRumah: newAlamat,
        statusKepemilikan: _selectedKeluarga!.statusKepemilikan,
        statusKeluarga: newStatus,
        jenisMutasi: _selectedJenisMutasi,
        alasanMutasi: _alasanMutasiController.text,
        tanggalMutasi: _parseDate(_tanggalMutasiController.text),
      );

      try {
        await _keluargaService.updateKeluarga(
            _selectedKeluarga!.id, updatedKeluarga);
        await showResultModal(
          context,
          type: ResultType.success,
          title: 'Berhasil',
          description: 'Data mutasi keluarga berhasil disimpan.',
          actionLabel: 'Selesai',
          autoProceed: true,
        );
        if (context.mounted) context.pop(true);
      } catch (e) {
        await showResultModal(
          context,
          type: ResultType.error,
          title: 'Gagal',
          description: 'Gagal menyimpan data mutasi keluarga: $e',
          actionLabel: 'OK',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Buat Mutasi Keluarga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionCard(
              title: 'Informasi Mutasi',
              children: [
                _buildJenisMutasiDropdown(),
                const SizedBox(height: 16),
                _buildKeluargaDropdown(),
                const SizedBox(height: 16),
                if (_selectedJenisMutasi == 'Pindah Rumah')
                  _buildAlamatBaruField(),
                if (_selectedJenisMutasi != null) ...[
                  const SizedBox(height: 16),
                  _buildAlasanMutasiField(),
                  const SizedBox(height: 16),
                  _buildTanggalMutasiField(),
                ]
              ],
            ),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildJenisMutasiDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Jenis Mutasi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedJenisMutasi,
          isExpanded: true,
          decoration: _inputDecoration('-- Pilih Jenis Mutasi --'),
          hint: const Text('-- Pilih Jenis Mutasi --'),
          items: _jenisMutasiOptions
              .map(
                (jenis) => DropdownMenuItem(value: jenis, child: Text(jenis)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedJenisMutasi = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jenis mutasi harus dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildKeluargaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Keluarga',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<k_model.Keluarga>>(
          future: _keluargaListFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final keluargaList = snapshot.data!;
            return DropdownButtonFormField<k_model.Keluarga>(
              value: _selectedKeluarga,
              isExpanded: true,
              decoration: _inputDecoration('-- Pilih Keluarga --'),
              hint: const Text('-- Pilih Keluarga --'),
              items: keluargaList
                  .map(
                    (keluarga) => DropdownMenuItem(
                        value: keluarga, child: Text(keluarga.namaKeluarga)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKeluarga = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Keluarga harus dipilih';
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlamatBaruField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Alamat Baru',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _alamatBaruController,
          maxLines: 5,
          decoration: _inputDecoration('Masukkan alamat baru disini...'),
          validator: (value) {
            if (_selectedJenisMutasi == 'Pindah Rumah' &&
                (value == null || value.trim().isEmpty)) {
              return 'Alamat baru harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAlasanMutasiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Alasan Mutasi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _alasanMutasiController,
          maxLines: 5,
          decoration: _inputDecoration('Masukkan alasan disini...'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Alasan mutasi harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTanggalMutasiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Tanggal Mutasi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTanggalMutasi,
          child: InputDecorator(
            decoration: _inputDecoration('--/--/----'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _tanggalMutasiController.text.isEmpty
                      ? '--/--/----'
                      : _tanggalMutasiController.text,
                  style: TextStyle(
                    color: _tanggalMutasiController.text.isEmpty
                        ? Colors.grey[400]
                        : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Simpan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
