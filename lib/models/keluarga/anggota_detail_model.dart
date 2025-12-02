// ========================== MODEL ==========================
class AnggotaDetail {
  final String nik;
  final String nama;
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final String? jenisKelamin;
  final String? agama;
  final String? golonganDarah;
  final String? telepon;
  final String? pendidikanTerakhir;
  final String? pekerjaan;
  final String? peranKeluarga;
  final String? statusPenduduk;
  final String? namaKeluarga;

  AnggotaDetail({
    required this.nik,
    required this.nama,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.agama,
    this.golonganDarah,
    this.telepon,
    this.pendidikanTerakhir,
    this.pekerjaan,
    this.peranKeluarga,
    this.statusPenduduk,
    this.namaKeluarga,
  });
}