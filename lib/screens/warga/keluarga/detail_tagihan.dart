import 'package:flutter/material.dart';
import 'package:jawara_pintar_kel_5/models/warga_tagihan_model.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/warga/keluarga/form_pembayaran.dart';

class DetailTagihanWargaScreen extends StatefulWidget {
  final WargaTagihanModel tagihan;

  const DetailTagihanWargaScreen({super.key, required this.tagihan});

  @override
  State<DetailTagihanWargaScreen> createState() => _DetailTagihanWargaScreenState();
}

class _DetailTagihanWargaScreenState extends State<DetailTagihanWargaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _currentStatus = widget.tagihan.status;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Helper Format Currency ---
  String _formatCurrency(double amount) {
    final realAmount = amount * 1000;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(realAmount);
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
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
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
              children: [
                _buildDetailTab(),
                _buildStatusBuktiTab(),
              ],
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
                        offset: const Offset(0, 4))
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
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.tagihan.kodeTagihan,
                            style:
                                TextStyle(color: Colors.grey[500], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    _buildDetailRow(Icons.calendar_today_outlined, 'Periode',
                        _formatDate(widget.tagihan.periode), Colors.orange),
                    _buildDivider(),
                    _buildDetailRow(Icons.family_restroom, 'Keluarga',
                        widget.tagihan.namaKeluarga, Colors.blue),
                    _buildDivider(),
                    _buildDetailRow(Icons.location_on_outlined, 'Alamat',
                        'Blok A49 (Simulasi)', Colors.red),
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
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    _buildBiayaRow(
                        "Nominal Iuran", _formatCurrency(widget.tagihan.nominal)),
                    const SizedBox(height: 12),
                    _buildBiayaRow("Biaya Admin", "Rp 0"),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Pembayaran",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          _formatCurrency(widget.tagihan.nominal),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF6366F1)),
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
  } else if (widget.tagihan.status == 'Ditolak' || widget.tagihan.status == 'Belum Dibayar') {
    statusColor = Colors.red;
    statusBg = Colors.red.shade50;
  } else {
    statusColor = Colors.orange;
    statusBg = Colors.orange.shade50;
  }

  return Container(
    color: const Color(0xFFF8F9FA),
    child: SingleChildScrollView( // ← FIX di sini
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
                      color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  const Text("Status Saat Ini",
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
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
                                Text("Alasan Penolakan:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red)),
                                Text("Bukti transfer buram/tidak terbaca.",
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 16),

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
                        blurRadius: 10)
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
                    Container(
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
                            const Icon(Icons.image,
                                size: 50, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              "Gambar Bukti Transfer",
                              style:
                                  TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    ),
  );
}


  Widget _buildBottomAction() {
    bool canPay = widget.tagihan.status == 'Belum Dibayar' ||
        widget.tagihan.status == 'Ditolak';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: canPay
            ? ElevatedButton(
                onPressed: () async {
                  final result = await context.pushNamed(
                    'FormPembayaranWarga',
                    extra: widget.tagihan,
                  );
                  if (result == true) {
                    setState(() {
                      _currentStatus = 'Menunggu Verifikasi';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Status tagihan diperbarui")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Bayar Sekarang',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              )
            : OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                            : Colors.orange),
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
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
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
        Text(label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
