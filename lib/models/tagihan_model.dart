class TagihanModel {
  final String namaKeluarga;
  final String statusKeluarga;
  final String iuran;
  final String kodeTagihan;
  final double nominal;
  final DateTime periode;
  final String status;

  TagihanModel({
    required this.namaKeluarga,
    required this.statusKeluarga,
    required this.iuran,
    required this.kodeTagihan,
    required this.nominal,
    required this.periode,
    required this.status,
  });

  static List<TagihanModel> getSampleData() {
    return [
      TagihanModel(
        namaKeluarga: 'Keluarga Habibie Ed Dien',
        statusKeluarga: 'Aktif',
        iuran: 'Mingguan',
        kodeTagihan: 'IR17545BA501',
        nominal: 10.00,
        periode: DateTime(2025, 10, 8),
        status: 'Belum Dibayar',
      ),
      TagihanModel(
        namaKeluarga: 'Keluarga Habibie Ed Dien',
        statusKeluarga: 'Aktif',
        iuran: 'Mingguan',
        kodeTagihan: 'IR18570ZKX01',
        nominal: 10.00,
        periode: DateTime(2025, 10, 15),
        status: 'Menunggu Bukti',
      ),
      TagihanModel(
        namaKeluarga: 'Keluarga Habibie Ed Dien',
        statusKeluarga: 'Aktif',
        iuran: 'Mingguan',
        kodeTagihan: 'IR223936NM01',
        nominal: 10.00,
        periode: DateTime(2025, 9, 30),
        status: 'Menunggu Verifikasi',
      ),
      TagihanModel(
        namaKeluarga: 'Keluarga Mara Nunez',
        statusKeluarga: 'Aktif',
        iuran: 'Mingguan',
        kodeTagihan: 'IR223936ZJQ2',
        nominal: 10.00,
        periode: DateTime(2025, 9, 30),
        status: 'Diterima',
      ),
      TagihanModel(
        namaKeluarga: 'Keluarga Habibie Ed Dien',
        statusKeluarga: 'Aktif',
        iuran: 'Agustusan',
        kodeTagihan: 'IR224406901',
        nominal: 15.00,
        periode: DateTime(2025, 10, 10),
        status: 'Ditolak',
      ),
      TagihanModel(
        namaKeluarga: 'Keluarga Mara Nunez',
        statusKeluarga: 'Aktif',
        iuran: 'Agustusan',
        kodeTagihan: 'IR224406BC02',
        nominal: 15.00,
        periode: DateTime(2025, 10, 10),
        status: 'Belum Dibayar',
      ),
      TagihanModel(
        namaKeluarga: 'Keluarga Raudhil Firdaus Naufal',
        statusKeluarga: 'Aktif',
        iuran: 'Agustusan',
        kodeTagihan: 'IR224432PP01',
        nominal: 15.00,
        periode: DateTime(2025, 9, 30),
        status: 'Belum Dibayar',
      ),
      TagihanModel(
        namaKeluarga: 'Keluarga varizky naldiba rimra',
        statusKeluarga: 'Aktif',
        iuran: 'Bersih Desa',
        kodeTagihan: 'IR224432KE02',
        nominal: 15.00,
        periode: DateTime(2025, 9, 30),
        status: 'Belum Dibayar',
      ),
      TagihanModel(
        namaKeluarga: 'Keluarga Anti Micin',
        statusKeluarga: 'Aktif',
        iuran: 'Kerja Bakti',
        kodeTagihan: 'IR121530BS01',
        nominal: 10.00,
        periode: DateTime(2025, 10, 9),
        status: 'Belum Dibayar',
      ),
      TagihanModel(
        namaKeluarga: 'Keluarga Mara Nunez',
        statusKeluarga: 'Aktif',
        iuran: 'Harian',
        kodeTagihan: 'IR121530WV02',
        nominal: 10.00,
        periode: DateTime(2025, 10, 9),
        status: 'Belum Dibayar',
      ),
    ];
  }
}
