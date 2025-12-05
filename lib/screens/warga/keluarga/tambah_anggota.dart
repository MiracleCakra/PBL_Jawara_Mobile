import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/warga_model.dart';
import 'package:jawara_pintar_kel_5/services/warga_service.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show getPrimaryColor;
import 'package:jawara_pintar_kel_5/widget/form/date_picker_field.dart';
import 'package:jawara_pintar_kel_5/widget/form/labeled_dropdown.dart';
import 'package:jawara_pintar_kel_5/widget/form/labeled_text_field.dart';
import 'package:jawara_pintar_kel_5/widget/form/section_card.dart';
import 'package:jawara_pintar_kel_5/widget/moon_result_modal.dart';

class TambahAnggotaKeluargaPage extends StatefulWidget {
  const TambahAnggotaKeluargaPage({super.key});

  @override
  State<TambahAnggotaKeluargaPage> createState() =>
      _TambahAnggotaKeluargaPageState();
}

class _TambahAnggotaKeluargaPageState extends State<TambahAnggotaKeluargaPage> {
  final _wargaService = WargaService();
  final _namaCtl = TextEditingController();
  final _idCtl = TextEditingController();
  final _tempatLahirCtl = TextEditingController();
  final _teleponCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  DateTime? _tanggalLahir;

  Gender? _jenisKelamin;
  String? _agama;
  GolonganDarah? _golDarah;
  String? _peranKeluarga;
  StatusHidup? _statusHidup;
  StatusPenduduk? _statusPenduduk;
  String? _pendidikan;
  String? _pekerjaan;

  // Rumah Saat Ini
  String? _rumahSaatIni;
  final _rumahManualCtl = TextEditingController();
  bool _isRumahManual = false;

  File? _fotoKtpFile;
  bool _isSaving = false;

  // Future<void> _pickFotoKtp({required ImageSource source}) async {
  //   try {
  //     final picked = await _picker.pickImage(source: source);

  //     if (picked == null) return;

  //     File originalFile = File(picked.path);

  //     // Validasi max 5MB
  //     final bytes = await originalFile.length();
  //     if (bytes > 5 * 1024 * 1024) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Ukuran gambar maksimal 5 MB')),
  //       );
  //       return;
  //     }

  //     setState(() {
  //       _fotoKtpFile = originalFile;
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
  //   }
  // }

  // void _removeFotoKtp() {
  //   setState(() {
  //     _fotoKtpFile = null;
  //   });
  // }

