import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/admin/penduduk/penerimaan/daftar_penerimaan_warga.dart';
import 'package:jawara_pintar_kel_5/widget/moon_result_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailPenerimaanWargaPage extends StatefulWidget {
  final PenerimaanWarga penerimaan;

  const DetailPenerimaanWargaPage({super.key, required this.penerimaan});

  @override
  State<DetailPenerimaanWargaPage> createState() =>
      _DetailPenerimaanWargaPageState();
}

class _DetailPenerimaanWargaPageState extends State<DetailPenerimaanWargaPage> {
  final supabase = Supabase.instance.client;
  static const Color _primaryColor = Color(0xFF4E46B4);

  List<Map<String, dynamic>> _anggotaKeluarga = [];
  bool _isLoadingAnggota = true;

  @override
  void initState() {
    super.initState();
    _fetchAnggotaKeluarga();
  }

  Future<void> _fetchAnggotaKeluarga() async {
    try {
      setState(() => _isLoadingAnggota = true);

      if (widget.penerimaan.namaKeluarga != null &&
          widget.penerimaan.namaKeluarga!.isNotEmpty) {
        final data = await supabase
            .from('warga')
            .select('id, nama, gender, status_penerimaan')
            .eq('nama_keluarga', widget.penerimaan.namaKeluarga!);

        setState(() {
          _anggotaKeluarga = List<Map<String, dynamic>>.from(data);
          _isLoadingAnggota = false;
        });
      } else {
        setState(() => _isLoadingAnggota = false);
      }
    } catch (error) {
      debugPrint('Error fetching anggota keluarga: $error');
      setState(() => _isLoadingAnggota = false);
    }
  }

  void _handleApprove() async {
    await supabase
        .from('warga')
        .update({'status_penerimaan': 'Diterima'})
        .eq('id', widget.penerimaan.nik);
    await showResultModal(
      context,
      type: ResultType.success,
      title: 'Berhasil',
      description: 'Pendaftaran warga "${widget.penerimaan.nama}" disetujui.',
      actionLabel: 'Selesai',
      autoProceed: true,
    );
    if (mounted) context.pop();
  }

  void _handleReject() {
    _showRejectReasonBottomSheet();
  }

  void _showRejectReasonBottomSheet() {
    final TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHandle(),
                  const SizedBox(height: 16),
                  const Text(
                    'Alasan Penolakan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    maxLines: 5,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan alasan penolakan...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: _primaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (reasonController.text.trim().isEmpty) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Alasan penolakan harus diisi'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context);
                        await supabase
                            .from('warga')
                            .update({
                              'status_penerimaan': 'Ditolak',
                              'alasan_penolakan': reasonController.text.trim(),
                            })
                            .eq('id', widget.penerimaan.nik);
                        await showResultModal(
                          context,
                          type: ResultType.error,
                          title: 'Ditolak',
                          description:
                              'Pendaftaran warga "${widget.penerimaan.nama}" telah ditolak.',
                          actionLabel: 'Selesai',
                          autoProceed: true,
                        );
                        if (mounted) context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Kirim Penolakan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showActionButtons =
        widget.penerimaan.status.toLowerCase() == 'pending' ||
        widget.penerimaan.status.toLowerCase() == 'ditolak';

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
          'Detail Pendaftaran Warga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileSection(),
                const SizedBox(height: 16),
                _buildInfoCard(),
                const SizedBox(height: 16),
                _buildAnggotaKeluargaSection(),
                const SizedBox(height: 16),
                _buildFotoIdentitasCard(),
                SizedBox(height: showActionButtons ? 80 : 16),
              ],
            ),
          ),
          if (showActionButtons) _buildStickyFooter(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
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
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: _primaryColor.withOpacity(0.1),
            child: Icon(
              widget.penerimaan.jenisKelamin.toLowerCase() == 'laki-laki'
                  ? Icons.male
                  : Icons.female,
              size: 40,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.penerimaan.nama,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            widget.penerimaan.email ?? '-',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
            icon: Icons.badge_outlined,
            label: 'NIK',
            value: widget.penerimaan.nik,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: widget.penerimaan.jenisKelamin.toLowerCase() == 'laki-laki'
                ? Icons.male
                : Icons.female,
            label: 'Jenis Kelamin',
            value: widget.penerimaan.jenisKelamin,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.home_outlined,
            label: 'Rumah Saat Ini',
            value: widget.penerimaan.alamatRumah ?? '-',
          ),
          _buildDivider(),
          _buildInfoRowWithBadge(
            icon: Icons.info_outline,
            label: 'Status Pendaftaran',
            status: widget.penerimaan.status,
          ),
        ],
      ),
    );
  }

  Widget _buildAnggotaKeluargaSection() {
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
        if (_isLoadingAnggota)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_anggotaKeluarga.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Center(
              child: Text(
                'Tidak ada data anggota keluarga',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          )
        else
          ..._anggotaKeluarga.map((anggota) => _buildAnggotaCard(anggota)),
      ],
    );
  }

  Widget _buildAnggotaCard(Map<String, dynamic> anggota) {
    // Get status color
    Color statusColor;
    Color statusBgColor;
    switch ((anggota['status_penerimaan'] ?? '').toLowerCase()) {
      case 'diterima':
        statusColor = const Color(0xFF16A34A);
        statusBgColor = const Color(0xFFDCFCE7);
        break;
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusBgColor = const Color(0xFFFEF3C7);
        break;
      case 'ditolak':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusBgColor = const Color(0xFFF3F4F6);
    }

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
                  anggota['nama'] ?? '-',
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
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  anggota['status_penerimaan'] ?? 'Pending',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAnggotaInfoRow('NIK', anggota['id'] ?? '-'),
          const SizedBox(height: 8),
          _buildAnggotaInfoRow('Jenis Kelamin', anggota['gender'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildFotoIdentitasCard() {
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
          Text(
            'Foto Identitas:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              '${widget.penerimaan.foto}',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Foto Identitas',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _handleReject,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tolak',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleApprove,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF16A34A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Setujui',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
                  color: widget.penerimaan.statusBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.penerimaan.statusColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: widget.penerimaan.statusColor,
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
}
