import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/tagihan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailTagihanScreen extends StatefulWidget {
  final TagihanModel tagihan;

  const DetailTagihanScreen({super.key, required this.tagihan});

  @override
  State<DetailTagihanScreen> createState() => _DetailTagihanScreenState();
}

class _DetailTagihanScreenState extends State<DetailTagihanScreen> {
  final TextEditingController _alasanController = TextEditingController();

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  // Method to approve payment
  Future<void> _approvePayment() async {
    try {
      // Make the request to approve the payment
      await Supabase.instance.client
          .from('tagihan_iuran')
          .update({'status_pembayaran': 'Terverifikasi'})
          .eq('id', widget.tagihan.kodeTagihan);
    } catch (e) {
      // Handle any exceptions or errors
      debugPrint('Error approving payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat menyetujui pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to reject payment
  Future<void> _rejectPayment() async {
    try {
      await Supabase.instance.client
          .from('tagihan_iuran')
          .update({
            'status_pembayaran': 'Ditolak',
            'alasan_penolakan':
                _alasanController.text, // Store rejection reason
          })
          .eq('id', widget.tagihan.kodeTagihan);
    } catch (e) {
      debugPrint('Error rejecting payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat menolak pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verifikasi Pembayaran Iuran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _buildDetailTab(),
    );
  }

  Widget _buildDetailTab() {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kode Iuran
                    _buildDetailRow(
                      Icons.qr_code,
                      'Kode Iuran',
                      widget.tagihan.kodeTagihan,
                      const Color(0xFF6366F1),
                    ),
                    _buildDivider(),

                    // Nama Iuran
                    _buildDetailRow(
                      Icons.payment,
                      'Nama Iuran',
                      widget.tagihan.iuran,
                      const Color(0xFF3B82F6),
                    ),
                    _buildDivider(),

                    // Kategori
                    _buildDetailRow(
                      Icons.category_outlined,
                      'Kategori',
                      'Iuran Khusus',
                      const Color(0xFF8B5CF6),
                    ),
                    _buildDivider(),

                    // Periode
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'Periode',
                      _formatDate(widget.tagihan.periode),
                      const Color(0xFFEF4444),
                    ),
                    _buildDivider(),

                    // Nominal
                    _buildDetailRow(
                      Icons.attach_money,
                      'Nominal',
                      'Rp ${_formatCurrency(widget.tagihan.nominal)}',
                      const Color(0xFF10B981),
                    ),
                    _buildDivider(),

                    // Status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status',
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
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.tagihan.status,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Keluarga Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama KK
                    _buildDetailRow(
                      Icons.family_restroom,
                      'Nama KK',
                      widget.tagihan.namaKeluarga,
                      const Color(0xFF6366F1),
                    ),
                    _buildDivider(),

                    // Alamat
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      'Alamat',
                      widget.tagihan.alamat ?? 'Alamat tidak tersedia',
                      const Color(0xFFEF4444),
                    ),
                    _buildDivider(),

                    // Metode Pembayaran
                    _buildDetailRow(
                      Icons.account_balance_wallet_outlined,
                      'Metode Pembayaran',
                      'Belum tersedia',
                      Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bukti Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            size: 20,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Bukti',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _alasanController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tulis alasan penolakan...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showRejectConfirmation();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Tolak',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showApproveConfirmation();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Setujui',
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
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
                  fontSize: 14,
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  void _showApproveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Setujui Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menyetujui pembayaran ini?',
        ),
        actions: [
          // Cancel button - Just close the dialog
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          // Approve button - Call _approvePayment and close the dialog
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _approvePayment(); // Call the approve payment method
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmation() {
    if (_alasanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi alasan penolakan terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Tolak Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin menolak pembayaran ini?'),
        actions: [
          TextButton(
            onPressed: () {
              _rejectPayment();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectPayment();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }
}
