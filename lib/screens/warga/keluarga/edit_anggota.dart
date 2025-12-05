import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/anggota_keluarga_model.dart';
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
  late final TextEditingController _nikCtl;
  late final TextEditingController _namaCtl;
  late final TextEditingController _tempatLahirCtl;
  late final TextEditingController _teleponCtl;
  final TextEditingController _emailCtl = TextEditingController();

  DateTime? _tanggalLahir;
  String? _jenisKelamin;
  String? _agama;
  String? _golDarah;
  String? _pendidikan;
  String? _pekerjaan;
  String? _peranKeluarga;
  String? _statusPenduduk;
  String? _statusHidup;

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

      _nikCtl = TextEditingController(text: a.nik ?? '');
      _namaCtl = TextEditingController(text: a.nama ?? '');
      _tempatLahirCtl = TextEditingController(text: a.tempatLahir ?? "");
      _teleponCtl = TextEditingController(text: a.telepon ?? "");
      _emailCtl.text = a.email ?? "";

      _tanggalLahir = a.tanggalLahir;
      _jenisKelamin = a.jenisKelamin;
      _agama = a.agama;
      _golDarah = a.golonganDarah;
      _pendidikan = a.pendidikanTerakhir;
      _pekerjaan = a.pekerjaan;
      _peranKeluarga = a.peranKeluarga;
      _statusPenduduk = a.statusPenduduk;
      _statusHidup = a.statusHidup;
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
      // Jika ada error, tetap lanjut dengan nilai default
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

    // **SIMULASI UPDATE TANPA API**
    await Future.delayed(const Duration(seconds: 1));

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

    setState(() => _isSaving = false);
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
                label: "Nama",
                controller: _namaCtl,
                hint: "Masukkan nama lengkap",
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: "NIK",
                controller: _nikCtl,
                keyboardType: TextInputType.number,
                hint: "Masukkan NIK",
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
                label: "Email (Opsional)",
                controller: _emailCtl,
                keyboardType: TextInputType.emailAddress,
                hint: "Masukkan email",
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
              if (!_isRumahManual)
                LabeledDropdown<String>(
                  label: "Rumah Saat ini",
                  value: _rumahSaatIni,
                  onChanged: (v) {
                    setState(() {
                      if (v == 'manual') {
                        _isRumahManual = true;
                        _rumahSaatIni = null;
                      } else {
                        _rumahSaatIni = v;
                      }
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('-- Pilih Rumah --'),
                    ),
                    DropdownMenuItem(
                      value: 'Blok A No. 1',
                      child: Text('Blok A No. 1'),
                    ),
                    DropdownMenuItem(
                      value: 'Blok A No. 2',
                      child: Text('Blok A No. 2'),
                    ),
                    DropdownMenuItem(
                      value: 'Blok B No. 1',
                      child: Text('Blok B No. 1'),
                    ),
                    DropdownMenuItem(value: 'manual', child: Text('Lainnya')),
                  ],
                )
              else ...[
                LabeledTextField(
                  label: "Rumah Saat Ini",
                  controller: _rumahManualCtl,
                  hint: "Masukkan rumah saat ini",
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRumahManual = false;
                      _rumahManualCtl.clear();
                    });
                  },
                  child: const Text('Kembali ke pilihan dropdown'),
                ),
              ],
            ],
          ),
          SectionCard(
            title: "Atribut Personal",
            children: [
              LabeledDropdown<String>(
                label: "Jenis Kelamin",
                value: _jenisKelamin,
                onChanged: (v) => setState(() => _jenisKelamin = v),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Jenis Kelamin --'),
                  ),
                  DropdownMenuItem(value: "Pria", child: Text("Pria")),
                  DropdownMenuItem(value: "Wanita", child: Text("Wanita")),
                ],
              ),
              LabeledDropdown<String>(
                label: "Agama",
                value: _agama,
                onChanged: (v) => setState(() => _agama = v),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Agama --'),
                  ),
                  DropdownMenuItem(value: "Islam", child: Text("Islam")),
                  DropdownMenuItem(value: "Kristen", child: Text("Kristen")),
                  DropdownMenuItem(value: "Katolik", child: Text("Katolik")),
                  DropdownMenuItem(value: "Hindu", child: Text("Hindu")),
                  DropdownMenuItem(value: "Buddha", child: Text("Buddha")),
                  DropdownMenuItem(value: "Konghucu", child: Text("Konghucu")),
                ],
              ),
              LabeledDropdown<String>(
                label: "Golongan Darah",
                value: _golDarah,
                onChanged: (v) => setState(() => _golDarah = v),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Golongan Darah --'),
                  ),
                  DropdownMenuItem(value: "A+", child: Text("A+")),
                  DropdownMenuItem(value: "A-", child: Text("A-")),
                  DropdownMenuItem(value: "B+", child: Text("B+")),
                  DropdownMenuItem(value: "B-", child: Text("B-")),
                  DropdownMenuItem(value: "AB+", child: Text("AB+")),
                  DropdownMenuItem(value: "AB-", child: Text("AB-")),
                  DropdownMenuItem(value: "O+", child: Text("O+")),
                  DropdownMenuItem(value: "O-", child: Text("O-")),
                ],
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
                  DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Peran Keluarga --'),
                  ),
                  DropdownMenuItem(
                    value: 'Kepala Keluarga',
                    child: Text('Kepala Keluarga'),
                  ),
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
                  DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Pendidikan Terakhir --'),
                  ),
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
                  DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Jenis Pekerjaan --'),
                  ),
                  DropdownMenuItem(
                    value: "Pelajar/Mahasiswa",
                    child: Text("Pelajar/Mahasiswa"),
                  ),
                  DropdownMenuItem(value: "Karyawan", child: Text("Karyawan")),
                  DropdownMenuItem(
                    value: "Wiraswasta",
                    child: Text("Wiraswasta"),
                  ),
                  DropdownMenuItem(
                    value: "Ibu Rumah Tangga",
                    child: Text("Ibu Rumah Tangga"),
                  ),
                  DropdownMenuItem(
                    value: "Tidak Bekerja",
                    child: Text("Tidak Bekerja"),
                  ),
                ],
              ),
            ],
          ),
          SectionCard(
            title: "Status",
            children: [
              LabeledDropdown<String>(
                label: "Status Hidup",
                value: _statusHidup,
                onChanged: (v) => setState(() => _statusHidup = v),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Status Hidup --'),
                  ),
                  DropdownMenuItem(value: "Hidup", child: Text("Hidup")),
                  DropdownMenuItem(value: "Wafat", child: Text("Wafat")),
                ],
              ),
              LabeledDropdown<String>(
                label: "Status Kependudukan",
                value: _statusPenduduk,
                onChanged: (v) => setState(() => _statusPenduduk = v),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Status Kependudukan --'),
                  ),
                  DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
                  DropdownMenuItem(
                    value: "Non Aktif",
                    child: Text("Non Aktif"),
                  ),
                ],
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
