import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show getPrimaryColor;
import 'package:jawara_pintar_kel_5/widget/form/date_picker_field.dart';
import 'package:jawara_pintar_kel_5/widget/form/labeled_dropdown.dart';
import 'package:jawara_pintar_kel_5/widget/form/labeled_text_field.dart';
import 'package:jawara_pintar_kel_5/widget/form/section_card.dart';
import 'package:jawara_pintar_kel_5/widget/moon_result_modal.dart';

class EditWargaPage extends StatefulWidget {
  final Map<String, String> warga;
  const EditWargaPage({super.key, required this.warga});

  @override
  State<EditWargaPage> createState() => _EditWargaPageState();
}

class _EditWargaPageState extends State<EditWargaPage> {
  // Controllers: kosongkan agar placeholder menampilkan nilai lama.
  final _namaCtl = TextEditingController();
  final _nikCtl = TextEditingController();
  final _teleponCtl = TextEditingController();
  final _tempatLahirCtl = TextEditingController();
  final _tglLahirCtl = TextEditingController();

  // Dropdown states (biarkan null saat awal supaya hint tampil)
  String? _jenisKelamin;
  String? _agama;
  String? _golDarah;
  String? _keluarga;
  String? _peranKeluarga;
  String? _statusHidup;
  String? _statusPenduduk;
  String? _pendidikan;
  String? _pekerjaan;

  String _w(String key, [String fallback = '']) =>
      widget.warga[key] ?? fallback;

  @override
  void dispose() {
    _namaCtl.dispose();
    _nikCtl.dispose();
    _teleponCtl.dispose();
    _tempatLahirCtl.dispose();
    _tglLahirCtl.dispose();
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
          'Edit Warga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SectionCard(
            title: 'Data Diri',
            children: [
              LabeledTextField(
                label: 'Nama Lengkap',
                controller: _namaCtl,
                hint: _w('name', 'Nama Lengkap'),
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: 'NIK',
                controller: _nikCtl,
                keyboardType: TextInputType.number,
                hint: _w('nik', 'NIK'),
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: 'Nomor Telephone',
                controller: _teleponCtl,
                keyboardType: TextInputType.phone,
                hint: _w('phone', 'Nomor Telephone'),
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: 'Tempat Lahir',
                controller: _tempatLahirCtl,
                hint: _w('birthPlace', 'Contoh: Malang'),
              ),
              const SizedBox(height: 8),
              DatePickerField(
                label: 'Tanggal Lahir',
                controller: _tglLahirCtl,
                placeholder: _w('birthDate', 'Tanggal Lahir'),
              ),
            ],
          ),

          SectionCard(
            title: 'Atribut Personal',
            children: [
              LabeledDropdown<String>(
                label: 'Jenis Kelamin',
                value: _jenisKelamin,
                hint: _w('gender', 'Pilih Jenis Kelamin'),
                onChanged: (v) => setState(() => _jenisKelamin = v),
                items: const [
                  DropdownMenuItem(
                    value: 'Laki-laki',
                    child: Text('Laki-laki'),
                  ),
                  DropdownMenuItem(
                    value: 'Perempuan',
                    child: Text('Perempuan'),
                  ),
                ],
              ),
              LabeledDropdown<String>(
                label: 'Agama',
                value: _agama,
                hint: _w('religion', 'Pilih Agama'),
                onChanged: (v) => setState(() => _agama = v),
                items: const [
                  DropdownMenuItem(value: 'Islam', child: Text('Islam')),
                  DropdownMenuItem(value: 'Kristen', child: Text('Kristen')),
                  DropdownMenuItem(value: 'Katolik', child: Text('Katolik')),
                  DropdownMenuItem(value: 'Hindu', child: Text('Hindu')),
                  DropdownMenuItem(value: 'Buddha', child: Text('Buddha')),
                  DropdownMenuItem(value: 'Konghucu', child: Text('Konghucu')),
                ],
              ),
              LabeledDropdown<String>(
                label: 'Golongan Darah',
                value: _golDarah,
                hint: _w('blood', 'Pilih Golongan Darah'),
                onChanged: (v) => setState(() => _golDarah = v),
                items: const [
                  DropdownMenuItem(value: 'A', child: Text('A')),
                  DropdownMenuItem(value: 'B', child: Text('B')),
                  DropdownMenuItem(value: 'AB', child: Text('AB')),
                  DropdownMenuItem(value: 'O', child: Text('O')),
                ],
              ),
            ],
          ),

