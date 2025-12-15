import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/screens/admin/penduduk/penerimaan/daftar_penerimaan_warga.dart';
import 'package:SapaWarga_kel_2/widget/moon_result_modal.dart';
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

  void _showActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, color: Colors.red, size: 24),
                  ),
                  title: const Text(
                    'Tolak Pendaftaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    'Tolak pendaftaran warga ini',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleReject();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Setujui Pendaftaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  subtitle: Text(
                    'Setujui pendaftaran warga ini',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleApprove();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showActionMenu =
        widget.penerimaan.status.toLowerCase() == 'pending' ||
        widget.penerimaan.status.toLowerCase() == 'ditolak';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Detail Pendaftaran Warga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (showActionMenu)
            IconButton(
              onPressed: _showActionBottomSheet,
              icon: const Icon(Icons.more_vert, color: Colors.black),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const SizedBox(height: 16),
              _buildInfoCard(),
              const SizedBox(height: 16),
              _buildDetailInfoCard(),
              const SizedBox(height: 16),
              _buildInformasiTambahanCard(),
              const SizedBox(height: 16),
              _buildStatusCard(),
              const SizedBox(height: 16),
              _buildFotoIdentitasCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey.shade300,
            child: Icon(
              widget.penerimaan.jenisKelamin.toLowerCase() == 'laki-laki'
                  ? Icons.male
                  : Icons.female,
              size: 40,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nama Lengkap',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  widget.penerimaan.nama,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'NIK: ${widget.penerimaan.nik}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _SectionCard(
      title: 'Data Diri',
      children: [
        _IconTextRow(icon: Icons.phone, title: 'Nomor Telepon', value: '-'),
        _IconTextRow(
          icon: Icons.email,
          title: 'Email (Opsional)',
          value: widget.penerimaan.email ?? '-',
        ),
        _IconTextRow(
          icon: Icons.location_city,
          title: 'Tempat Lahir',
          value: '-',
        ),
        _IconTextRow(icon: Icons.event, title: 'Tanggal Lahir', value: '-'),
        _IconTextRow(icon: Icons.home, title: 'Rumah Saat Ini', value: '-'),
      ],
    );
  }

  Widget _buildDetailInfoCard() {
    return _SectionCard(
      title: 'Atribut Personal',
      children: [
        _IconTextRow(
          icon: Icons.people,
          title: 'Jenis Kelamin',
          value: widget.penerimaan.jenisKelamin,
        ),
        _IconTextRow(icon: Icons.self_improvement, title: 'Agama', value: '-'),
        _IconTextRow(
          icon: Icons.bloodtype,
          title: 'Golongan Darah',
          value: '-',
        ),
      ],
    );
  }

  Widget _buildInformasiTambahanCard() {
    return _SectionCard(
      title: 'Peran & Latar Belakang',
      children: [
        _IconTextRow(
          icon: Icons.family_restroom,
          title: 'Peran Keluarga',
          value: '-',
        ),
        _IconTextRow(
          icon: Icons.school,
          title: 'Pendidikan Terakhir',
          value: '-',
        ),
        _IconTextRow(icon: Icons.work, title: 'Pekerjaan', value: '-'),
      ],
    );
  }

  Widget _buildStatusCard() {
    return _SectionCard(
      title: 'Status',
      children: [
        _IconTextRow(icon: Icons.favorite, title: 'Status Hidup', value: '-'),
        _IconTextRow(
          icon: Icons.verified,
          title: 'Status Kependudukan',
          value: '-',
        ),
        _IconTextRowWithBadge(
          icon: Icons.verified,
          title: 'Status Pendaftaran',
          status: widget.penerimaan.status,
          statusColor: widget.penerimaan.statusColor,
          statusBackgroundColor: widget.penerimaan.statusBackgroundColor,
        ),
      ],
    );
  }

  Widget _buildFotoIdentitasCard() {
    return _SectionCard(
      title: 'Foto Kartu Keluarga',
      children: [
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
    );
  }

}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...children.map(
              (w) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconTextRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _IconTextRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(78, 70, 180, 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF4E46B4)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconTextRowWithBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final Color statusColor;
  final Color statusBackgroundColor;
  const _IconTextRowWithBadge({
    required this.icon,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.statusBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(78, 70, 180, 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF4E46B4)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
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
}
