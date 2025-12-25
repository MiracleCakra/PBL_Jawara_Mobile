import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/aspirasi_model.dart';
import 'package:SapaWarga_kel_2/services/aspirasi_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color _primaryColor = Color.fromARGB(255, 50, 52, 182);
const Color _deleteColor = Colors.red;
const Color _editColor = Colors.blue;

class WargaDetailKirimanScreen extends StatefulWidget {
  final AspirasiModel data;

  const WargaDetailKirimanScreen({super.key, required this.data});

  @override
  State<WargaDetailKirimanScreen> createState() =>
      _WargaDetailKirimanScreenState();
}

class _WargaDetailKirimanScreenState extends State<WargaDetailKirimanScreen> {
  final AspirasiService _aspirasiService = AspirasiService();

  void _navigateToEdit(BuildContext context) async {
    final result = await context.pushNamed<bool>(
      'warga_kirimanEdit',
      extra: widget.data,
    );

    if (result == true) {
      if (mounted) {
        context.pop(true);
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Hapus Kiriman',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Anda yakin ingin menghapus kiriman berjudul '${widget.data.judul}'? Tindakan ini tidak dapat dibatalkan.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await _aspirasiService.deleteAspiration(
                              widget.data.id!,
                            );
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              context.pop(true);
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menghapus: $e'),
                                  backgroundColor: Colors.grey.shade800,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            _buildOptionTile(
              key: const Key('option_edit_aspirasi'),
              icon: Icons.edit_rounded,
              color: _editColor,
              title: 'Edit Data',
              subtitle: 'Ubah detail pesan Anda',
              onTap: () {
                Navigator.pop(bc);
                _navigateToEdit(context);
              },
            ),

            _buildOptionTile(
              key: const Key('option_delete_aspirasi'),
              icon: Icons.delete_forever,
              color: _deleteColor,
              title: 'Hapus Data',
              subtitle: 'Hapus pesan ini secara permanen',
              onTap: () {
                Navigator.pop(bc);
                _showDeleteDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    Key? key,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      key: key,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.15),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      onTap: onTap,
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    switch (status) {
      case 'Approved':
      case 'Diterima':
        statusColor = const Color.fromARGB(255, 76, 58, 208);
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Ditolak':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: statusColor, size: 16),
          const SizedBox(width: 6),
          Text(
            status,
            key: const Key('detail_aspirasi_status'),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _SectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _IconRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.grey.shade500,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final String judul = data.judul;
    final String deskripsi = data.isi;
    final String status = data.status;
    final String pengirim = data.pengirim;
    final String tanggalStr = DateFormat('dd MMMM yyyy').format(data.tanggal);

    final String currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? '';
    final bool isOwner = data.userId == currentUserId;
    final bool canModify = status == 'Pending' && isOwner;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          "Detail Kiriman",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (canModify)
            IconButton(
              key: const Key('detail_aspirasi_more_options'),
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () => _showOptionsBottomSheet(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: "Informasi Pesan",
              children: [
                Text(
                  judul,
                  key: const Key('detail_aspirasi_judul'),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),

                // Status Metadata
                _IconRow(
                  icon: Icons.info_outline,
                  label: "Status Saat Ini",
                  value: status,
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 48, bottom: 8),
                  child: _buildStatusBadge(status),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SectionCard(
              title: "Metadata",
              children: [
                _IconRow(
                  icon: Icons.person_outline,
                  label: "Dikirim oleh",
                  value: pengirim,
                ),
                _IconRow(
                  icon: Icons.calendar_today_outlined,
                  label: "Tanggal Dikirim",
                  value: tanggalStr,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 3. DESKRIPSI (ISI PESAN)
            _SectionCard(
              title: "Deskripsi",
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    deskripsi,
                    key: const Key('detail_aspirasi_isi'),
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
