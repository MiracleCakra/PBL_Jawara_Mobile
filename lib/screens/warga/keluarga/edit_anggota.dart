import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/anggota_keluarga_model.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'package:jawara_pintar_kel_5/services/keluarga_service.dart';
import 'package:jawara_pintar_kel_5/services/warga_service.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show getPrimaryColor;
import 'package:jawara_pintar_kel_5/widget/form/date_picker_field.dart';
import 'package:jawara_pintar_kel_5/widget/form/labeled_dropdown.dart';
import 'package:jawara_pintar_kel_5/widget/form/labeled_text_field.dart';
import 'package:jawara_pintar_kel_5/widget/form/section_card.dart';
import 'package:jawara_pintar_kel_5/widget/moon_result_modal.dart';

class EditAnggotaPage extends StatefulWidget {
  final Anggota anggota;

  const EditAnggotaPage({super.key, required this.anggota});

  @override
  State<EditAnggotaPage> createState() => _EditAnggotaPageState();
}

class _EditAnggotaPageState extends State<EditAnggotaPage> {
  final WargaService _wargaService = WargaService();
  final KeluargaService _keluargaService = KeluargaService();

  late final TextEditingController _nikCtl;
  late final TextEditingController _namaCtl;
  late final TextEditingController _tempatLahirCtl;
  late final TextEditingController _teleponCtl;
  final TextEditingController _emailCtl = TextEditingController();

  DateTime? _tanggalLahir;
  Gender? _jenisKelamin;
  String? _agama;
  GolonganDarah? _golDarah;
  String? _pendidikan;
  String? _pekerjaan;
  String? _peranKeluarga;
  StatusPenduduk? _statusPenduduk;
  StatusHidup? _statusHidup;