  // =======================
  //  SAVE DATA
  // =======================
  Future<void> _saveWarga() async {
    if (_idCtl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('NIK tidak boleh kosong')));
      return;
    }

    if (_namaCtl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    if (_jenisKelamin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jenis kelamin harus dipilih')),
      );
      return;
    }

    if (_statusPenduduk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status kependudukan harus dipilih')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? fotoKtpBase64;
      if (_fotoKtpFile != null) {
        fotoKtpBase64 = base64Encode(_fotoKtpFile!.readAsBytesSync());
      }

      final warga = Warga(
        id: _idCtl.text,
        nama: _namaCtl.text,
        tanggalLahir: _tanggalLahir,
        tempatLahir: _tempatLahirCtl.text.isEmpty ? null : _tempatLahirCtl.text,
        telepon: _teleponCtl.text.isEmpty ? null : _teleponCtl.text,
        gender: _jenisKelamin,
        golDarah: _golDarah,
        pendidikanTerakhir: _pendidikan,
        pekerjaan: _pekerjaan,
        statusPenduduk: _statusPenduduk,
        statusHidupWafat: _statusHidup,
        keluargaId: null,
        agama: _agama,
        fotoKtp: fotoKtpBase64,
        email: _emailCtl.text.isEmpty ? null : _emailCtl.text,
      );

      // await _wargaService.createWarga(warga);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data anggota keluarga berhasil ditambahkan'),
            backgroundColor: Colors.grey.shade800,
          ),
        );

        // Return data anggota baru ke halaman daftar
        context.pop({
          'nama': _namaCtl.text,
          'nik': _idCtl.text,
          'jenisKelamin': _jenisKelamin?.value ?? '',
          'peranKeluarga': _peranKeluarga ?? '',
        });
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
    _namaCtl.dispose();
    _idCtl.dispose();
    _tempatLahirCtl.dispose();
    _teleponCtl.dispose();
    _emailCtl.dispose();
    _rumahManualCtl.dispose();
    super.dispose();
  }

  // =======================
  //  BUILD UI
  // =======================
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

      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ================= DATA DIRI =================
          SectionCard(
            title: 'Data Diri',
            children: [
              LabeledTextField(
                label: 'Nama',
                controller: _namaCtl,
                hint: 'Masukkan nama lengkap',
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: 'NIK',
                controller: _idCtl,
                keyboardType: TextInputType.number,
                hint: 'Masukkan NIK',
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: 'Nomor Telepon',
                controller: _teleponCtl,
                keyboardType: TextInputType.phone,
                hint: 'Masukkan nomor telepon',
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: 'Email (Opsional)',
                controller: _emailCtl,
                keyboardType: TextInputType.emailAddress,
                hint: 'Masukkan email',
              ),
              const SizedBox(height: 8),
              LabeledTextField(
                label: 'Tempat Lahir',
                controller: _tempatLahirCtl,
                hint: 'Masukkan tempat lahir',
              ),
              const SizedBox(height: 8),
              DatePickerField(
                label: 'Tanggal Lahir',
                selectedDate: _tanggalLahir,
                onDateSelected: (date) {
                  setState(() => _tanggalLahir = date);
                },
                placeholder: 'Pilih Tanggal',
              ),
              const SizedBox(height: 8),
              if (!_isRumahManual)
                LabeledDropdown<String>(
                  label: 'Rumah Saat Ini',
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
                  label: 'Rumah Saat Ini',
                  controller: _rumahManualCtl,
                  hint: 'Masukkan rumah saat ini',
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

          // ================= ATRIBUT PERSONAL =================
          SectionCard(
            title: 'Atribut Personal',
            children: [
              LabeledDropdown<Gender>(
                label: 'Jenis Kelamin',
                value: _jenisKelamin,
                onChanged: (v) => setState(() => _jenisKelamin = v),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Jenis Kelamin --'),
                  ),
                  ...Gender.values.map(
                    (g) => DropdownMenuItem(value: g, child: Text(g.value)),
                  ),
                ],
              ),
              LabeledDropdown<String>(
                label: 'Agama',
                value: _agama,
                onChanged: (v) => setState(() => _agama = v),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Agama --'),
                  ),
                  DropdownMenuItem(value: 'Islam', child: Text('Islam')),
                  DropdownMenuItem(value: 'Kristen', child: Text('Kristen')),
                  DropdownMenuItem(value: 'Katolik', child: Text('Katolik')),
                  DropdownMenuItem(value: 'Hindu', child: Text('Hindu')),
                  DropdownMenuItem(value: 'Buddha', child: Text('Buddha')),
                  DropdownMenuItem(value: 'Konghucu', child: Text('Konghucu')),
                ],
              ),
              LabeledDropdown<GolonganDarah>(
                label: 'Golongan Darah',
                value: _golDarah,
                onChanged: (v) => setState(() => _golDarah = v),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Golongan Darah --'),
                  ),
                  ...GolonganDarah.values.map(
                    (gd) => DropdownMenuItem(value: gd, child: Text(gd.value)),
                  ),
                ],
              ),
            ],
          ),

          // ================= PERAN =================
          SectionCard(
            title: 'Peran & Latar Belakang',
            children: [
              LabeledDropdown<String>(
                label: 'Peran Keluarga',
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
                label: 'Pendidikan Terakhir',
                value: _pendidikan,
                onChanged: (v) => setState(() => _pendidikan = v),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Pendidikan Terakhir --'),
                  ),
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
                onChanged: (v) => setState(() => _pekerjaan = v),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Jenis Pekerjaan --'),
                  ),
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

          // ================= STATUS =================
          SectionCard(
            title: 'Status',
            children: [
              LabeledDropdown<StatusHidup>(
                label: 'Status Hidup',
                value: _statusHidup,
                onChanged: (v) => setState(() => _statusHidup = v),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Status Hidup --'),
                  ),
                  ...StatusHidup.values.map(
                    (s) => DropdownMenuItem(value: s, child: Text(s.value)),
                  ),
                ],
              ),
              LabeledDropdown<StatusPenduduk>(
                label: 'Status Kependudukan',
                value: _statusPenduduk,
                onChanged: (v) => setState(() => _statusPenduduk = v),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('-- Pilih Status Kependudukan --'),
                  ),
                  ...StatusPenduduk.values.map(
                    (s) => DropdownMenuItem(value: s, child: Text(s.value)),
                  ),
                ],
              ),
            ],
          ),

          // // ================= FOTO KTP =================
          // SectionCard(
          //   title: 'Foto Identitas',
          //   children: [
          //     GestureDetector(
          //       onTap: () {
          //         showModalBottomSheet(
          //           context: context,
          //           shape: const RoundedRectangleBorder(
          //             borderRadius: BorderRadius.vertical(
          //               top: Radius.circular(16),
          //             ),
          //           ),
          //           builder: (_) => SafeArea(
          //             child: Wrap(
          //               children: [
          //                 ListTile(
          //                   leading: const Icon(Icons.photo_camera),
          //                   title: const Text('Ambil dari Kamera'),
          //                   onTap: () {
          //                     Navigator.pop(context);
          //                     _pickFotoKtp(source: ImageSource.camera);
          //                   },
          //                 ),
          //                 ListTile(
          //                   leading: const Icon(Icons.photo_library),
          //                   title: const Text('Pilih dari Galeri'),
          //                   onTap: () {
          //                     Navigator.pop(context);
          //                     _pickFotoKtp(source: ImageSource.gallery);
          //                   },
          //                 ),
          //               ],
          //             ),
          //           ),
          //         );
          //       },
          //       child: Container(
          //         height: 160,
          //         width: double.infinity,
          //         decoration: BoxDecoration(
          //           color: Colors.grey[100],
          //           borderRadius: BorderRadius.circular(12),
          //           border: Border.all(color: Colors.grey.shade300),
          //         ),
          //         child: _fotoKtpFile == null
          //             ? const Center(
          //                 child: Column(
          //                   mainAxisSize: MainAxisSize.min,
          //                   children: [
          //                     Icon(Icons.upload, size: 40, color: Colors.grey),
          //                     SizedBox(height: 6),
          //                     Text("Tap untuk upload foto Identitas"),
          //                   ],
          //                 ),
          //               )
          //             : Stack(
          //                 children: [
          //                   ClipRRect(
          //                     borderRadius: BorderRadius.circular(12),
          //                     child: Image.file(
          //                       _fotoKtpFile!,
          //                       width: double.infinity,
          //                       height: double.infinity,
          //                       fit: BoxFit.cover,
          //                     ),
          //                   ),
          //                   Positioned(
          //                     right: 8,
          //                     top: 8,
          //                     child: InkWell(
          //                       onTap: _removeFotoKtp,
          //                       child: Container(
          //                         decoration: const BoxDecoration(
          //                           color: Colors.black54,
          //                           shape: BoxShape.circle,
          //                         ),
          //                         padding: const EdgeInsets.all(6),
          //                         child: const Icon(
          //                           Icons.close,
          //                           color: Colors.white,
          //                         ),
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //       ),
          //     ),
          //   ],
          // ),

          // const SizedBox(height: 12),

          // ================= BUTTON =================
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
                onPressed: _isSaving ? null : _saveWarga,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
