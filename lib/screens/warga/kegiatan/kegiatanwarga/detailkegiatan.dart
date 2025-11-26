import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class DetailKegiatanWargaScreen extends StatelessWidget {
    final Map<String, String> kegiatan;
    const DetailKegiatanWargaScreen({super.key, required this.kegiatan});

    static const Color primaryColor = Color(0xFF6366F1);

    Widget _buildDetailField(String label, String value, {int? maxLines = 1}) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87), 
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Colors.grey.shade300, width: 1), 
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 1.5), 
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
        final String namaKegiatan = kegiatan['judul'] ?? 'Nama Kegiatan Tidak Ada';
        final String kategori = kegiatan['kategori'] ?? 'Lainnya';
        final String deskripsi =
            kegiatan['deskripsi'] ?? 'Deskripsi Belum Tersedia';
        final String tanggal = kegiatan['tanggal'] ?? '-';
        final String lokasi = kegiatan['lokasi'] ?? 'Belum Ditentukan';
        final String pj = kegiatan['pj'] ?? '-';
        final String dibuatOleh = kegiatan['dibuat_oleh'] ?? 'Admin Jawara';

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
            
            body: SingleChildScrollView(
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
                                Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.0),
                                        
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.network(
                                            'https://plus.unsplash.com/premium_photo-1663061406443-48423f04e73d?w=1000&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8a2VyamElMjBiYWt0aXxlbnwwfHwwfHx8MA%3D%3D',
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
              color: Colors.black87
            )
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

