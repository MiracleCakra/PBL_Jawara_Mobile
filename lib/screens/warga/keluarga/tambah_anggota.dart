import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/models/keluarga/warga_model.dart';
import 'package:SapaWarga_kel_2/services/keluarga_service.dart';
import 'package:SapaWarga_kel_2/services/warga_service.dart';
import 'package:SapaWarga_kel_2/utils.dart' show getPrimaryColor;
import 'package:SapaWarga_kel_2/widget/form/labeled_dropdown.dart';
import 'package:SapaWarga_kel_2/widget/form/labeled_text_field.dart';
import 'package:SapaWarga_kel_2/widget/form/section_card.dart';
import 'package:SapaWarga_kel_2/widget/moon_result_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahAnggotaKeluargaPage extends StatefulWidget {
  const TambahAnggotaKeluargaPage({super.key});

  @override
  State<TambahAnggotaKeluargaPage> createState() =>
      _TambahAnggotaKeluargaPageState();
}

class _TambahAnggotaKeluargaPageState extends State<TambahAnggotaKeluargaPage> {
  final _wargaService = WargaService();
  final _keluargaService = KeluargaService();
  final _idCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _teleponCtl = TextEditingController();

  // State for Dropdown logic
  List<Warga> _availableWarga = [];
  Warga? _selectedWarga;
  String? _currentKeluargaId;
  bool _isLoading = true;
  bool _isSaving = false;

