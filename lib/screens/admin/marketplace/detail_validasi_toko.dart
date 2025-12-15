import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:SapaWarga_kel_2/models/marketplace/store_model.dart';
import 'package:SapaWarga_kel_2/providers/marketplace/store_provider.dart';
import 'package:SapaWarga_kel_2/services/marketplace/store_service.dart';
import 'package:provider/provider.dart';

const Color _primaryColor = Color(0xFF4E46B4);
const Color _successColor = Color(0xFF6366F1);
const Color _dangerColor = Colors.red;
const Color _warningColor = Color.fromARGB(255, 203, 155, 12);
const Color _defaultColor = Colors.grey;

class DetailValidasiTokoScreen extends StatefulWidget {
  final StoreModel store;

  const DetailValidasiTokoScreen({super.key, required this.store});

  @override
  State<DetailValidasiTokoScreen> createState() =>
      _DetailValidasiTokoScreenState();
}

class _DetailValidasiTokoScreenState extends State<DetailValidasiTokoScreen> {
  StoreModel? _currentStore;
  String _ownerName = '-';
  String _ownerEmail = '-';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentStore = widget.store;
    _fetchWargaInfo();
  }

  String _getTimeAgo(DateTime? createdAt) {
    if (createdAt == null) return 'Tidak diketahui';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(createdAt);
    }
  }

  Future<void> _fetchWargaInfo() async {
    if (_currentStore?.userId == null) return;

    setState(() => _isLoading = true);

    try {
      final storeService = StoreService();
      final wargaInfo = await storeService.getWargaByUserId(
        _currentStore!.userId!,
      );
      if (wargaInfo != null) {
        setState(() {
          _ownerName = wargaInfo['nama'] ?? '-';
          _ownerEmail = wargaInfo['email'] ?? '-';
        });
      }
    } catch (e) {
      print('Error fetching warga info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat info pemilik: $e'),
            backgroundColor: Colors.grey.shade800,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleApprove() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Setujui Toko',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Apakah Anda yakin ingin menyetujui pendaftaran toko "${_currentStore?.nama}"?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _updateStoreStatus('Diterima', null);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Setujui',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  void _handleReject() {
    final TextEditingController alasanController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Padding(
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
                      controller: alasanController,
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
                          if (alasanController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Alasan penolakan harus diisi',
                                ),
                                backgroundColor: Colors.grey.shade800,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context);
                          await _updateStoreStatus(
                            'Ditolak',
                            alasanController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _dangerColor,
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
          ),
        );
      },
    );
  }

  Future<void> _showSuccessDialog(String status) async {
    String title;
    String message;
    Color iconColor;
    IconData icon;
    Color primaryActionColor;

    if (status == 'Ditolak') {
      title = 'Penolakan Berhasil';
      message = 'Permintaan toko "${_currentStore?.nama}" berhasil ditolak.';
      iconColor =
          _dangerColor; // Menggunakan warna merah/danger untuk penolakan
      icon = Icons.cancel;
      primaryActionColor = _dangerColor;
    } else if (status == 'Diterima') {
      title = 'Persetujuan Berhasil';
      message = 'Permintaan toko "${_currentStore?.nama}" berhasil disetujui.';
      iconColor = _successColor;
      icon = Icons.check_circle_outline;
      primaryActionColor = _successColor;
    } else {
      // Default fallback
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Icon(icon, color: iconColor, size: 40)),
                ),
                const SizedBox(height: 24),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Tutup Dialog
                      Navigator.of(context).pop();
                      // Tutup DetailValidasiTokoScreen, kembali ke halaman sebelumnya
                      context.pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryActionColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateStoreStatus(String status, String? alasan) async {
    if (_currentStore?.storeId == null) return;

    setState(() => _isLoading = true);
    if (!mounted) return;

    final storeProvider = Provider.of<StoreProvider>(context, listen: false);

    // Check if this is a reactivation request (was deactivated by admin)
    final isReactivationRequest = _currentStore?.deactivatedBy == 'admin';

    // If approving a reactivation request, clear deactivated_by
    if (status == 'Diterima' && isReactivationRequest) {
      final storeService = StoreService();
      await storeService.reactivateStore(_currentStore!.storeId!);

      // Refresh store data
      await storeProvider.fetchStoreById(_currentStore!.storeId!);

      if (mounted) {
        setState(() {
          _currentStore = storeProvider.stores.firstWhere(
            (s) => s.storeId == _currentStore!.storeId,
            orElse: () => _currentStore!,
          );
          _isLoading = false;
        });
        await _showSuccessDialog(status);
      }
    } else {
      // Regular approval/rejection
      final success = await storeProvider.updateVerificationStatus(
        _currentStore!.storeId!,
        status,
        alasan: alasan,
      );

      if (success) {
        final updatedStore = _currentStore!.copyWith(
          verifikasi: status,
          alasan: alasan,
        );
        setState(() {
          _currentStore = updatedStore;
          _isLoading = false;
        });
        if (mounted) {
          await _showSuccessDialog(status);
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                storeProvider.errorMessage ?? 'Gagal memperbarui status toko',
              ),
              backgroundColor: Colors.grey.shade800,
            ),
          );
        }
      }
    }
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

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront, color: _primaryColor, size: 35),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nama Toko',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _currentStore?.nama ?? 'Nama Toko',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID: ${_currentStore?.storeId ?? '-'}',
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
      title: 'Informasi Toko',
      children: [
        _IconTextRow(
          icon: Icons.person,
          title: 'Pemilik Toko',
          value: _ownerName,
        ),
        _IconTextRow(
          icon: Icons.badge,
          title: 'NIK Pemilik',
          value: _currentStore?.userId ?? '-',
        ),
        _IconTextRow(
          icon: Icons.phone,
          title: 'Nomor Kontak Toko',
          value: _currentStore?.kontak ?? '-',
        ),
        _IconTextRow(
          icon: Icons.email,
          title: 'Email Pemilik',
          value: _ownerEmail,
        ),
        _IconTextRow(
          icon: Icons.location_on,
          title: 'Alamat Toko',
          value: _currentStore?.alamat ?? '-',
        ),
        _IconTextRow(
          icon: Icons.access_time,
          title: 'Waktu Pendaftaran',
          value: _getTimeAgo(_currentStore?.createdAt),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return _SectionCard(
      title: 'Deskripsi Toko',
      children: [
        Text(
          _currentStore?.deskripsi ?? '-',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final String status = _currentStore?.verifikasi ?? 'Pending';
    Color statusColor;
    Color statusBgColor;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = _warningColor;
        statusBgColor = _warningColor.withOpacity(0.1);
        break;
      case 'ditolak':
        statusColor = _dangerColor;
        statusBgColor = _dangerColor.withOpacity(0.1);
        break;
      case 'diterima':
        statusColor = _successColor;
        statusBgColor = _successColor.withOpacity(0.1);
        break;
      default:
        statusColor = _defaultColor;
        statusBgColor = _defaultColor.withOpacity(0.1);
        break;
    }

    return _SectionCard(
      title: 'Status Verifikasi',
      children: [
        _IconTextRowWithBadge(
          icon: Icons.verified,
          title: 'Status Saat Ini',
          status: status,
          statusColor: statusColor,
          statusBackgroundColor: statusBgColor,
        ),
        if (status.toLowerCase() == 'ditolak' &&
            _currentStore!.alasan != null &&
            _currentStore!.alasan!.isNotEmpty)
          _IconTextRow(
            icon: Icons.info_outline,
            title: 'Alasan Penolakan',
            value: _currentStore!.alasan!,
            isMultiline: true,
          ),
      ],
    );
  }

  void _showOptionsBottomSheet() {
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
                      color: const Color(0xFF6A5AE0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF6A5AE0),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Setujui Toko',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6A5AE0),
                    ),
                  ),
                  subtitle: Text(
                    'Setujui pendaftaran toko',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleApprove();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _dangerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: _dangerColor,
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Tolak Toko',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _dangerColor,
                    ),
                  ),
                  subtitle: Text(
                    'Tolak pendaftaran toko',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleReject();
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
    final bool showActionButtons =
        _currentStore?.verifikasi?.toLowerCase() == 'pending';

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
          'Detail Validasi Toko',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (showActionButtons)
            IconButton(
              onPressed: _showOptionsBottomSheet,
              icon: const Icon(Icons.more_vert, color: Colors.black),
            ),
        ],
      ),
      body: _isLoading && _ownerName == '-'
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner untuk permohonan aktivasi ulang
                  if (_currentStore?.deactivatedBy == 'admin' &&
                      _currentStore?.verifikasi == 'Pending') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.refresh_rounded,
                              color: Colors.orange.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Permohonan Aktivasi Ulang',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Toko ini sebelumnya dinonaktifkan oleh admin dan kini mengajukan untuk diaktifkan kembali.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade800,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildProfileSection(),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(),
                  const SizedBox(height: 16),
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
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
  final bool isMultiline;
  const _IconTextRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isMultiline = false,
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
            color: _primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: isMultiline ? 5 : 2,
                overflow: isMultiline
                    ? TextOverflow.clip
                    : TextOverflow.ellipsis,
              ),
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
            color: _primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _primaryColor),
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
