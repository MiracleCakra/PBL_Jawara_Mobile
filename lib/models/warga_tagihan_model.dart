class WargaTagihanModel {
  final String namaKeluarga;
  final String statusKeluarga;
  final String iuran;
  final String kodeTagihan;
  final double nominal;
  final DateTime periode;
  final String status;

  WargaTagihanModel({
    required this.namaKeluarga,
    required this.statusKeluarga,
    required this.iuran,
    required this.kodeTagihan,
    required this.nominal,
    required this.periode,
    required this.status,
  });

  static List<WargaTagihanModel> getSampleData() {
    return [
      WargaTagihanModel(
        namaKeluarga: 'Keluarga Susanto',
        statusKeluarga: 'Aktif',
        iuran: 'Mingguan',
        kodeTagihan: 'IR17545BA501',
        nominal: 10.00,
        periode: DateTime(2025, 10, 8),
        status: 'Belum Dibayar',
      ),
      WargaTagihanModel(
        namaKeluarga: 'Keluarga Susanto',
        statusKeluarga: 'Aktif',
        iuran: 'Mingguan',
        kodeTagihan: 'IR18570ZKX01',
        nominal: 10.00,
        periode: DateTime(2025, 10, 15),
        status: 'Diterima',
      ),
      WargaTagihanModel(
        namaKeluarga: 'Keluarga Susanto',
        statusKeluarga: 'Aktif',
        iuran: 'Mingguan',
        kodeTagihan: 'IR223936NM01',
        nominal: 10.00,
        periode: DateTime(2025, 9, 30),
        status: 'Diterima',
      ),
      WargaTagihanModel(
        namaKeluarga: 'Keluarga Susanto',
        statusKeluarga: 'Aktif',
        iuran: 'Mingguan',
        kodeTagihan: 'IR223936ZJQ2',
        nominal: 10.00,
        periode: DateTime(2025, 9, 30),
        status: 'Diterima',
      ),
      WargaTagihanModel(
        namaKeluarga: 'Keluarga Susanto',
        statusKeluarga: 'Aktif',
        iuran: 'Agustusan',
        kodeTagihan: 'IR224406901',
        nominal: 15.00,
        periode: DateTime(2025, 10, 10),
        status: 'Ditolak',
      ),
      WargaTagihanModel(
        namaKeluarga: 'Keluarga Susanto',
        statusKeluarga: 'Aktif',
        iuran: 'Agustusan',
        kodeTagihan: 'IR224406BC02',
        nominal: 15.00,
        periode: DateTime(2025, 10, 10),
        status: 'Belum Dibayar',
      ),
      WargaTagihanModel(
        namaKeluarga: 'Keluarga Susanto',
        statusKeluarga: 'Aktif',
        iuran: 'Agustusan',
        kodeTagihan: 'IR224432PP01',
        nominal: 15.00,
        periode: DateTime(2025, 9, 30),
        status: 'Diterima',
      ),
      WargaTagihanModel(
        namaKeluarga: 'Keluarga Susanto',
        statusKeluarga: 'Aktif',
        iuran: 'Bersih Desa',
        kodeTagihan: 'IR224432KE02',
        nominal: 15.00,
        periode: DateTime(2025, 9, 30),
        status: 'Diterima',
      ),
      WargaTagihanModel(
        namaKeluarga: 'Keluarga Susanto',
        statusKeluarga: 'Aktif',
        iuran: 'Kerja Bakti',
        kodeTagihan: 'IR121530BS01',
        nominal: 10.00,
        periode: DateTime(2025, 10, 9),
        status: 'Diterima',
      ),
      WargaTagihanModel(
        namaKeluarga: 'Keluarga Susanto',
        statusKeluarga: 'Aktif',
        iuran: 'Mingguan',
        kodeTagihan: 'IR121530WV02',
        nominal: 10.00,
        periode: DateTime(2025, 10, 9),
        status: 'Diterima',
      ),
    ];
  }
}
