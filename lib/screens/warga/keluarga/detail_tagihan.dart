import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/channel_transfer_model.dart';
import 'package:jawara_pintar_kel_5/models/keuangan/warga_tagihan_model.dart';

class DetailTagihanWargaScreen extends StatefulWidget {
  final WargaTagihanModel tagihan;

  const DetailTagihanWargaScreen({super.key, required this.tagihan});

  @override
  State<DetailTagihanWargaScreen> createState() =>
      _DetailTagihanWargaScreenState();
}

class _DetailTagihanWargaScreenState extends State<DetailTagihanWargaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _currentStatus;
  List<ChannelTransferModel> channels = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadChannels();
    _currentStatus = widget.tagihan.status;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _loadChannels() async {
    try {
      final fetchedChannels = await ChannelTransferModel.fetchChannels();
      setState(() {
        channels = fetchedChannels; // List<ChannelTransferModel>
      });
    } catch (e) {
      debugPrint("Error fetching channels: $e");
    }
  }

  // --- Helper Format Currency ---
  String _formatCurrency(double amount) {
    final realAmount = amount * 1000;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(realAmount);
  }

  // --- Helper Format Date ---
  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Tagihan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ---------- TABBAR BARU (clean seperti laporan) ----------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: Colors.blue.shade700,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue.shade700,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: "Rincian"),
                Tab(text: "Status & Bukti"),
              ],
            ),
          ),

          // --- TAB CONTENT ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildDetailTab(), _buildStatusBuktiTab()],
            ),
          ),
        ],
      ),

      // --- BOTTOM ACTION ---
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildDetailTab() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD 1: INFORMASI UTAMA
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.tagihan.iuran == 'Agustusan'
                                  ? Icons.flag
                                  : Icons.receipt_long,
                              size: 40,
                              color: const Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Iuran ${widget.tagihan.iuran}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.tagihan.kodeTagihan,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'Periode',
                      _formatDate(widget.tagihan.periode),
                      Colors.orange,
                    ),
                    _buildDivider(),
                    _buildDetailRow(
                      Icons.family_restroom,
                      'Keluarga',
                      widget.tagihan.namaKeluarga,
                      Colors.blue,
                    ),
                    _buildDivider(),
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      'Alamat',
                      widget.tagihan.alamat,
                      Colors.red,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // CARD 2: RINGKASAN BIAYA
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildBiayaRow(
                      "Nominal Iuran",
                      _formatCurrency(widget.tagihan.nominal),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Pembayaran",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatCurrency(widget.tagihan.nominal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBuktiTab() {
    Color statusColor;
    Color statusBg;
    if (widget.tagihan.status == 'Diterima') {
      statusColor = Colors.green;
      statusBg = Colors.green.shade50;
    } else if (widget.tagihan.status == 'Ditolak' ||
        widget.tagihan.status == 'Belum Dibayar') {
      statusColor = Colors.red;
      statusBg = Colors.red.shade50;
    } else {
      statusColor = Colors.orange;
      statusBg = Colors.orange.shade50;
    }

    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        // ← FIX di sini
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- STATUS CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Status Saat Ini",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.tagihan.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    if (widget.tagihan.status == 'Ditolak') ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Alasan Penolakan:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  Text(
                                    "Bukti transfer buram/tidak terbaca.",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- BUKTI TRANSFER CARD ---
              // --- BUKTI TRANSFER CARD ---
              if (widget.tagihan.status != 'Belum Dibayar')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bukti Transfer Terkirim",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      // Checking if the 'bukti' value is not null or empty
                      widget.tagihan.bukti != null &&
                              widget.tagihan.bukti!.isNotEmpty
                          ? Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget
                                      .tagihan
                                      .bukti!, // Use the bukti URL to load the image
                                  fit: BoxFit
                                      .cover, // Make the image cover the container
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 50,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Gambar Bukti Transfer Tidak Tersedia",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChannelTransferBottomSheet() async {
    debugPrint('=== Bottom sheet method called ===');

    debugPrint('Total channels: ${channels.length}');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 16),
                const Text(
                  'Pilih Channel Transfer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: channels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final channel =
                        channels[index]; // ChannelTransferModel instance
                    final Map<String, String> channelMap = {
                      'name': channel
                          .nama, // Sesuaikan dengan properti yang ada pada ChannelTransferModel
                      'type': channel.tipe,
                      'account': channel.norek,
                      'owner': channel.pemilik,
                    };
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          // 1. Tutup Bottom Sheet
                          Navigator.pop(context);

                          // 2. Navigasi menggunakan GoRouter dan tunggu hasilnya
                          final result = await context.pushNamed(
                            'FormPembayaranWarga',
                            extra: {
                              'tagihan': widget.tagihan,
                              'channel': channelMap,
                            },
                          );

                          if (result == true && mounted) {
                            setState(() {
                              _currentStatus = 'Menunggu Verifikasi';
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Status tagihan diperbarui"),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  channel.tipe == 'Bank'
                                      ? Icons.account_balance
                                      : channel.tipe == 'QRIS'
                                      ? Icons.qr_code
                                      : Icons.account_balance_wallet,
                                  color: const Color(0xFF6366F1),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      channel.nama,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      channel.pemilik,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomAction() {
    bool canPay =
        widget.tagihan.status == 'Belum Dibayar' ||
        widget.tagihan.status == 'Ditolak';

    // Debug: Print status
    debugPrint('Current status: "${widget.tagihan.status}"');
    debugPrint('Can pay: $canPay');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: canPay
            ? ElevatedButton(
                onPressed: () {
                  debugPrint('=== Bayar Sekarang button pressed ===');
                  _showChannelTransferBottomSheet();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentStatus == 'Diterima'
                          ? Icons.check_circle
                          : Icons.access_time,
                      color: _currentStatus == 'Diterima'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentStatus == 'Diterima'
                          ? 'Lunas / Diterima'
                          : 'Sedang Diproses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _currentStatus == 'Diterima'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // --- Widget Helpers ---
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
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
              const SizedBox(height: 2),
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

  Widget _buildBiayaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
