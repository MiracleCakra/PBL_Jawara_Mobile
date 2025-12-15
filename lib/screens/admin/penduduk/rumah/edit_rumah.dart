import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/screens/admin/penduduk/rumah/daftar_rumah.dart';
import 'package:SapaWarga_kel_2/widget/form/section_card.dart';
import 'package:SapaWarga_kel_2/widget/form/labeled_text_field.dart';
import 'package:SapaWarga_kel_2/widget/form/labeled_dropdown.dart';
import 'package:SapaWarga_kel_2/widget/moon_result_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditRumahPage extends StatefulWidget {
  final Rumah rumah;

  const EditRumahPage({super.key, required this.rumah});

  @override
  State<EditRumahPage> createState() => _EditRumahPageState();
}

class _EditRumahPageState extends State<EditRumahPage> {
  static const Color _primaryColor = Color(0xFF4E46B4);

  late final TextEditingController _alamatController;
  late final TextEditingController _residentsController;
  String? _selectedStatus;
  String? _selectedKeluarga;
  List<Map<dynamic, dynamic>> _keluargaList = []; // Store keluarga names

  @override
  void initState() {
    super.initState();
    _alamatController = TextEditingController(text: widget.rumah.alamat);
    _residentsController = TextEditingController(
      text: widget.rumah.residents.toString(),
    );
    _selectedStatus = widget.rumah.status;
    _selectedKeluarga = widget.rumah.pemilik == null
        ? null
        : widget.rumah.pemilikId;

    fetchNamaKeluarga();
  }

  fetchNamaKeluarga() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('keluarga')
        .select('id, nama_keluarga');

    try {
      setState(() {
        _keluargaList = List<Map<dynamic, dynamic>>.from(
          response.map(
            (item) => {
              'id': item['id'],
              'nama_keluarga': item['nama_keluarga'],
            },
          ),
        );
      });
    } catch (e) {
      // Handle error or show message
      debugPrint('Error fetching keluarga: $e');
    }
  }

  @override
  void dispose() {
    _alamatController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_alamatController.text.trim().isEmpty) {
      _showErrorModal('Alamat rumah tidak boleh kosong');
      return;
    }
    if (_selectedStatus == null || _selectedStatus!.isEmpty) {
      _showErrorModal('Status rumah harus dipilih');
      return;
    }
    if (_selectedStatus == 'Ditempati' &&
        (_selectedKeluarga == null || _selectedKeluarga!.isEmpty)) {
      _showErrorModal('Keluarga harus dipilih untuk status Ditempati');
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('rumah')
          .update({
            'alamat': _alamatController.text.trim(),
            'status': _selectedStatus,
            'keluarga_id': _selectedStatus == 'Tersedia'
                ? null
                : _selectedKeluarga,
            'jumlah_penghuni': _selectedStatus == 'Tersedia'
                ? 0
                : _residentsController.text.trim(),
          })
          .eq('id', widget.rumah.id);
      _showSuccessModal();
    } catch (e) {
      _showErrorModal('Gagal memperbarui data rumah: $e');
      debugPrint('Error updating rumah: $e');
    }
  }

  void _showErrorModal(String message) {
    showResultModal(
      context,
      type: ResultType.error,
      title: 'Gagal',
      description: message,
    );
  }

  void _showSuccessModal() {
    showResultModal(
      context,
      type: ResultType.success,
      title: 'Berhasil',
      description: 'Data rumah berhasil diperbarui',
      autoProceed: true,
      onAction: () => context.pop(),
    );
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
          'Edit Rumah',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SectionCard(
            title: 'Informasi Rumah',
            accentColor: _primaryColor,
            children: [
              LabeledTextField(
                label: 'Alamat Rumah',
                controller: _alamatController,
                hint: widget.rumah.alamat,
                keyboardType: TextInputType.streetAddress,
              ),
              const SizedBox(height: 8),
              LabeledDropdown(
                label: 'Status',
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem(value: 'Tersedia', child: Text('Tersedia')),
                  DropdownMenuItem(
                    value: 'Ditempati',
                    child: Text('Ditempati'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                    _selectedKeluarga = null; // Reset keluarga selection
                  });
                },
                hint: 'Pilih status rumah',
              ),
              // Show keluarga dropdown only if the status is "Ditempati"
              if (_selectedStatus == 'Ditempati')
                LabeledDropdown(
                  label: 'Keluarga',
                  value: _selectedKeluarga,
                  items: _keluargaList.map((keluarga) {
                    return DropdownMenuItem(
                      value: keluarga['id'],
                      child: Text(keluarga['nama_keluarga']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKeluarga = value.toString();
                    });
                  },
                  hint: 'Pilih keluarga',
                ),
              if (_selectedStatus == 'Ditempati')
                LabeledTextField(
                  label: 'Jumlah Penghuni',
                  controller: _residentsController,
                  keyboardType: TextInputType.number,
                  hint: widget.rumah.residents.toString(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Simpan Perubahan',
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