  // Editable fields (if null in DB)
  Gender? _jenisKelamin;
  String? _agama;
  GolonganDarah? _golDarah;
  String? _peranKeluarga;
  StatusHidup? _statusHidup;
  StatusPenduduk? _statusPenduduk;
  String? _pendidikan;
  String? _pekerjaan;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch current user to get keluarga_id
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email != null) {
        final currentUser = await _wargaService.getWargaByEmail(email);
        _currentKeluargaId = currentUser?.keluargaId;
      }

      // 2. Fetch warga without keluarga
      _availableWarga = await _wargaService.getWargaWithoutKeluarga();

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  void _onWargaSelected(Warga? warga) {
    setState(() {
      _selectedWarga = warga;
      if (warga != null) {
        _idCtl.text = warga.id;
        _emailCtl.text = warga.email ?? '';
        _teleponCtl.text = warga.telepon ?? '';

        _jenisKelamin = warga.gender;

        const agamaList = [
          'Islam',
          'Kristen',
          'Katolik',
          'Hindu',
          'Buddha',
          'Konghucu',
        ];
        _agama = (warga.agama != null && agamaList.contains(warga.agama))
            ? warga.agama
            : null;

        _golDarah = warga.golDarah;

        const peranList = ['Kepala Keluarga', 'Ibu', 'Anak', 'Lainnya'];
        _peranKeluarga = (warga.role != null && peranList.contains(warga.role))
            ? warga.role
            : null;

        _statusHidup = warga.statusHidupWafat;
        _statusPenduduk = warga.statusPenduduk;

        const pendidikanList = [
          'SD',
          'SMP',
          'SMA/SMK',
          'Diploma',
          'S1',
          'S2',
          'S3',
        ];
        _pendidikan = pendidikanList.contains(warga.pendidikanTerakhir)
            ? warga.pendidikanTerakhir
            : null;

        const pekerjaanList = [
          'Pelajar/Mahasiswa',
          'Karyawan',
          'Wiraswasta',
          'Ibu Rumah Tangga',
          'Tidak Bekerja',
        ];
        _pekerjaan = pekerjaanList.contains(warga.pekerjaan)
            ? warga.pekerjaan
            : null;
      } else {
        // Reset if deselected
        _idCtl.clear();
        _emailCtl.clear();
        _teleponCtl.clear();
        _jenisKelamin = null;
        _agama = null;
        _golDarah = null;
        _peranKeluarga = null;
        _statusHidup = null;
        _statusPenduduk = null;
        _pendidikan = null;
        _pekerjaan = null;
      }
    });
  }

  Future<void> _saveWarga() async {
    if (_selectedWarga == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih anggota terlebih dahulu')),
      );
      return;
    }

    if (_currentKeluargaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Anda belum memiliki keluarga, tidak bisa menambahkan anggota.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedWarga = Warga(
        id: _selectedWarga!.id,
        nama: _selectedWarga!.nama,
        keluargaId: _currentKeluargaId,

        // Use values from form
        telepon: _teleponCtl.text.isEmpty ? null : _teleponCtl.text,
        email: _emailCtl.text.isEmpty ? null : _emailCtl.text,
        gender: _jenisKelamin,
        agama: _agama,
        golDarah: _golDarah,
        pendidikanTerakhir: _pendidikan,
        pekerjaan: _pekerjaan,
        statusPenduduk: _statusPenduduk,
        statusHidupWafat: _statusHidup,
        role: _selectedWarga!.role,
        statusPenerimaan: 'Pending',

        // Preserve other fields
        tanggalLahir: _selectedWarga!.tanggalLahir,
        tempatLahir: _selectedWarga!.tempatLahir,
        fotoKtp: _selectedWarga!.fotoKtp,
        fotoProfil: _selectedWarga!.fotoProfil,
      );

      // 1. Update Warga Table (Set keluarga_id and other fields)
      await _wargaService.updateWarga(_selectedWarga!.id, updatedWarga);

      // 2. Add Relation to keluarga_warga Table
      if (_peranKeluarga != null) {
        await _keluargaService.addAnggotaKeluargaRelation(
          _currentKeluargaId!,
          _selectedWarga!.id,
          _peranKeluarga!,
        );
      }

      if (mounted) {
        await showResultModal(
          context,
          type: ResultType.success,
          title: 'Berhasil',
          description: 'Data anggota keluarga berhasil disimpan.',
          actionLabel: 'Selesai',
          onAction: () {
            Navigator.pop(context);
            context.pop({'refresh': true});
          },
        );
      }
    } catch (e) {
      if (mounted) {
        await showResultModal(
          context,
          type: ResultType.error,
          title: 'Error',
          description: 'Gagal menyimpan data: $e',
          actionLabel: 'Coba Lagi',
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _idCtl.dispose();
    _emailCtl.dispose();
    _teleponCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Tambah Anggota Keluarga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                SectionCard(
                  title: 'Pilih Anggota',
                  children: [
                    LabeledDropdown<Warga>(
                      label: 'Nama Lengkap',
                      value: _selectedWarga,
                      onChanged: _onWargaSelected,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('-- Pilih Nama Warga --'),
                        ),
                        ..._availableWarga.map(
                          (w) => DropdownMenuItem(
                            value: w,
                            child: Text('${w.nama} (NIK: ${w.id})'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (_selectedWarga != null) ...[
                  SectionCard(
                    title: 'Data Diri',
                    children: [
                      LabeledTextField(
                        label: 'NIK',
                        controller: _idCtl,
                        readOnly: true,
                      ),
                      const SizedBox(height: 8),
                      LabeledTextField(
                        label: 'Email',
                        controller: _emailCtl,
                        readOnly: true,
                      ),
                      const SizedBox(height: 8),
                      LabeledTextField(
                        label: 'Nomor Telepon',
                        controller: _teleponCtl,
                        keyboardType: TextInputType.phone,
                        hint: 'Masukkan nomor telepon',
                      ),
                    ],
                  ),

                  SectionCard(
                    title: 'Atribut Personal',
                    children: [
                      LabeledDropdown<Gender>(
                        label: 'Jenis Kelamin',
                        value: _jenisKelamin,
                        onChanged: (v) => setState(() => _jenisKelamin = v),
                        items: Gender.values
                            .map(
                              (g) => DropdownMenuItem(
                                value: g,
                                child: Text(g.value),
                              ),
                            )
                            .toList(),
                      ),
                      LabeledDropdown<String>(
                        label: 'Agama',
                        value: _agama,
                        onChanged: (v) => setState(() => _agama = v),
                        items:
                            [
                                  'Islam',
                                  'Kristen',
                                  'Katolik',
                                  'Hindu',
                                  'Buddha',
                                  'Konghucu',
                                ]
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v),
                                  ),
                                )
                                .toList(),
                      ),
                      LabeledDropdown<GolonganDarah>(
                        label: 'Golongan Darah',
                        value: _golDarah,
                        onChanged: (v) => setState(() => _golDarah = v),
                        items: GolonganDarah.values
                            .map(
                              (g) => DropdownMenuItem(
                                value: g,
                                child: Text(g.value),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),

                  SectionCard(
                    title: 'Peran & Status',
                    children: [
                      LabeledDropdown<String>(
                        label:
                            'Peran Keluarga', // Assuming maps to 'role' in Warga or specific field if added
                        value: _peranKeluarga,
                        onChanged: (v) => setState(() => _peranKeluarga = v),
                        items:
                            [
                                  'Kepala Keluarga',
                                  'Ibu',
                                  'Anak',
                                  'Lainnya',
                                ] // Simple list, or fetch if dynamic
                                .map(
                                  (v) => DropdownMenuItem(
                                    value: v,
                                    child: Text(v),
                                  ),
                                )
                                .toList(),
                      ),
                      LabeledDropdown<StatusHidup>(
                        label: 'Status Hidup',
                        value: _statusHidup,
                        onChanged: (v) => setState(() => _statusHidup = v),
                        items: StatusHidup.values
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.value),
                              ),
                            )
                            .toList(),
                      ),
                      LabeledDropdown<StatusPenduduk>(
                        label: 'Status Kependudukan',
                        value: _statusPenduduk,
                        onChanged: (v) => setState(() => _statusPenduduk = v),
                        items: StatusPenduduk.values
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.value),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getPrimaryColor(context),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSaving ? null : _saveWarga,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Simpan'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
