class LaporanKeuanganModel {
  final String nama;
  final String? jenisPemasukan;
  final String? jenisPengeluaran;
  final String? kategoriPemasukan;
  final String? kategoriPengeluaran;
  final DateTime tanggal;
  final int nominal;
  final String verifikator;

  LaporanKeuanganModel({
    required this.nama,
    this.jenisPemasukan,
    this.jenisPengeluaran,
    this.kategoriPemasukan,
    this.kategoriPengeluaran,
    required this.tanggal,
    required this.nominal,
    this.verifikator = 'Admin Jawara',
  });
}
