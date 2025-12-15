import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/screens/admin/penduduk/rumah/daftar_rumah.dart';
import 'package:SapaWarga_kel_2/widget/moon_result_modal.dart';
import 'package:moon_design/moon_design.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailRumahPage extends StatelessWidget {
  final Rumah rumah;

  const DetailRumahPage({super.key, required this.rumah});

  static const Color _primaryColor = Color(0xFF4E46B4);

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
          'Detail Rumah',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          _MoreMenu(
            rumahAddress: rumah.alamat,
            rumah: rumah,
            onEdit: () {
              context.pushNamed('rumahEdit', extra: rumah);
            },
            onDeleteConfirmed: () async {
              final confirmed = await _showDeleteConfirmationDialog(
                context: context,
                title: 'Hapus Data Rumah?',
                message:
                    'Apakah Anda yakin ingin menghapus data rumah "${rumah.alamat}"? Data yang sudah dihapus tidak dapat dikembalikan.',
              );
              if (confirmed == true) {
                // Call delete service here (Supabase)
                try {
                  // Delete row(s) where alamat equals the rumah.alamat
                  await Supabase.instance.client
                      .from('rumah')
                      .delete()
                      .eq('alamat', rumah.alamat);
                  // Show success modal and return a positive result to caller
                  await showResultModal(
                    context,
                    type: ResultType.success,
                    title: 'Berhasil',
                    description: 'Data rumah "${rumah.alamat}" telah dihapus.',
                    actionLabel: 'Selesai',
                    autoProceed: true,
                  );
                  if (context.mounted)
                    Navigator.of(context).pop(true); // return true
                } catch (e) {
                  // Show error modal and do not pop
                  await showResultModal(
                    context,
                    type: ResultType.error,
                    title: 'Gagal',
                    description: 'Gagal menghapus rumah: $e',
                    actionLabel: 'Tutup',
                  );
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          // const SizedBox(height: 16),
          // _buildRiwayatPenghuniCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final isDitempati = rumah.isDitempati;

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
          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: _primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alamat',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rumah.alamat,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          // Status
          _buildDetailRow(
            icon: Icons.info_outline,
            label: 'Status',
            value: rumah.status,
            valueColor: isDitempati ? _primaryColor : const Color(0xFFB794F6),
            showBadge: true,
          ),
          const SizedBox(height: 16),
          // // Tipe
          // _buildDetailRow(
          //   icon: Icons.business_outlined,
          //   label: 'Tipe Bangunan',
          //   value: rumah.type,
          // ),
          const SizedBox(height: 16),
          // Penghuni
          _buildDetailRow(
            icon: Icons.people_outline,
            label: 'Jumlah Penghuni',
            value: '${rumah.residents} orang',
          ),
          const SizedBox(height: 16),
          // Pemilik
          _buildDetailRow(
            icon: Icons.person_outline,
            label: 'Pemilik',
            value: rumah.pemilik ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool showBadge = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              showBadge
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: valueColor?.withOpacity(0.1) ?? Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: valueColor?.withOpacity(0.3) ?? Colors.grey,
                        ),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: valueColor ?? Colors.black87,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? Colors.black87,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatPenghuniCard() {
    // Sample resident history data
    final residents = [
      {
        'keluarga': 'Keluarga Anti Micin',
        'kepalaKeluarga': 'Anti Micin',
        'tanggalMasuk': '15 Oktober 2025',
        'tanggalKeluar': 'Masih Tinggal',
        'isActive': true,
      },
      {
        'keluarga': 'Keluarga Mara Nunez',
        'kepalaKeluarga': 'Mara Nunez',
        'tanggalMasuk': '30 September 2025',
        'tanggalKeluar': 'Masih Tinggal',
        'isActive': true,
      },
      {
        'keluarga': 'Keluarga Ijat',
        'kepalaKeluarga': 'Ijat',
        'tanggalMasuk': '12 Oktober 2025',
        'tanggalKeluar': '24 Oktober 2026',
        'isActive': false,
      },
    ];

    // Check if there are residents
    final hasResidents = rumah.residents > 0;

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
          const Text(
            'Riwayat Penghuni',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (!hasResidents)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada riwayat penghuni.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...residents.map((resident) => _buildResidentItem(resident)),
        ],
      ),
    );
  }

  Widget _buildResidentItem(Map<String, dynamic> resident) {
    final isActive = resident['isActive'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keluarga',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resident['keluarga'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tanggal Masuk',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resident['tanggalMasuk'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kepala Keluarga',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resident['kepalaKeluarga'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tanggal Keluar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resident['tanggalKeluar'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF16A34A) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// More Menu Widget
class _MoreMenu extends StatelessWidget {
  final String rumahAddress;
  final Rumah rumah;
  final VoidCallback onEdit;
  final VoidCallback onDeleteConfirmed;

  const _MoreMenu({
    required this.rumahAddress,
    required this.rumah,
    required this.onEdit,
    required this.onDeleteConfirmed,
  });

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Opsi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                // Edit option
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4E46B4).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF4E46B4),
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Edit Data',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Ubah data rumah'),
                  onTap: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                ),
                const Divider(height: 1),
                // Delete option
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Hapus Data',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: const Text('Hapus data rumah secara permanen'),
                  onTap: () {
                    Navigator.pop(context);
                    onDeleteConfirmed();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Lainnya',
      icon: const Icon(Icons.more_vert, color: Colors.black),
      onPressed: () => _showOptionsBottomSheet(context),
    );
  }
}

// Delete Confirmation Dialog
Future<bool?> _showDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  bool? result;
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'DeleteConfirm',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, anim, secAnim) {
      final colors = ctx.moonColors ?? MoonTokens.light.colors;
      return Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.86,
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: MoonSquircleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ).squircleBorderRadius(ctx),
              ),
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                Text(title, style: MoonTokens.light.typography.heading.text18),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: MoonTokens.light.typography.body.text14.copyWith(
                    color: colors.trunks,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: MoonOutlinedButton(
                        onTap: () {
                          result = false;
                          Navigator.of(ctx).maybePop();
                        },
                        label: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MoonFilledButton(
                        backgroundColor: Colors.red,
                        onTap: () {
                          result = true;
                          Navigator.of(ctx).maybePop();
                        },
                        label: const Text('Hapus'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, anim, secAnim, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      );
    },
  );
  return result;
}
