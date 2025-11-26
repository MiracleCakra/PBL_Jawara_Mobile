class KegiatanBroadcastWarga {
  final String judul;
  final String pengirim;
  final String tanggal;
  final String kategori;
  final String konten;
  final String? lampiranGambarUrl;
  final List<String> lampiranDokumen;

  KegiatanBroadcastWarga({
    required this.judul,
    required this.pengirim,
    required this.tanggal,
    required this.konten,
    this.kategori = "Pemberitahuan",
    this.lampiranGambarUrl,
    this.lampiranDokumen = const [],
  });
}

List<KegiatanBroadcastWarga> dummyData = [
  KegiatanBroadcastWarga(
    judul: "Pemberitahuan Kerja Bakti",
    pengirim: "Ketua RT",
    tanggal: "12/10/2025",
    konten:
        "PENGUMUMAN — Kepada seluruh warga RT 03/RW 07, besok Minggu pukul 07.00 akan diadakan kerja bakti membersihkan selokan dan lingkungan sekitar.",
    lampiranGambarUrl: 'assets/images/images.png',
    lampiranDokumen: ["file_panduan.pdf", "file_absensi.pdf"],
  ),
  KegiatanBroadcastWarga(
    judul: "Pengumuman Lomba Kebersihan",
    pengirim: "Sekretaris RW",
    tanggal: "23/10/2025",
    kategori: "Pengumuman",
    konten:
        "Lomba Kebersihan Lingkungan akan dimulai minggu depan. Mohon partisipasi seluruh warga agar lingkungan tetap bersih dan asri.",
    lampiranGambarUrl: null,
    lampiranDokumen: ["Panduan_Lomba.pdf"],
  ),
  KegiatanBroadcastWarga(
    judul: "Himbauan Pembayaran Iuran",
    pengirim: "Bendahara RT",
    tanggal: "15/10/2025",
    kategori: "Keuangan",
    konten: "Dimohon segera melunasi iuran bulanan sebelum tanggal 20.",
    lampiranGambarUrl: null,
    lampiranDokumen: ["laporan_keuangan.pdf"],
  ),
  KegiatanBroadcastWarga(
    judul: "Undangan Rapat Program",
    pengirim: "Sekretaris RW",
    tanggal: "20/10/2025",
    kategori: "Pemberitahuan",
    konten: "Rapat Program Kerja akan diadakan pada hari Rabu di Balai Warga.",
    lampiranGambarUrl: null,
    lampiranDokumen: ["Undangan_Rapat.pdf"],
  ),
];
final List<Map<String, String>> dummyDataKegiatan = [
  {
    'judul': 'Pemberitahuan Kerja Bakti Lingkungan',
    'pj': 'Pak Habibi',
    'tanggal': '12/10/2025',
    'kategori': 'Sosial',
    'lokasi': 'Balai Warga RW 01',
    'deskripsi':
        'Kerja bakti membersihkan lingkungan dari sampah dan selokan untuk menjaga kebersihan dan keamanan lingkungan.',
    'dibuat_oleh': 'Admin Jawara',
    'has_docs': 'true',
  },
  {
    'judul': 'Parkir Liar di Depan Gerbang',
    'tanggal': '18/11/2025',
    'kategori': 'Keamanan',
    'lokasi': 'Pos Satpam',
    'deskripsi': 'Rapat membahas penertiban parkir liar.',
    'dibuat_oleh': 'Admin Jawara',
    'has_docs': 'false',
  },
];
