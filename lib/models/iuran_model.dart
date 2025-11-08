class IuranModel {
  final int no;
  final String namaIuran;
  final String jenisIuran;
  final double nominal;
  final String status; // 'Aktif' atau 'Hidup'

  IuranModel({
    required this.no,
    required this.namaIuran,
    required this.jenisIuran,
    required this.nominal,
    required this.status,
  });

  // Sample data berdasarkan gambar
  static List<IuranModel> getSampleData() {
    return [
      IuranModel(
        no: 1,
        namaIuran: 'Bersih Desa',
        jenisIuran: 'Iuran Khusus',
        nominal: 200000.00,
        status: 'Aktif',
      ),
      IuranModel(
        no: 2,
        namaIuran: 'Mingguan',
        jenisIuran: 'Iuran Khusus',
        nominal: 12.00,
        status: 'Aktif',
      ),
      IuranModel(
        no: 3,
        namaIuran: 'Agustusan',
        jenisIuran: 'Iuran Khusus',
        nominal: 15.00,
        status: 'Aktif',
      ),
    ];
  }
}

enum JenisIuran {
  bulanan('Iuran Bulanan'),
  khusus('Iuran Khusus');

  final String displayName;
  const JenisIuran(this.displayName);
}
