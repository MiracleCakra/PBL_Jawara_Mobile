import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/widget/form/section_card.dart';
import 'package:SapaWarga_kel_2/widget/form/labeled_text_field.dart';
import 'package:SapaWarga_kel_2/widget/moon_result_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahRumahPage extends StatefulWidget {
  const TambahRumahPage({super.key});

  @override
  State<TambahRumahPage> createState() => _TambahRumahPageState();
}

class _TambahRumahPageState extends State<TambahRumahPage> {
  static const Color _primaryColor = Color(0xFF4E46B4);

  final _alamatController = TextEditingController();

  @override
  void dispose() {
    _alamatController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    // Validation
    if (_alamatController.text.trim().isEmpty) {
      _showErrorModal('Alamat rumah tidak boleh kosong');
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('rumah').insert({
        'alamat': _alamatController.text.trim(),
      });
      _showSuccessModal();
    } catch (e) {
      _showErrorModal('Gagal menambah rumah: $e');
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
      description: 'Data rumah berhasil ditambahkan',
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
          'Tambah Rumah Baru',
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
                hint: 'Masukkan alamat lengkap rumah',
                keyboardType: TextInputType.streetAddress,
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
