class LaporanKeuanganModel {
  final String nama;
  final String? kategoriPemasukan;
  final String? kategoriPengeluaran;
  final DateTime tanggal;
  final int nominal;
  final String? verifikator;
  final String? buktiFoto;

  LaporanKeuanganModel({
    required this.nama,
    this.kategoriPemasukan,
    this.kategoriPengeluaran,
    required this.tanggal,
    required this.nominal,
    this.verifikator,
    this.buktiFoto,
  });
}
