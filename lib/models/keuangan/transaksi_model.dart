class TransaksiModel {
  final String id;
  final String tipeTransaksi; // 'Pemasukan' atau 'Pengeluaran'
  final String jenisKategori; // Contoh: Iuran Wajib, Sumbangan, Biaya Keamanan, Acara
  final String namaSubjek; // Nama Warga (Pemasukan) atau Keterangan/Vendor (Pengeluaran)
  final double nominal; // Dalam Rupiah
  final DateTime tanggal;
  final String status; // 'Diterima' (Terkonfirmasi) atau 'Menunggu' (Verifikasi)
  final String scope; // 'RT 05' atau 'RW 05'
  final String verifikator; // Siapa yang mengkonfirmasi

  TransaksiModel({
    required this.id,
    required this.tipeTransaksi,
    required this.jenisKategori,
    required this.namaSubjek,
    required this.nominal,
    required this.tanggal,
    required this.status,
    required this.scope,
    this.verifikator = 'Admin Jawara',
  });

  // --- DATA SIMULASI ---
  static List<TransaksiModel> getSampleData() {
    return [
      // === Pemasukan RT 05 ===
      TransaksiModel(
        id: 'P001', tipeTransaksi: 'Pemasukan', jenisKategori: 'Iuran Bulanan',
        namaSubjek: 'Agus Sutanto', nominal: 50000.0,
        tanggal: DateTime(2025, 11, 20), status: 'Diterima', scope: 'RT 05',
      ),
      TransaksiModel(
        id: 'P002', tipeTransaksi: 'Pemasukan', jenisKategori: 'Iuran Mingguan',
        namaSubjek: 'Agus Sutanto', nominal: 25000.0,
        tanggal: DateTime(2025, 11, 21), status: 'Menunggu', scope: 'RT 05',
      ),
      TransaksiModel(
        id: 'P003', tipeTransaksi: 'Pemasukan', jenisKategori: 'Iuran Bulanan',
        namaSubjek: 'Dewi Lestari', nominal: 50000.0,
        tanggal: DateTime(2025, 10, 5), status: 'Diterima', scope: 'Bendahara RT 05',
      ),
      
      // === Pemasukan RW 05 (Dana Bersama/Khusus) ===
      TransaksiModel(
        id: 'P004', tipeTransaksi: 'Pemasukan', jenisKategori: 'Dana Sosial',
        namaSubjek: 'Dewi Lestari', nominal: 100000.0,
        tanggal: DateTime(2025, 11, 15), status: 'Diterima', scope: 'Bendahara RW 05',
      ),
      TransaksiModel(
        id: 'P005', tipeTransaksi: 'Pemasukan', jenisKategori: 'Donasi Kebersihan',
        namaSubjek: 'Bambang Irawan', nominal: 25000.0,
        tanggal: DateTime(2025, 10, 25), status: 'Diterima', scope: 'RW 05',
      ),
      
      // === Pengeluaran RT 05 ===
      TransaksiModel(
        id: 'K001', tipeTransaksi: 'Pengeluaran', jenisKategori: 'Biaya Keamanan',
        namaSubjek: 'Gaji Satpam Bulan Nov', nominal: 800000.0,
        tanggal: DateTime(2025, 11, 10), status: 'Diterima', scope: 'RT 05',
      ),
      // === Pengeluaran RW 05 ===
      TransaksiModel(
        id: 'K002', tipeTransaksi: 'Pengeluaran', jenisKategori: 'Pembelian Alat Kebersihan',
        namaSubjek: 'Toko Bangunan Jaya', nominal: 150000.0,
        tanggal: DateTime(2025, 11, 18), status: 'Diterima', scope: 'RW 05',
      ),
    ];
  }
}