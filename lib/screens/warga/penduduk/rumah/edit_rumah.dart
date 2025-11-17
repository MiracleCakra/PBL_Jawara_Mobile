import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/warga/penduduk/rumah/daftar_rumah.dart';
import 'package:jawara_pintar_kel_5/widget/form/section_card.dart';
import 'package:jawara_pintar_kel_5/widget/form/labeled_text_field.dart';
import 'package:jawara_pintar_kel_5/widget/form/labeled_dropdown.dart';
import 'package:jawara_pintar_kel_5/widget/moon_result_modal.dart';

class EditRumahPage extends StatefulWidget {
  final Rumah rumah;

  const EditRumahPage({super.key, required this.rumah});

  @override
  State<EditRumahPage> createState() => _EditRumahPageState();
}

class _EditRumahPageState extends State<EditRumahPage> {
  static const Color _primaryColor = Color(0xFF4E46B4);

  late final TextEditingController _alamatController;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _alamatController = TextEditingController(text: widget.rumah.address);
    _selectedStatus = widget.rumah.status;
  }

  @override
  void dispose() {
    _alamatController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // Validation
    if (_alamatController.text.trim().isEmpty) {
      _showErrorModal('Alamat rumah tidak boleh kosong');
      return;
    }

    if (_selectedStatus == null || _selectedStatus!.isEmpty) {
      _showErrorModal('Status rumah harus dipilih');
      return;
    }

    // TODO: Save to backend/database
    _showSuccessModal();
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
                hint: widget.rumah.address,
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
                  });
                },
                hint: 'Pilih status rumah',
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
