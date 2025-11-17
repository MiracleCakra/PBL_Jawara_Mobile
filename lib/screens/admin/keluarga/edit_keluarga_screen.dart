import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/keluarga_model.dart' as k_model;
import 'package:jawara_pintar_kel_5/models/warga_model.dart';
import 'package:jawara_pintar_kel_5/services/keluarga_service.dart';
import 'package:jawara_pintar_kel_5/services/warga_service.dart';
import 'package:go_router/go_router.dart';

class EditKeluargaScreen extends StatefulWidget {
  final k_model.Keluarga keluarga;

  const EditKeluargaScreen({super.key, required this.keluarga});

  @override
  State<EditKeluargaScreen> createState() => _EditKeluargaScreenState();
}

class _EditKeluargaScreenState extends State<EditKeluargaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keluargaService = KeluargaService();
  final _wargaService = WargaService();

  late TextEditingController _namaKeluargaController;
  late TextEditingController _alamatRumahController;
  late TextEditingController _statusKepemilikanController;

  String? _selectedKepalaKeluargaId;
  String? _selectedStatusKeluarga;

  late Future<List<Warga>> _wargaListFuture;

  @override
  void initState() {
    super.initState();
    _namaKeluargaController =
        TextEditingController(text: widget.keluarga.namaKeluarga);
    _alamatRumahController =
        TextEditingController(text: widget.keluarga.alamatRumah);
    _statusKepemilikanController =
        TextEditingController(text: widget.keluarga.statusKepemilikan);
    _selectedKepalaKeluargaId = widget.keluarga.kepalaKeluargaId;
    _selectedStatusKeluarga = widget.keluarga.statusKeluarga;
    _wargaListFuture = _wargaService.getAllWarga();
  }

  @override
  void dispose() {
    _namaKeluargaController.dispose();
    _alamatRumahController.dispose();
    _statusKepemilikanController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final updatedKeluarga = k_model.Keluarga(
        id: widget.keluarga.id,
        namaKeluarga: _namaKeluargaController.text,
        kepalaKeluargaId: _selectedKepalaKeluargaId!,
        alamatRumah: _alamatRumahController.text,
        statusKepemilikan: _statusKepemilikanController.text,
        statusKeluarga: _selectedStatusKeluarga!,
      );

      try {
        await _keluargaService.updateKeluarga(
            widget.keluarga.id, updatedKeluarga);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keluarga berhasil diperbarui')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui keluarga: $e')),
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
          'Edit Keluarga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionCard(
              title: 'Informasi Keluarga',
              children: [
                _buildNamaKeluargaField(),
                const SizedBox(height: 16),
                _buildKepalaKeluargaDropdown(),
                const SizedBox(height: 16),
                _buildAlamatRumahField(),
                const SizedBox(height: 16),
                _buildStatusKepemilikanField(),
                const SizedBox(height: 16),
                _buildStatusKeluargaDropdown(),
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

  Widget _buildNamaKeluargaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Nama Keluarga',
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
          controller: _namaKeluargaController,
          decoration: _inputDecoration('Masukkan nama keluarga'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama keluarga tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildKepalaKeluargaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Kepala Keluarga',
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
        FutureBuilder<List<Warga>>(
          future: _wargaListFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final wargaList = snapshot.data!;
            return DropdownButtonFormField<String>(
              value: _selectedKepalaKeluargaId,
              decoration: _inputDecoration('-- Pilih Kepala Keluarga --'),
              items: wargaList.map((warga) {
                return DropdownMenuItem(
                  value: warga.id,
                  child: Text(warga.nama),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKepalaKeluargaId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Kepala keluarga harus dipilih';
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlamatRumahField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Alamat Rumah',
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
          controller: _alamatRumahController,
          decoration: _inputDecoration('Masukkan alamat rumah'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Alamat rumah tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusKepemilikanField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Status Kepemilikan',
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
          controller: _statusKepemilikanController,
          decoration: _inputDecoration('Masukkan status kepemilikan'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Status kepemilikan tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusKeluargaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Status Keluarga',
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
          value: _selectedStatusKeluarga,
          decoration: _inputDecoration('-- Pilih Status Keluarga --'),
          items: const [
            DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
            DropdownMenuItem(value: 'Nonaktif', child: Text('Nonaktif')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedStatusKeluarga = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Status keluarga harus dipilih';
            }
            return null;
          },
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
        borderSide: const BorderSide(color: Color(0xFF4E46B4), width: 1.5),
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
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF4E46B4),
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