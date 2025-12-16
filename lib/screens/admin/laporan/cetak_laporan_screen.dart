import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:SapaWarga_kel_2/models/keuangan/laporan_keuangan_model.dart';
import 'package:SapaWarga_kel_2/utils.dart'
    show formatDate, getPrimaryColor, openDateTimePicker;
import 'package:SapaWarga_kel_2/widget/moon_result_modal.dart'
    show showResultModal, ResultType;
import 'package:moon_design/moon_design.dart';

class CetakLaporanScreen extends StatefulWidget {
  const CetakLaporanScreen({super.key});

  @override
  State<CetakLaporanScreen> createState() => _CetakLaporanScreenState();
}

class _CetakLaporanScreenState extends State<CetakLaporanScreen> {
  String _selectedType = 'pemasukan';
  DateTime? _startDate;
  DateTime? _endDate;
  List<LaporanKeuanganModel> _laporanData = [];

  LaporanKeuanganModel laporanKeuanganModel = LaporanKeuanganModel(
    tanggal: DateTime.now(),
    nama: "",
    nominal: 0,
    kategoriPengeluaran: '',
    buktiFoto: '',
  );

  // State untuk filter Kategori Iuran
  String _selectedCategory = 'Semua';

  // Daftar Kategori Iuran
  final List<String> _jenisIuranOptions = [
    'Semua',
    'Iuran Bulanan',
    'Iuran Khusus',
    // Tambahkan kategori lain jika ada
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   _loadLaporanData();
  // }

  _loadLaporanData() async {
    debugPrint(
      'Loading laporan data $_selectedType... (start: $_startDate, end: $_endDate)',
    );

    // Clear previous data
    _laporanData.clear();

    // Fetch data based on selected type and date range
    try {
      switch (_selectedType) {
        case 'pemasukan':
          var iuranData = await laporanKeuanganModel.fetchIuran(
            startDate: _startDate,
            endDate: _endDate,
          );
          var pemasukanData = await laporanKeuanganModel.fetchPemasukan(
            startDate: _startDate,
            endDate: _endDate,
          );
          _laporanData.addAll(iuranData);
          _laporanData.addAll(pemasukanData);
          break;
        case 'pengeluaran':
          var pengeluaranData = await laporanKeuanganModel.fetchPengeluaran(
            startDate: _startDate,
            endDate: _endDate,
          );
          _laporanData.addAll(pengeluaranData);
          break;
        default:
          var allIuranData = await laporanKeuanganModel.fetchIuran(
            startDate: _startDate,
            endDate: _endDate,
          );
          var allPemasukanData = await laporanKeuanganModel.fetchPemasukan(
            startDate: _startDate,
            endDate: _endDate,
          );
          var allPengeluaranData = await laporanKeuanganModel.fetchPengeluaran(
            startDate: _startDate,
            endDate: _endDate,
          );
          _laporanData.addAll(allIuranData);
          _laporanData.addAll(allPemasukanData);
          _laporanData.addAll(allPengeluaranData);
          break;
      }
    } catch (e) {
      debugPrint('Error loading laporan data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: Text(
          'Cetak Laporan',
          style: MoonTokens.light.typography.heading.text20.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Text(
              'Cetak atau ekspor laporan keuangan',
              style: MoonTokens.light.typography.body.text14.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            // 3 Tabs (Jenis Laporan)
            Container(
              width: double.infinity,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: MoonSquircleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ).squircleBorderRadius(context),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jenis Laporan
                  Text(
                    'Jenis Laporan',
                    style: MoonTokens.light.typography.body.text16.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TypeSegmented(
                    value: _selectedType,
                    onChanged: (v) => setState(() => _selectedType = v),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 12),
            // _CategoryFilterBar(
            //   selectedCategory: _selectedCategory,
            //   onTap: _showCategoryFilterModal,
            //   primaryColor: getPrimaryColor(context),
            // ),
            const SizedBox(height: 12),
            // Form card
            Container(
              width: double.infinity,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: MoonSquircleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ).squircleBorderRadius(context),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Periode
                  Text(
                    'Periode',
                    style: MoonTokens.light.typography.body.text16.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Dari tanggal',
                          value: _startDate == null
                              ? null
                              : formatDate(_startDate!),
                          onTap: () async {
                            final picked = await openDateTimePicker(context);
                            if (picked != null) {
                              setState(() => _startDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: 'Sampai tanggal',
                          value: _endDate == null
                              ? null
                              : formatDate(_endDate!),
                          onTap: () async {
                            final picked = await openDateTimePicker(context);
                            if (picked != null) {
                              setState(() => _endDate = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        flex: 3,
                        child: MoonFilledButton(
                          backgroundColor: getPrimaryColor(context),
                          onTap: () async {
                            await _printReport();
                          },
                          label: const Text('Cetak'),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showCategoryFilterModal() {
  //   String tempSelected = _selectedCategory;

  //   final primaryColor = getPrimaryColor(context);

  //   showMoonModalBottomSheet(
  //     context: context,
  //     enableDrag: true,
  //     height: MediaQuery.of(context).size.height * 0.65,
  //     builder: (BuildContext context) => StatefulBuilder(
  //       builder: (context, setStateModal) {
  //         return Column(
  //           children: [
  //             const SizedBox(height: 8),
  //             Container(
  //               height: 4,
  //               width: 40,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[300],
  //                 borderRadius: BorderRadius.circular(40),
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //             const Text(
  //               "Filter Kategori",
  //               style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
  //             ),
  //             const SizedBox(height: 16),

  //             Expanded(
  //               child: ListView(
  //                 children: List.generate(_jenisIuranOptions.length, (index) {
  //                   final option = _jenisIuranOptions[index];
  //                   final isSelected = tempSelected == option;

  //                   return MoonMenuItem(
  //                     onTap: () {
  //                       setStateModal(() => tempSelected = option);
  //                     },
  //                     label: Text(option),
  //                     trailing: isSelected
  //                         ? const Icon(
  //                             MoonIcons.generic_check_alternative_32_light,
  //                           )
  //                         : null,
  //                   );
  //                 }),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: MoonFilledButton(
  //                       backgroundColor: Colors.grey[300],
  //                       label: const Text(
  //                         "Reset",
  //                         style: TextStyle(color: Colors.black),
  //                       ),
  //                       onTap: () {
  //                         setState(() => _selectedCategory = "Semua");
  //                         Navigator.pop(context);
  //                       },
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: MoonFilledButton(
  //                       backgroundColor: primaryColor,
  //                       label: const Text("Terapkan"),
  //                       onTap: () {
  //                         setState(() => _selectedCategory = tempSelected);
  //                         Navigator.pop(context);
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }

  // Helper function untuk mendapatkan ikon
  // IconData _getJenisIcon(String jenis) {
  //   switch (jenis) {
  //     case 'Semua':
  //       return Icons.apps;
  //     case 'Iuran Bulanan':
  //       return Icons.calendar_month;
  //     case 'Iuran Khusus':
  //       return Icons.star_outline;
  //     default:
  //       return Icons.category;
  //   }
  // }

  // --- Utility & Display Helpers ---

  String get _periodLabel {
    if (_startDate == null && _endDate == null) return 'Semua waktu';
    if (_startDate != null && _endDate == null) {
      return 'Sejak ${formatDate(_startDate!)}';
    }
    if (_startDate == null && _endDate != null) {
      return 'Hingga ${formatDate(_endDate!)}';
    }
    return '${formatDate(_startDate!)} - ${formatDate(_endDate!)}';
  }

  String _labelForType(String v) {
    switch (v) {
      case 'pemasukan':
        return 'Pemasukan';
      case 'pengeluaran':
        return 'Pengeluaran';
      default:
        return 'Semua';
    }
  }

  Future<void> _printReport() async {
    final categoryText = _selectedCategory != 'Semua'
        ? ' untuk kategori **$_selectedCategory**'
        : '';

    log('Printing laporan $_selectedType...', name: 'cetakLaporan');

    // Load the report data asynchronously
    await _loadLaporanData(); // Await the data loading

    try {
      // Attempt to export to Excel and save the file
      bool isSaved = await laporanKeuanganModel.exportToExcel(_laporanData);

      // Show success modal after the file is saved
      if (isSaved) {
        _laporanData.clear(); // Clear the data after saving
        await showResultModal(
          context,
          type: ResultType.success,
          title: 'Laporan siap!',
          description:
              'Laporan **${_labelForType(_selectedType).toLowerCase()}**$categoryText periode $_periodLabel berhasil disiapkan.',
          actionLabel: 'Selesai',
          onAction: () {},
        );
      } else {
        // If the file wasn't saved, show an error message
        await showResultModal(
          context,
          type: ResultType.error,
          title: 'Gagal menyimpan laporan',
          description:
              'Terjadi kesalahan saat menyimpan laporan. Pastikan Anda memberi izin akses penyimpanan.',
          actionLabel: 'Coba Lagi',
          onAction: () {},
        );
      }
    } catch (e) {
      // If there's any error in the process, show an error message
      await showResultModal(
        context,
        type: ResultType.error,
        title: 'Terjadi Kesalahan',
        description: 'Ada masalah dalam memproses laporan. Silakan coba lagi.',
        actionLabel: 'Coba Lagi',
        onAction: () {},
      );
    }
  }
}

// class _CategoryFilterBar extends StatelessWidget {
//   final String selectedCategory;
//   final VoidCallback onTap;
//   final Color primaryColor;

//   const _CategoryFilterBar({
//     required this.selectedCategory,
//     required this.onTap,
//     required this.primaryColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: primaryColor,
//       shape: MoonSquircleBorder(
//         borderRadius: BorderRadius.circular(20).squircleBorderRadius(context),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20).squircleBorderRadius(context),
//         onTap: onTap,
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.tune, color: Colors.white, size: 18),
//               const SizedBox(width: 10),
//               Text(
//                 "Filter Kategori",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _TypeSegmented extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _TypeSegmented({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors ?? MoonTokens.light.colors;
    final items = const [
      ('pemasukan', 'Pemasukan'),
      ('pengeluaran', 'Pengeluaran'),
      ('semua', 'Semua'),
    ];

    return Container(
      decoration: ShapeDecoration(
        color: Colors.grey[50],
        shape: MoonSquircleBorder(
          borderRadius: BorderRadius.circular(12).squircleBorderRadius(context),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (final (key, label) in items) ...[
            Expanded(
              child: _Segment(
                label: label,
                selected: value == key,
                onTap: () => onChanged(key),
                selectedColor: colors.piccolo,
              ),
            ),
            if (key != items.last.$1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? selectedColor.withValues(alpha: 0.12)
          : Colors.transparent,
      shape: MoonSquircleBorder(
        borderRadius: BorderRadius.circular(10).squircleBorderRadius(context),
      ),
      child: InkWell(
        customBorder: MoonSquircleBorder(
          borderRadius: BorderRadius.circular(10).squircleBorderRadius(context),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: MoonTokens.light.typography.body.text14.copyWith(
                color: selected ? selectedColor : Colors.black,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: MoonSquircleBorder(
        borderRadius: BorderRadius.circular(12).squircleBorderRadius(context),
      ),
      child: InkWell(
        customBorder: MoonSquircleBorder(
          borderRadius: BorderRadius.circular(12).squircleBorderRadius(context),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.event_outlined, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value ?? label,
                  style: MoonTokens.light.typography.body.text14.copyWith(
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
