import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/keluarga/daftar_keluarga.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Model for Anggota Keluarga
class AnggotaKeluarga {
  final String nama;
  final String nik;
  final String peran;
  final String jenisKelamin;
  final String? tanggalLahir;
  final String status;

  const AnggotaKeluarga({
    required this.nama,
    required this.nik,
    required this.peran,
    required this.jenisKelamin,
    this.tanggalLahir,
    required this.status,
  });

  // Get status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'aktif':
        return const Color(0xFF16A34A); // Green
      case 'nonaktif':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280);
    }
  }

  // Get status background color
  Color get statusBackgroundColor {
    switch (status.toLowerCase()) {
      case 'aktif':
        return const Color(0xFFDCFCE7); // Light green
      case 'nonaktif':
        return const Color(0xFFFEE2E2); // Light red
      default:
        return const Color(0xFFF3F4F6);
    }
  }
}

// Model for Mutasi Keluarga
class MutasiKeluarga {
  final String keluarga;
  final String alamatLama;
  final String alamatBaru;
  final String tanggalMutasi;
  final String jenisMutasi;
  final String alasan;

  const MutasiKeluarga({
    required this.keluarga,
    required this.alamatLama,
    required this.alamatBaru,
    required this.tanggalMutasi,
    required this.jenisMutasi,
    required this.alasan,
  });
}

class DetailKeluargaPage extends StatefulWidget {
  final Keluarga keluarga;
  const DetailKeluargaPage({super.key, required this.keluarga});

  @override
  State<DetailKeluargaPage> createState() => _DetailKeluargaPage();
}

class _DetailKeluargaPage extends State<DetailKeluargaPage> {
  late final SupabaseClient supabase;

  // DetailKeluargaPage({super.key, required this.keluarga});

  List<AnggotaKeluarga> _allAnggotaKeluarga = [];

  @override
  void initState() {
    super.initState();
    // Fetch data when the page is initialized
    supabase = Supabase.instance.client;
    fetchAnggotaKeluarga();
  }

  fetchAnggotaKeluarga() async {
    try {
      // -- TAMBAHKAN PRINT UNTUK DEBUGGING --
      debugPrint(
        "Mencoba memuat data Anggota Keluarga. Status login: ${supabase.auth.currentUser?.email ?? 'Tidak Login'}",
      );
      // ------------------------------------
      final response = await Supabase.instance.client
          .from('keluarga_warga')
          .select(
            '*, warga!warga_id(nama, gender, tanggal_lahir, status_penduduk)',
          );

      // Map data from Supabase to List<PenerimaanWarga>
      setState(() {
        _allAnggotaKeluarga = response.map<AnggotaKeluarga>((item) {
          return AnggotaKeluarga(
            nama: item['warga']['nama'],
            nik: item['warga_id'],
            peran: item['peran'],
            jenisKelamin: item['warga']['gender'],
            tanggalLahir: item['warga']['tanggal_lahir'],
            status: item['warga']['status_penduduk'],
          );
        }).toList();
      });
      print("Data fetched successfully: $_allAnggotaKeluarga");
    } catch (e) {
      debugPrint("Gagal memuat data warga: $e");
    }
  }

  // Sample anggota keluarga data
  // List<AnggotaKeluarga> get _anggotaKeluarga {
  //   // This would come from API/database in real implementation
  //   return const [
  //     AnggotaKeluarga(
  //       nama: 'Habibie Ed Dien',
  //       nik: '2341123456756789',
  //       peran: 'Kepala Keluarga',
  //       jenisKelamin: 'Laki-laki',
  //       tanggalLahir: '-',
  //       status: 'Aktif',
  //     ),
  //     AnggotaKeluarga(
  //       nama: 'Cukurukuk',
  //       nik: '123456789123456',
  //       peran: 'Anak',
  //       jenisKelamin: 'Laki-laki',
  //       tanggalLahir: '27 Feb 1999 00',
  //       status: 'Aktif',
  //     ),
  //   ];
  // }

