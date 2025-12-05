class Anggota {
  final String nik;
  final String nama;
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final String? jenisKelamin;
  final String? agama;
  final String? golonganDarah;
  final String? telepon;
  final String? email;
  final String? pendidikanTerakhir;
  final String? pekerjaan;
  final String? peranKeluarga;
  final String? statusPenduduk;
  final String? statusHidup;
  final String? namaKeluarga;
  final String? status; // Aktif/Nonaktif utk list
  final String? fotoKtp;
  final String? rumahSaatIni;

  Anggota({
    required this.nik,
    required this.nama,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.agama,
    this.golonganDarah,
    this.telepon,
    this.email,
    this.pendidikanTerakhir,
    this.pekerjaan,
    this.peranKeluarga,
    this.statusPenduduk,
    this.statusHidup,
    this.namaKeluarga,
    this.status = "Aktif",
    this.fotoKtp,
    this.rumahSaatIni,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      nik: json['nik'] ?? '',
      nama: json['nama'] ?? '',
      tempatLahir: json['tempat_lahir'],
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.tryParse(json['tanggal_lahir'])
          : null,
      jenisKelamin: json['jenis_kelamin'],
      agama: json['agama'],
      golonganDarah: json['golongan_darah'],
      telepon: json['telepon'],
      email: json['email'],
      pendidikanTerakhir: json['pendidikan_terakhir'],
      pekerjaan: json['pekerjaan'],
      peranKeluarga: json['peran_keluarga'],
      statusPenduduk: json['status_penduduk'],
      statusHidup: json['status_hidup'],
      namaKeluarga: json['nama_keluarga'],
      status: json['status'] ?? "Aktif",
      fotoKtp: json['foto_ktp'],
      rumahSaatIni: json['rumah_saat_ini'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nik': nik,
      'nama': nama,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir?.toIso8601String(),
      'jenis_kelamin': jenisKelamin,
      'agama': agama,
      'golongan_darah': golonganDarah,
      'telepon': telepon,
      'email': email,
      'pendidikan_terakhir': pendidikanTerakhir,
      'pekerjaan': pekerjaan,
      'peran_keluarga': peranKeluarga,
      'status_penduduk': statusPenduduk,
      'status_hidup': statusHidup,
      'nama_keluarga': namaKeluarga,
      'status': status,
      'foto_ktp': fotoKtp,
      'rumah_saat_ini': rumahSaatIni,
    };
  }

  Anggota copyWith({
    String? nik,
    String? nama,
    String? tempatLahir,
    DateTime? tanggalLahir,
    String? jenisKelamin,
    String? agama,
    String? golonganDarah,
    String? telepon,
    String? pendidikanTerakhir,
    String? pekerjaan,
    String? peranKeluarga,
    String? statusPenduduk,
    String? namaKeluarga,
    String? status,
    String? fotoKtp,
    String? rumahSaatIni,
  }) {
    return Anggota(
      nik: nik ?? this.nik,
      nama: nama ?? this.nama,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      agama: agama ?? this.agama,
      golonganDarah: golonganDarah ?? this.golonganDarah,
      telepon: telepon ?? this.telepon,
      pendidikanTerakhir: pendidikanTerakhir ?? this.pendidikanTerakhir,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      peranKeluarga: peranKeluarga ?? this.peranKeluarga,
      statusPenduduk: statusPenduduk ?? this.statusPenduduk,
      namaKeluarga: namaKeluarga ?? this.namaKeluarga,
      status: status ?? this.status,
      fotoKtp: fotoKtp ?? this.fotoKtp,
      rumahSaatIni: rumahSaatIni ?? this.rumahSaatIni,
    );
  }
}

final List<Anggota> dummyAnggota = [
  Anggota(
    nik: "3512345678900001",
    nama: "Budi Santoso",
    jenisKelamin: "Pria",
    peranKeluarga: "Kepala Keluarga",
    namaKeluarga: "Keluarga Santoso",
    pendidikanTerakhir: "S1",
    pekerjaan: "Karyawan",
    status: "Aktif",
  ),
  Anggota(
    nik: "3512345678900002",
    nama: "Siti Rahmawati",
    jenisKelamin: "Wanita",
    peranKeluarga: "Ibu",
    namaKeluarga: "Keluarga Santoso",
    pendidikanTerakhir: "SMA",
    pekerjaan: "Ibu Rumah Tangga",
    status: "Aktif",
  ),
  Anggota(
    nik: "3512345678900003",
    nama: "Aldi Rahman",
    jenisKelamin: "Pria",
    peranKeluarga: "Anak",
    namaKeluarga: "Keluarga Santoso",
    pendidikanTerakhir: "SMP",
    status: "Nonaktif",
  ),
];
