class LaporanKeuanganModel {
  final String nama;
  final String jenisPemasukan;
  final DateTime tanggal;
  final int nominal;
  final String verifikator;

  LaporanKeuanganModel({
    required this.nama,
    this.jenisPemasukan = 'Pemasukkan Halal',
    required this.tanggal,
    required this.nominal,
    this.verifikator = 'Admin Jawara',
  });
}