  // Sample mutasi keluarga data
  List<MutasiKeluarga> get _mutasiKeluarga {
    // This would come from API/database in real implementation
    return [
      MutasiKeluarga(
        keluarga: widget.keluarga.namaKeluarga,
        alamatLama: widget.keluarga.alamatLama ?? '-',
        alamatBaru: widget.keluarga.alamat,
        tanggalMutasi: widget.keluarga.tanggalMutasi ?? '-',
        jenisMutasi: widget.keluarga.jenisMutasi ?? '',
        alasan: widget.keluarga.alasanMutasi ?? '-',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Detail Keluarga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(context),
          const SizedBox(height: 16),
          _buildAnggotaKeluargaSection(context),
          const SizedBox(height: 16),
          _buildMutasiKeluargaSection(context),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.family_restroom,
            label: 'Nama Keluarga',
            value: widget.keluarga.namaKeluarga,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.person,
            label: 'Kepala Keluarga',
            value: widget.keluarga.kepalaKeluarga,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.home_outlined,
            label: 'Rumah Saat Ini',
            value: widget.keluarga.alamat,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.key_outlined,
            label: 'Status Kepemilikan',
            value: widget.keluarga.pemilik, // This would come from data
          ),
          _buildDivider(),
          _buildInfoRowWithBadge(
            icon: Icons.info_outline,
            label: 'Status Keluarga',
            status: widget.keluarga.status,
            statusColor: widget.keluarga.statusColor,
            statusBackgroundColor: widget.keluarga.statusBackgroundColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAnggotaKeluargaSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Anggota Keluarga:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
        ),
        ..._allAnggotaKeluarga.map((anggota) => _buildAnggotaCard(anggota)),
      ],
    );
  }

  Widget _buildAnggotaCard(AnggotaKeluarga anggota) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  anggota.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: anggota.statusBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: anggota.statusColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  anggota.status,
                  style: TextStyle(
                    color: anggota.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAnggotaInfoRow('NIK', anggota.nik),
          const SizedBox(height: 8),
          _buildAnggotaInfoRow('Peran', anggota.peran),
          const SizedBox(height: 8),
          _buildAnggotaInfoRow('Jenis Kelamin', anggota.jenisKelamin),
          if (anggota.tanggalLahir != null && anggota.tanggalLahir != '-') ...[
            const SizedBox(height: 8),
            _buildAnggotaInfoRow('Tanggal Lahir', anggota.tanggalLahir!),
          ],
        ],
      ),
    );
  }

  Widget _buildAnggotaInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithBadge({
    required IconData icon,
    required String label,
    required String status,
    required Color statusColor,
    required Color statusBackgroundColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: Colors.grey[200], height: 1, thickness: 1),
    );
  }

  Widget _buildMutasiKeluargaSection(BuildContext context) {
    if (_mutasiKeluarga.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Data Mutasi Keluarga:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
        ),
        ..._mutasiKeluarga.map((mutasi) => _buildMutasiCard(mutasi)),
      ],
    );
  }

  Widget _buildMutasiCard(MutasiKeluarga mutasi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Builder(
          builder: (context) => InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // TODO: Navigate to detail mutasi page when created
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Halaman detail mutasi belum tersedia'),
                  backgroundColor: Color(0xFF8B5CF6),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMutasiInfoRow('Keluarga', mutasi.keluarga),
                  const SizedBox(height: 8),
                  _buildMutasiInfoRow('Alamat Lama', mutasi.alamatLama),
                  const SizedBox(height: 8),
                  _buildMutasiInfoRow('Alamat Baru', mutasi.alamatBaru),
                  const SizedBox(height: 8),
                  _buildMutasiInfoRow('Tanggal Mutasi', mutasi.tanggalMutasi),
                  const SizedBox(height: 8),
                  _buildMutasiInfoRowWithBadge(
                    'Jenis Mutasi',
                    mutasi.jenisMutasi,
                  ),
                  const SizedBox(height: 8),
                  _buildMutasiInfoRow('Alasan', mutasi.alasan),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMutasiInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMutasiInfoRowWithBadge(String label, String jenisMutasi) {
    // Get badge styling based on jenis mutasi (same logic as daftar mutasi)
    final bool isOutlineStyle = jenisMutasi.toLowerCase() == 'keluar wilayah';
    const Color primaryColor = Color(0xFF4E46B4);
    final Color backgroundColor = isOutlineStyle
        ? Colors.transparent
        : primaryColor;
    final Color textColor = isOutlineStyle ? primaryColor : Colors.white;
    final double borderWidth = isOutlineStyle ? 1.5 : 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor, width: borderWidth),
            ),
            child: Text(
              jenisMutasi,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
