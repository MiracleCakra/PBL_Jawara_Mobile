import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/laporan_keuangan_model.dart';
import 'package:jawara_pintar_kel_5/screens/admin/laporan/detail_screen.dart';
import 'package:jawara_pintar_kel_5/screens/admin/laporan/pemasukan_lain_tambah_screen.dart';
import 'package:jawara_pintar_kel_5/utils.dart'
    show formatDate, formatRupiah, openDateTimePicker;
import 'package:moon_design/moon_design.dart';

class SemuaPemasukanScreen extends StatefulWidget {
  const SemuaPemasukanScreen({super.key});

  @override
  State<SemuaPemasukanScreen> createState() => _SemuaPemasukanScreenState();
}

class _SemuaPemasukanScreenState extends State<SemuaPemasukanScreen> {
  late final TextEditingController _textController;
  String _query = '';
  String _selectedKategori = 'Semua';
  DateTime? _selectedDari;
  DateTime? _selectedSampai;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  final List<LaporanKeuanganModel> fakeData = [
    LaporanKeuanganModel(
      tanggal: DateTime(2024, 1, 1),
      nama: "Pemasukan 1",
      nominal: 100000,
      kategoriPemasukan: 'Donasi',
      buktiFoto:
          'https://via.placeholder.com/400x300.png?text=Bukti+Transfer+1',
    ),
    LaporanKeuanganModel(
      tanggal: DateTime(2024, 1, 3),
      nama: "Pemasukan 2",
      nominal: 300000,
      kategoriPemasukan: 'Dana Bantuan Pemerintah',
      buktiFoto:
          'https://via.placeholder.com/400x300.png?text=Bukti+Transfer+2',
    ),
    LaporanKeuanganModel(
      tanggal: DateTime(2024, 1, 5),
      nama: "Pemasukan 3",
      nominal: 400000,
      kategoriPemasukan: 'Sumbangan Swadaya',
      buktiFoto:
          'https://via.placeholder.com/400x300.png?text=Bukti+Transfer+3',
    ),
    LaporanKeuanganModel(
      tanggal: DateTime(2024, 1, 7),
      nama: "Pemasukan 4",
      nominal: 500000,
      kategoriPemasukan: 'Hasil Usaha Kampung',
      buktiFoto:
          'https://via.placeholder.com/400x300.png?text=Bukti+Transfer+4',
    ),
    LaporanKeuanganModel(
      tanggal: DateTime(2024, 1, 9),
      nama: "Pemasukan 5",
      nominal: 600000,
      kategoriPemasukan: 'Pendapatan Lainnya',
      buktiFoto:
          'https://via.placeholder.com/400x300.png?text=Bukti+Transfer+5',
    ),
    LaporanKeuanganModel(
      tanggal: DateTime(2024, 1, 10),
      nama: "Pemasukan 6",
      nominal: 700000,
      kategoriPemasukan: 'Donasi',
      buktiFoto:
          'https://via.placeholder.com/400x300.png?text=Bukti+Transfer+6',
    ),
  ];

  List<LaporanKeuanganModel> get _filteredData {
    var filtered = fakeData;

    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered
          .where((e) => e.nama.toLowerCase().contains(q))
          .toList();
    }

    if (_selectedKategori != 'Semua') {
      filtered = filtered
          .where((e) => e.kategoriPemasukan == _selectedKategori)
          .toList();
    }

