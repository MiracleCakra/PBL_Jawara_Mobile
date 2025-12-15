import 'package:flutter/material.dart';
import 'package:SapaWarga_kel_2/models/keuangan/laporan_keuangan_model.dart';
import 'package:SapaWarga_kel_2/screens/admin/laporan/detail_screen.dart';
import 'package:SapaWarga_kel_2/screens/admin/laporan/pengeluaran_tambah.dart';
import 'package:SapaWarga_kel_2/utils.dart'
    show formatDate, formatRupiah, openDateTimePicker;
import 'package:moon_design/moon_design.dart';
import 'package:SapaWarga_kel_2/utils.dart' show getPrimaryColor;

class SemuaPengeluaranScreen extends StatefulWidget {
  const SemuaPengeluaranScreen({super.key});

  @override
  State<SemuaPengeluaranScreen> createState() => _SemuaPengeluaranScreenState();
}

class _SemuaPengeluaranScreenState extends State<SemuaPengeluaranScreen> {
  late final TextEditingController _textController;
  List<LaporanKeuanganModel> _pengeluaranList = [];
  String _query = '';
  String _selectedKategori = 'Semua';
  DateTime? _selectedDari;
  DateTime? _selectedSampai;

  LaporanKeuanganModel laporanKeuanganModel = LaporanKeuanganModel(
    tanggal: DateTime.now(),
    nama: "",
    nominal: 0,
    kategoriPengeluaran: '',
    buktiFoto: '',
  );

  @override
  void initState() {
    _textController = TextEditingController();
    _loadPengeluaranData();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadPengeluaranData() async {
    final fetchedTagihan = await laporanKeuanganModel.fetchPengeluaran();
    setState(() {
      _pengeluaranList = fetchedTagihan;
    });
  }

  List<LaporanKeuanganModel> get _filteredData {
    var filtered = _pengeluaranList;

    // Filter berdasarkan query pencarian
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered
          .where((e) => e.nama.toLowerCase().contains(q))
          .toList();
    }

    // Filter berdasarkan kategori
    if (_selectedKategori != 'Semua') {
      filtered = filtered
          .where(
            (e) =>
                e.kategoriPengeluaran != null &&
                e.kategoriPengeluaran == _selectedKategori,
          )
          .toList();
    }

    // Filter berdasarkan tanggal
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
          "Semua Pengeluaran",
          style: MoonTokens.light.typography.heading.text20.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
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
                    itemBuilder: (context, index) {
                      final item = _filteredData[index];
                      return _incomeCard(item);
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: _filteredData.length,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PengeluaranTambahScreen()),
          );
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _pengeluaranList.add(
                LaporanKeuanganModel(
                  tanggal: result['tanggal'] ?? DateTime.now(),
                  nama: result['nama'] ?? '',
                  nominal: (result['nominal'] ?? 0).toInt(),
                  kategoriPengeluaran:
                      (result['kategoriPengeluaran'] == null ||
                          result['kategoriPengeluaran'] == '')
                      ? null
                      : result['kategoriPengeluaran'],
                  buktiFoto: result['buktiFoto'],
                ),
              );
            });
          }
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

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
                'Operasional',
                'Pembangunan',
                'Pemeliharaan',
                'Kegiatan Sosial',
                'Administrasi',
                'Honorarium',
                'Transportasi',
                'Konsumsi',
                'Peralatan',
                'Lainnya',
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
                      'Pilih Kategori Pengeluaran',
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

                  // Kategori Pengeluaran
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
                          backgroundColor: getPrimaryColor(context),
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

  Widget _incomeCard(LaporanKeuanganModel item) {
    final colors = context.moonColors ?? MoonTokens.light.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                LaporanDetailScreen(data: item, isPemasukkan: false),
          ),
        );
      },
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: MoonSquircleBorder(
            borderRadius: BorderRadius.circular(
              16,
            ).squircleBorderRadius(context),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.piccolo.withValues(alpha: 0.12),
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
                    color: const Color(0xFF2E7D32), // green accent for income
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
