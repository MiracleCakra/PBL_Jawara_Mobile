import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:SapaWarga_kel_2/models/kegiatan/kegiatan_model.dart';
import 'package:SapaWarga_kel_2/services/kegiatan_service.dart';

class DetailKegiatanWargaScreen extends StatefulWidget {
  final int kegiatanId;
  const DetailKegiatanWargaScreen({super.key, required this.kegiatanId});

  static const Color primaryColor = Color(0xFF6366F1);

  @override
  State<DetailKegiatanWargaScreen> createState() =>
      _DetailKegiatanWargaScreenState();
}

class _DetailKegiatanWargaScreenState extends State<DetailKegiatanWargaScreen> {
  late Future<KegiatanModel> _kegiatanFuture;
  final KegiatanService _kegiatanService = KegiatanService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _kegiatanFuture = _kegiatanService.getKegiatanById(widget.kegiatanId);
    });
  }

  Widget _buildDetailField(String label, String value, {int? maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value.isEmpty ? '-' : value,
          readOnly: true,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(
                  color: DetailKegiatanWargaScreen.primaryColor.withOpacity(0.5),
                  width: 1.5),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

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
          'Detail Kegiatan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: FutureBuilder<KegiatanModel>(
        future: _kegiatanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final kegiatan = snapshot.data!;
            final String namaKegiatan = kegiatan.judul;
            final String kategori = kegiatan.kategori;
            final String deskripsi = kegiatan.deskripsi;
            final String tanggal = dateFormat.format(kegiatan.tanggal);
            final String lokasi = kegiatan.lokasi;
            final String pj = kegiatan.pj;
            final String dibuatOleh = kegiatan.dibuatOleh ?? 'Admin Jawara';
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    title: "Informasi Kegiatan",
                    children: [
                      _buildDetailField('Nama Kegiatan', namaKegiatan),
                      _buildDetailField('Kategori', kategori),
                      _buildDetailField('Tanggal', tanggal),
                      _buildDetailField('Lokasi', lokasi),
                      _buildDetailField('Penanggung Jawab', pj),
                      _buildDetailField('Dibuat Oleh', dibuatOleh),
                      const SizedBox(height: 0),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: "Deskripsi Kegiatan",
                    children: [
                      _buildDetailField('Deskripsi', deskripsi, maxLines: null),
                      const SizedBox(height: 0),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: 'Dokumentasi Event',
                    children: [
                      const SizedBox(height: 8),
                      if (kegiatan.images != null && kegiatan.images!.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: kegiatan.images!.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final imgUrl = kegiatan.images![index].img;
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imgUrl,
                                  width: 300,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 300,
                                      height: 200,
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.grey.shade400),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              kegiatan.gambarDokumentasi ??
                                  'https://placehold.co/600x400/CCCCCC/333333?text=Tidak+Ada+Dokumentasi',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    'Gagal memuat gambar',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text("Tidak ada data kegiatan."),
            );
          }
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
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