    if (_selectedDari != null) {
      filtered = filtered
          .where(
            (e) => e.tanggal.isAfter(
              _selectedDari!.subtract(const Duration(days: 1)),
            ),
          )
          .toList();
    }
    if (_selectedSampai != null) {
      filtered = filtered
          .where(
            (e) => e.tanggal.isBefore(
              _selectedSampai!.add(const Duration(days: 1)),
            ),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: Text(
          "Semua Pemasukkan",
          style: MoonTokens.light.typography.heading.text20.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PemasukanLainTambahScreen(),
            ),
          );

          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              fakeData.add(
                LaporanKeuanganModel(
                  tanggal: result['tanggal'] ?? DateTime.now(),
                  nama: result['nama'] ?? '',
                  nominal: (result['nominal'] ?? 0).toInt(),
                  kategoriPemasukan: result['kategoriPemasukan'] ?? '',
                  buktiFoto: result['buktiFoto'],
                ),
              );
            });
          }
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          searchSection(),
          Expanded(
            child: _filteredData.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data',
                      style: MoonTokens.light.typography.body.text14,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemBuilder: (context, index) =>
                        _incomeCard(_filteredData[index]),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: _filteredData.length,
                  ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------
  // SEARCH SECTION
  // -----------------------------------------------------
  Padding searchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  hintText: 'Cari nama...',
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _textController.clear();
                            setState(() => _query = '');
                          },
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // FILTER BUTTON
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _showFilterSheet,
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.tune, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------
  // FILTER BOTTOM SHEET
  // -----------------------------------------------------
  void _showFilterSheet() {
    final colors = context.moonColors ?? MoonTokens.light.colors;
    showMoonModalBottomSheet(
      context: context,
      builder: (ctx) {
        String kategori = _selectedKategori;
        DateTime? dari = _selectedDari;
        DateTime? sampai = _selectedSampai;

        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickDate({required bool isStart}) async {
              final res = await openDateTimePicker(context);
              if (res != null) {
                setState(() {
                  if (isStart) {
                    dari = res;
                  } else {
                    sampai = res;
                  }
                });
              }
            }

            void _showKategoriBottomSheet() {
              final List<String> kategoris = [
                'Semua',
                'Donasi',
                'Dana Bantuan Pemerintah',
                'Sumbangan Swadaya',
                'Hasil Usaha Kampung',
                'Pendapatan Lainnya',
                'Iuran',
              ];
              showMoonModalBottomSheet(
                context: context,
                enableDrag: true,
                height: MediaQuery.of(context).size.height * 0.7,
                builder: (context) => Column(
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: ShapeDecoration(
                        color: context.moonColors!.beerus,
                        shape: MoonSquircleBorder(
                          borderRadius: BorderRadius.circular(
                            16,
                          ).squircleBorderRadius(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih Kategori Pemasukan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: kategoris.map((item) {
                            final isSelected = kategori == item;
                            return MoonMenuItem(
                              leading: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF6366F1),
                                    )
                                  : const SizedBox(width: 24),
                              label: Text(
                                item,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[800],
                                ),
                              ),
                              onTap: () {
                                setState(() => kategori = item);
                                Navigator.of(context).pop();
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: MoonSquircleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ).squircleBorderRadius(context),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: ShapeDecoration(
                          color: context.moonColors!.beerus,
                          shape: MoonSquircleBorder(
                            borderRadius: BorderRadius.circular(
                              16,
                            ).squircleBorderRadius(context),
                          ),
                        ),
                      ),
                      Text(
                        'Filter',
                        style: MoonTokens.light.typography.heading.text18
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Kategori Pemasukan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: InkWell(
                      onTap: _showKategoriBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                kategori,
                                style: MoonTokens.light.typography.body.text14
                                    .copyWith(
                                      color: kategori == 'Semua'
                                          ? Colors.grey[600]
                                          : Colors.black87,
                                      fontWeight: kategori == 'Semua'
                                          ? FontWeight.w500
                                          : FontWeight.w600,
                                    ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: InkWell(
                            onTap: () => pickDate(isStart: true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_outlined,
                                    size: 18,
                                    color: Colors.grey[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      dari != null
                                          ? formatDate(dari!)
                                          : 'Dari tanggal',
                                      style: MoonTokens
                                          .light
                                          .typography
                                          .body
                                          .text14
                                          .copyWith(color: Colors.grey[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: InkWell(
                            onTap: () => pickDate(isStart: false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_outlined,
                                    size: 18,
                                    color: Colors.grey[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      sampai != null
                                          ? formatDate(sampai!)
                                          : 'Sampai tanggal',
                                      style: MoonTokens
                                          .light
                                          .typography
                                          .body
                                          .text14
                                          .copyWith(color: Colors.grey[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: MoonButton(
                          onTap: () {
                            setState(() {
                              kategori = 'Semua';
                              dari = null;
                              sampai = null;
                            });
                          },
                          label: const Text('Reset'),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MoonFilledButton(
                          backgroundColor: colors.piccolo,
                          onTap: () {
                            this.setState(() {
                              _selectedKategori = kategori;
                              _selectedDari = dari;
                              _selectedSampai = sampai;
                            });
                            Navigator.of(context).pop();
                          },
                          label: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // -----------------------------------------------------
  // CARD ITEM PEMASUKAN
  // -----------------------------------------------------
  Widget _incomeCard(LaporanKeuanganModel item) {
    final colors = context.moonColors ?? MoonTokens.light.colors;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LaporanDetailScreen(data: item)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.piccolo.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up_rounded,
                color: colors.piccolo,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MoonTokens.light.typography.body.text16.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatRupiah(item.nominal),
                  style: MoonTokens.light.typography.body.text16.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  formatDate(item.tanggal),
                  style: MoonTokens.light.typography.body.text12.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
