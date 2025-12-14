import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_validation_model.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/product_service.dart';

const Color _primaryColor = Color(0xFF6366F1);
const Color _successColor = Color(0xFF6366F1);
const Color _dangerColor = Colors.red;
const Color _warningColor = Color(0xFFFBBF24);
const Color _defaultColor = Colors.grey;

class DetailValidasiProdukScreen extends StatefulWidget {
  final ProductValidation product;
  final Function(String productId, String newStatus) onStatusUpdated;

  const DetailValidasiProdukScreen({
    super.key,
    required this.product,
    required this.onStatusUpdated,
  });

  @override
  State<DetailValidasiProdukScreen> createState() =>
      _DetailValidasiProdukScreenState();
}

class _DetailValidasiProdukScreenState
    extends State<DetailValidasiProdukScreen> {
  ProductValidation? _currentProduct;
  final ProductService _productService = ProductService();
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  // --- Fungsi Utilitas ---

  // Konversi confidence double (0.0 - 1.0) ke String persentase
  String _formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(0)}%';
  }

  // Mendapatkan warna untuk badge status
  Color _getStatusColor(String status, {bool isBackground = false}) {
    switch (status.toLowerCase()) {
      case 'pending':
        return isBackground ? _warningColor.withOpacity(0.1) : _warningColor;
      case 'ditolak':
        return isBackground ? _dangerColor.withOpacity(0.1) : _dangerColor;
      case 'disetujui':
        return isBackground ? _successColor.withOpacity(0.1) : _successColor;
      default:
        return isBackground ? _defaultColor.withOpacity(0.1) : _defaultColor;
    }
  }

  // Mendapatkan warna untuk badge confidence CV
  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.90) return Colors.green.shade700;
    if (confidence > 0.70) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  // --- Bottom Sheet Menu ---
  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
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
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Hapus Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    'Hapus produk dari sistem',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _handleDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Aksi Hapus ---
  void _handleDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hapus Produk',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Apakah Anda yakin ingin menghapus produk "${_currentProduct?.productName}"? Tindakan ini tidak dapat dibatalkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isDeleting
                            ? null
                            : () async {
                                Navigator.pop(context);
                                await _deleteProduct();
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Hapus',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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

  Future<void> _deleteProduct() async {
    setState(() => _isDeleting = true);

    try {
      // Convert id from String to int
      final productId = int.parse(_currentProduct!.id);

      // Call ProductService to delete the product
      await _productService.deleteProductByAdmin(productId);

      if (!mounted) return;

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
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
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: _primaryColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Berhasil Dihapus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Produk "${_currentProduct?.productName}" berhasil dihapus dari sistem',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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

      // Return to previous screen and notify that product was deleted
      context.pop(true); // Pass true to indicate deletion success
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus produk: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  // --- Widget Pembantu UI ---

  Widget _buildProductHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              _currentProduct!.imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 180,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentProduct?.productName ?? 'Nama Produk',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${_currentProduct?.id ?? '-'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _SectionCard(
      title: 'Informasi Produk & Penjual',
      children: [
        _IconTextRow(
          icon: Icons.category,
          title: 'Kategori',
          value: _currentProduct?.category ?? '-',
        ),
        _IconTextRow(
          icon: Icons.person,
          title: 'Penjual',
          value: _currentProduct?.sellerName ?? '-',
        ),
        _IconTextRow(
          icon: Icons.access_time,
          title: 'Waktu Upload',
          value: _currentProduct?.timeUploaded ?? '-',
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return _SectionCard(
      title: 'Deskripsi Produk',
      children: [
        Text(
          _currentProduct?.description.isNotEmpty == true
              ? _currentProduct!.description
              : 'Tidak ada deskripsi tambahan.',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCVCard() {
    final double confidence = _currentProduct?.cvConfidence ?? 0.0;
    final Color confidenceColor = _getConfidenceColor(confidence);
    final String confidenceString = _formatConfidence(confidence);

    return _SectionCard(
      title: 'Hasil Computer Vision',
      children: [
        _IconTextRow(
          icon: Icons.analytics,
          title: 'Klasifikasi CV',
          value: _currentProduct?.cvResult ?? 'Tidak diketahui',
          iconColor: Colors.blueAccent,
        ),
        _IconTextRowWithBadge(
          icon: Icons.verified,
          title: 'Tingkat Keyakinan (Confidence)',
          status: confidenceString,
          statusColor: confidenceColor,
          statusBackgroundColor: confidenceColor.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final String status = _currentProduct?.status ?? 'Pending';
    Color statusColor = _getStatusColor(status);
    Color statusBgColor = _getStatusColor(status, isBackground: true);

    return _SectionCard(
      title: 'Status Validasi',
      children: [
        _IconTextRowWithBadge(
          icon: Icons.verified_user,
          title: 'Status Saat Ini',
          status: status,
          statusColor: statusColor,
          statusBackgroundColor: statusBgColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: IconButton(
          // Gunakan pop untuk kembali ke halaman list
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Detail Validasi Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _showOptionsBottomSheet,
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildDescriptionCard(),
            const SizedBox(height: 16),
            _buildCVCard(),
            const SizedBox(height: 16),
            _buildStatusCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// --- Widget Pembantu (Dipindahkan dan diadaptasi agar dapat digunakan) ---

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
  final Color? iconColor;

  const _IconTextRow({
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
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
            color: (iconColor ?? _primaryColor).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? _primaryColor),
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
                style: const TextStyle(color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
          child: const Icon(Icons.verified_user, color: _primaryColor),
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
