import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/broadcast_model.dart';
import 'package:SapaWarga_kel_2/services/broadcast_service.dart';

class DetailBroadcastWargaScreen extends StatefulWidget {
  final int broadcastId;
  const DetailBroadcastWargaScreen({super.key, required this.broadcastId});
  static const Color primaryColor = Color(0xFF6366F1);

  @override
  State<DetailBroadcastWargaScreen> createState() =>
      _DetailBroadcastWargaScreenState();
}

class _DetailBroadcastWargaScreenState
    extends State<DetailBroadcastWargaScreen> {
  late Future<BroadcastModel> _futureBroadcast;
  final BroadcastService _broadcastService = BroadcastService();

  @override
  void initState() {
    super.initState();
    // Saat layar dibuka, langsung panggil service
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _futureBroadcast = _broadcastService.getBroadcastById(widget.broadcastId);
    });
  }

  // Helper Buka URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tidak dapat membuka file'),
            backgroundColor: Colors.grey.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detail Broadcast',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: Divider(height: 1, color: Colors.grey),
        ),
      ),
      // FutureBuilder adalah kunci untuk fetch data
      body: FutureBuilder<BroadcastModel>(
        future: _futureBroadcast,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchData,
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData)
            return const Center(child: Text("Data kosong"));
          final broadcastData = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _fetchData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    title: "Informasi Broadcast",
                    children: [
                      _IconRow(
                        icon: Icons.title,
                        label: "Judul Broadcast",
                        value: broadcastData.judul,
                      ),
                      _IconRow(
                        icon: Icons.calendar_today,
                        label: "Tanggal Publikasi",
                        value: dateFormat.format(broadcastData.tanggal),
                      ),
                      _IconRow(
                        icon: Icons.category,
                        label: "Kategori",
                        value: broadcastData.kategori,
                      ),
                      _IconRow(
                        icon: Icons.person,
                        label: "Dibuat oleh",
                        value: broadcastData.pengirim,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _SectionCard(
                    title: "Isi Broadcast",
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        broadcastData.konten,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (broadcastData.lampiranGambarUrl != null)
                    _SectionCard(
                      title: 'Lampiran Gambar',
                      children: [
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            broadcastData.lampiranGambarUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Text("Gagal memuat gambar"),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),

                  if (broadcastData.lampiranGambarUrl != null)
                    const SizedBox(height: 20),

                  // 4. LAMPIRAN DOKUMEN (UPDATE - Single URL)
                  if (broadcastData.lampiranDokumenUrl != null)
                    _SectionCard(
                      title: 'Lampiran Dokumen',
                      children: [
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () =>
                              _launchUrl(broadcastData.lampiranDokumenUrl!),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: DetailBroadcastWargaScreen.primaryColor
                                  .withOpacity(0.05),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    "Download / Lihat Dokumen",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.download,
                                  color:
                                      DetailBroadcastWargaScreen.primaryColor,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
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
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _IconRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // Mengakses variabel static dari class utama
              color: DetailBroadcastWargaScreen.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: DetailBroadcastWargaScreen.primaryColor,
              size: 20,
            ),
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
                  key: label == 'Judul Broadcast' ? const Key('warga_broadcast_detail_title') : null,
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
}