  // Rumah Saat Ini
  String? _rumahSaatIni;
  final TextEditingController _rumahManualCtl = TextEditingController();
  bool _isRumahManual = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    try {
      final a = widget.anggota;

      _nikCtl = TextEditingController(text: a.nik);
      _namaCtl = TextEditingController(text: a.nama);
      _tempatLahirCtl = TextEditingController(text: a.tempatLahir ?? "");
      _teleponCtl = TextEditingController(text: a.telepon ?? "");
      _emailCtl.text = a.email ?? "";

      _tanggalLahir = a.tanggalLahir;

      // Safe assignment for Dropdowns
      const genderList = ["Pria", "Wanita"];
      _jenisKelamin = (a.jenisKelamin != null && genderList.contains(a.jenisKelamin)) 
          ? Gender.values.firstWhere((g) => g.value == a.jenisKelamin) 
          : null;

      const agamaList = ["Islam", "Kristen", "Katolik", "Hindu", "Buddha", "Konghucu"];
      _agama = (a.agama != null && agamaList.contains(a.agama)) ? a.agama : null;

      const golDarahList = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
      _golDarah = (a.golonganDarah != null && golDarahList.contains(a.golonganDarah)) 
          ? GolonganDarah.values.firstWhere((g) => g.value == a.golonganDarah)
          : null;

      const pendidikanList = ["SD", "SMP", "SMA/SMK", "Diploma", "S1", "S2", "S3"];
      _pendidikan = (a.pendidikanTerakhir != null && pendidikanList.contains(a.pendidikanTerakhir)) ? a.pendidikanTerakhir : null;

      const pekerjaanList = ["Pelajar/Mahasiswa", "Karyawan", "Wiraswasta", "Ibu Rumah Tangga", "Tidak Bekerja"];
      _pekerjaan = (a.pekerjaan != null && pekerjaanList.contains(a.pekerjaan)) ? a.pekerjaan : null;

      const peranList = ['Kepala Keluarga', 'Ibu', 'Anak', 'Lainnya'];
      _peranKeluarga = (a.peranKeluarga != null && peranList.contains(a.peranKeluarga)) ? a.peranKeluarga : null;

      const statusPendudukList = ["Aktif", "Nonaktif"];
      _statusPenduduk = (a.statusPenduduk != null && statusPendudukList.contains(a.statusPenduduk)) 
          ? StatusPenduduk.values.firstWhere((s) => s.value == a.statusPenduduk)
          : null;

      const statusHidupList = ["Hidup", "Wafat"];
      _statusHidup = (a.statusHidup != null && statusHidupList.contains(a.statusHidup)) 
          ? StatusHidup.values.firstWhere((s) => s.value == a.statusHidup)
          : null;

      _rumahSaatIni = a.rumahSaatIni;

      // Set manual mode if rumahSaatIni doesn't match predefined options
      if (_rumahSaatIni != null &&
          _rumahSaatIni != 'Blok A No. 1' &&
          _rumahSaatIni != 'Blok A No. 2' &&
          _rumahSaatIni != 'Blok B No. 1') {
        _isRumahManual = true;
        _rumahManualCtl.text = _rumahSaatIni!;
        _rumahSaatIni = null;
      }
    } catch (e) {
      debugPrint('Error initializing edit form: $e');
    }
  }

  Future<void> _updateAnggota() async {
    if (_nikCtl.text.isEmpty || _namaCtl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan NIK tidak boleh kosong")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
        // We assume we are editing an existing Warga (member) who is ALREADY in the family.
        // We fetch the existing Warga to get the 'role' (app role) to preserve it.
        final existingWarga = await _wargaService.getWargaById(_nikCtl.text);

        final updatedWarga = Warga(
            id: _nikCtl.text,
            nama: _namaCtl.text,
            email: _emailCtl.text.isEmpty ? null : _emailCtl.text,
            telepon: _teleponCtl.text.isEmpty ? null : _teleponCtl.text,
            tempatLahir: _tempatLahirCtl.text.isEmpty ? null : _tempatLahirCtl.text,
            tanggalLahir: _tanggalLahir,
            gender: _jenisKelamin,
            agama: _agama,
            golDarah: _golDarah,
            pendidikanTerakhir: _pendidikan,
            pekerjaan: _pekerjaan,
            statusPenduduk: _statusPenduduk,
            statusHidupWafat: _statusHidup,
            
            // Preserve existing fields
            keluargaId: existingWarga.keluargaId,
            fotoKtp: existingWarga.fotoKtp,
            fotoProfil: existingWarga.fotoProfil,
            role: existingWarga.role, // Preserve App Role
            statusPenerimaan: 'Pending',
        );

        // 1. Update Warga
        await _wargaService.updateWarga(_nikCtl.text, updatedWarga);

        // 2. Update Keluarga Relation (Peran)
        if (_peranKeluarga != null) {
            if (existingWarga.anggotaKeluarga != null && existingWarga.anggotaKeluarga!.isNotEmpty) {
               await _keluargaService.updateAnggotaKeluargaRelation(_nikCtl.text, _peranKeluarga!);
            } else if (existingWarga.keluargaId != null) {
               await _keluargaService.addAnggotaKeluargaRelation(
                 existingWarga.keluargaId!, 
                 _nikCtl.text, 
                 _peranKeluarga!
               );
            }
        }

        if (!mounted) return;

        await showResultModal(
            context,
            type: ResultType.success,
            title: "Berhasil",
            description: "Data anggota berhasil diperbarui.",
            actionLabel: "OK",
            autoProceed: true,
        );

        context.pop(true);

    } catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
        }
    } finally {
        if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nikCtl.dispose();
    _namaCtl.dispose();
    _tempatLahirCtl.dispose();
    _teleponCtl.dispose();
    _emailCtl.dispose();
    _rumahManualCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Edit Anggota",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SectionCard(
            title: "Data Diri",
            children: [
              LabeledTextField(
                label: "Nama (Read Only)",
                controller: _namaCtl,
                hint: "Masukkan nama lengkap",
                readOnly: true, // Disabled as requested
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: "NIK (Read Only)",
                controller: _nikCtl,
                keyboardType: TextInputType.number,
                hint: "Masukkan NIK",
                readOnly: true, // Disabled as requested
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: "Nomor Telepon",
                controller: _teleponCtl,
                keyboardType: TextInputType.phone,
                hint: "Masukkan nomor telepon",
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: "Email (Read Only)",
                controller: _emailCtl,
                keyboardType: TextInputType.emailAddress,
                hint: "Masukkan email",
                readOnly: true, // Disabled
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: "Tempat Lahir",
                controller: _tempatLahirCtl,
                hint: "Masukkan tempat lahir",
              ),
              const SizedBox(height: 8),
              DatePickerField(
                label: "Tanggal Lahir",
                selectedDate: _tanggalLahir,
                placeholder: "Pilih Tanggal",
                onDateSelected: (d) => setState(() => _tanggalLahir = d),
              ),
              const SizedBox(height: 8),
              // Rumah Saat Ini (Read Only/Disabled)
              if (!_isRumahManual)
                IgnorePointer( // Disable interaction
                  child: LabeledDropdown<String>(
                    label: "Rumah Saat ini (Read Only)",
                    value: _rumahSaatIni,
                    onChanged: (v) {},
                    items: const [
                      DropdownMenuItem(value: null, child: Text('-- Pilih Rumah --')),
                      DropdownMenuItem(value: 'Blok A No. 1', child: Text('Blok A No. 1')),
                      DropdownMenuItem(value: 'Blok A No. 2', child: Text('Blok A No. 2')),
                      DropdownMenuItem(value: 'Blok B No. 1', child: Text('Blok B No. 1')),
                      DropdownMenuItem(value: 'manual', child: Text('Lainnya')),
                    ],
                  ),
                )
              else ...[
                LabeledTextField(
                  label: "Rumah Saat Ini (Read Only)",
                  controller: _rumahManualCtl,
                  hint: "Masukkan rumah saat ini",
                  readOnly: true,
                ),
              ],
            ],
          ),
          SectionCard(
            title: "Atribut Personal",
            children: [
              LabeledDropdown<Gender>(
                label: "Jenis Kelamin",
                value: _jenisKelamin,
                onChanged: (v) => setState(() => _jenisKelamin = v),
                items: Gender.values.map((g) => DropdownMenuItem(value: g, child: Text(g.value))).toList(),
              ),
              LabeledDropdown<String>(
                label: "Agama",
                value: _agama,
                onChanged: (v) => setState(() => _agama = v),
                items: const [
                  DropdownMenuItem(value: null, child: Text('-- Pilih Agama --')),
                  DropdownMenuItem(value: "Islam", child: Text("Islam")),
                  DropdownMenuItem(value: "Kristen", child: Text("Kristen")),
                  DropdownMenuItem(value: "Katolik", child: Text("Katolik")),
                  DropdownMenuItem(value: "Hindu", child: Text("Hindu")),
                  DropdownMenuItem(value: "Buddha", child: Text("Buddha")),
                  DropdownMenuItem(value: "Konghucu", child: Text("Konghucu")),
                ],
              ),
              LabeledDropdown<GolonganDarah>(
                label: "Golongan Darah",
                value: _golDarah,
                onChanged: (v) => setState(() => _golDarah = v),
                items: GolonganDarah.values.map((g) => DropdownMenuItem(value: g, child: Text(g.value))).toList(),
              ),
            ],
          ),
          SectionCard(
            title: "Peran & Latar Belakang",
            children: [
              LabeledDropdown<String>(
                label: "Peran Keluarga",
                value: _peranKeluarga,
                onChanged: (v) => setState(() => _peranKeluarga = v),
                items: const [
                  DropdownMenuItem(value: null, child: Text('-- Pilih Peran Keluarga --')),
                  DropdownMenuItem(value: 'Kepala Keluarga', child: Text('Kepala Keluarga')),
                  DropdownMenuItem(value: 'Ibu', child: Text('Ibu')),
                  DropdownMenuItem(value: 'Anak', child: Text('Anak')),
                  DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                ],
              ),
              LabeledDropdown<String>(
                label: "Pendidikan Terakhir",
                value: _pendidikan,
                onChanged: (v) => setState(() => _pendidikan = v),
                items: const [
                  DropdownMenuItem(value: null, child: Text('-- Pilih Pendidikan Terakhir --')),
                  DropdownMenuItem(value: "SD", child: Text("SD")),
                  DropdownMenuItem(value: "SMP", child: Text("SMP")),
                  DropdownMenuItem(value: "SMA/SMK", child: Text("SMA/SMK")),
                  DropdownMenuItem(value: "Diploma", child: Text("Diploma")),
                  DropdownMenuItem(value: "S1", child: Text("S1")),
                  DropdownMenuItem(value: "S2", child: Text("S2")),
                  DropdownMenuItem(value: "S3", child: Text("S3")),
                ],
              ),
              LabeledDropdown<String>(
                label: "Pekerjaan",
                value: _pekerjaan,
                onChanged: (v) => setState(() => _pekerjaan = v),
                items: const [
                  DropdownMenuItem(value: null, child: Text('-- Pilih Jenis Pekerjaan --')),
                  DropdownMenuItem(value: "Pelajar/Mahasiswa", child: Text("Pelajar/Mahasiswa")),
                  DropdownMenuItem(value: "Karyawan", child: Text("Karyawan")),
                  DropdownMenuItem(value: "Wiraswasta", child: Text("Wiraswasta")),
                  DropdownMenuItem(value: "Ibu Rumah Tangga", child: Text("Ibu Rumah Tangga")),
                  DropdownMenuItem(value: "Tidak Bekerja", child: Text("Tidak Bekerja")),
                ],
              ),
            ],
          ),
          SectionCard(
            title: "Status",
            children: [
              LabeledDropdown<StatusHidup>(
                label: "Status Hidup",
                value: _statusHidup,
                onChanged: (v) => setState(() => _statusHidup = v),
                items: StatusHidup.values.map((s) => DropdownMenuItem(value: s, child: Text(s.value))).toList(),
              ),
              LabeledDropdown<StatusPenduduk>(
                label: "Status Kependudukan",
                value: _statusPenduduk,
                onChanged: (v) => setState(() => _statusPenduduk = v),
                items: StatusPenduduk.values.map((s) => DropdownMenuItem(value: s, child: Text(s.value))).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _updateAnggota,
              style: ElevatedButton.styleFrom(
                backgroundColor: getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Simpan Perubahan"),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}