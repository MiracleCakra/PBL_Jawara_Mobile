import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/screens/warga/kegiatan/broadcashwarga/broadcash_warga.dart';
import 'package:jawara_pintar_kel_5/models/broadcah_model.dart';


class DetailBroadcastWargaScreen extends StatelessWidget {
  final KegiatanBroadcastWarga broadcastData;
  const DetailBroadcastWargaScreen({super.key, required this.broadcastData});
  static const Color primaryColor = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) => Scaffold(
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. DETAIL UTAMA (Judul, Konten, Tanggal)
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
                    value: broadcastData.tanggal, 
                  ),
                  _IconRow(
                    icon: Icons.person,
                    label: "Dibuat oleh",
                    value: broadcastData.pengirim,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. ISI BROADCAST
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

              // 3. LAMPIRAN GAMBAR
              if (broadcastData.lampiranGambarUrl != null)
                _SectionCard(
                  title: 'Lampiran Gambar',
                  children: [
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        broadcastData.lampiranGambarUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              const SizedBox(height: 20),

              // 4. LAMPIRAN DOKUMEN
              if (broadcastData.lampiranDokumen.isNotEmpty)
                _SectionCard(
                  title: 'Lampiran Dokumen',
                  children: [
                    const SizedBox(height: 8),
                    ...broadcastData.lampiranDokumen.map(
                      (dokumen) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: primaryColor.withOpacity(0.05), // Menggunakan warna tema
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  dokumen,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.download, color: primaryColor, size: 20),
                            ],
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

  const _IconRow({required this.icon, required this.label, required this.value});

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
              color: DetailBroadcastWargaScreen.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: DetailBroadcastWargaScreen.primaryColor, size: 20),
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
          )
        ],
      ),
    );
  }
}