          SectionCard(
            title: 'Status & Peran',
            children: [
              LabeledDropdown<String>(
                label: 'Keluarga',
                value: _keluarga,
                hint: _w('family', 'Pilih Keluarga'),
                onChanged: (v) => setState(() => _keluarga = v),
                items: const [
                  DropdownMenuItem(
                    value: 'Keluarga Besar Mojokerto',
                    child: Text('Keluarga Besar Mojokerto'),
                  ),
                  DropdownMenuItem(
                    value: 'Keluarga Besar Blitar',
                    child: Text('Keluarga Besar Blitar'),
                  ),
                ],
              ),
              LabeledDropdown<String>(
                label: 'Peran',
                value: _peranKeluarga,
                hint: _w('role', 'Pilih Peran dalam keluarga'),
                onChanged: (v) => setState(() => _peranKeluarga = v),
                items: const [
                  DropdownMenuItem(
                    value: 'Kepala Keluarga',
                    child: Text('Kepala Keluarga'),
                  ),
                  DropdownMenuItem(value: 'Ibu', child: Text('Ibu')),
                  DropdownMenuItem(value: 'Anak', child: Text('Anak')),
                ],
              ),
              LabeledDropdown<String>(
                label: 'Status Hidup',
                value: _statusHidup,
                hint: _w('lifeStatus', 'Pilih Status Hidup'),
                onChanged: (v) => setState(() => _statusHidup = v),
                items: const [
                  DropdownMenuItem(value: 'Hidup', child: Text('Hidup')),
                  DropdownMenuItem(value: 'Wafat', child: Text('Wafat')),
                ],
              ),
              LabeledDropdown<String>(
                label: 'Status Kependudukan',
                value: _statusPenduduk,
                hint: _w('status', 'Pilih Status Penduduk'),
                onChanged: (v) => setState(() => _statusPenduduk = v),
                items: const [
                  DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                  DropdownMenuItem(value: 'Nonaktif', child: Text('Nonaktif')),
                ],
              ),
            ],
          ),

          SectionCard(
            title: 'Latar Belakang',
            children: [
              LabeledDropdown<String>(
                label: 'Pendidikan Terakhir',
                value: _pendidikan,
                hint: _w('education', 'Pilih Pendidikan Terakhir'),
                onChanged: (v) => setState(() => _pendidikan = v),
                items: const [
                  DropdownMenuItem(value: 'SD', child: Text('SD')),
                  DropdownMenuItem(value: 'SMP', child: Text('SMP')),
                  DropdownMenuItem(value: 'SMA/SMK', child: Text('SMA/SMK')),
                  DropdownMenuItem(value: 'Diploma', child: Text('Diploma')),
                  DropdownMenuItem(value: 'S1', child: Text('S1')),
                  DropdownMenuItem(value: 'S2', child: Text('S2')),
                  DropdownMenuItem(value: 'S3', child: Text('S3')),
                ],
              ),
              LabeledDropdown<String>(
                label: 'Pekerjaan',
                value: _pekerjaan,
                hint: _w('job', 'Pilih Pekerjaan'),
                onChanged: (v) => setState(() => _pekerjaan = v),
                items: const [
                  DropdownMenuItem(
                    value: 'Pelajar/Mahasiswa',
                    child: Text('Pelajar/Mahasiswa'),
                  ),
                  DropdownMenuItem(value: 'Karyawan', child: Text('Karyawan')),
                  DropdownMenuItem(
                    value: 'Wiraswasta',
                    child: Text('Wiraswasta'),
                  ),
                  DropdownMenuItem(
                    value: 'Ibu Rumah Tangga',
                    child: Text('Ibu Rumah Tangga'),
                  ),
                  DropdownMenuItem(
                    value: 'Tidak Bekerja',
                    child: Text('Tidak Bekerja'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                onPressed: () async {
                  // TODO: Simpan perubahan
                  await showResultModal(
                    context,
                    type: ResultType.success,
                    title: 'Berhasil',
                    description: 'Perubahan data warga berhasil disimpan.',
                    actionLabel: 'Selesai',
                    autoProceed: true,
                  );
                  // Kembali ke halaman detail warga
                  if (context.mounted) context.pop();
                },
                child: const Text('Simpan Perubahan'),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
