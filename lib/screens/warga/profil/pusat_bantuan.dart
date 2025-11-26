import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moon_design/moon_design.dart';

class PusatBantuanScreen extends StatelessWidget {
  const PusatBantuanScreen({super.key});

  static const Color _primaryColor = Color(0xFF6A5AE0); 
  static const Color _textColor = Color(0xFF1F2937);
  static const Color _backgroundColor = Color(0xFFF7F7F7);

  final List<Map<String, String>> faqData = const [
    {
      'question': 'Bagaimana cara melihat iuran bulanan saya?',
      'answer': 'Anda dapat melihat semua riwayat dan tagihan iuran di menu "Keuangan". Pastikan Anda memilih tahun dan bulan yang benar.',
    },
    {
      'question': 'Apa yang harus dilakukan jika data diri saya salah?',
      'answer': 'Silakan masuk ke menu "Profil" > "Lihat Profil" > "Ubah Data Diri". Jika ada data yang tidak bisa diubah, hubungi administrator RW melalui kontak yang tersedia di aplikasi.',
    },
    {
      'question': 'Apakah saya bisa membayar tagihan dari luar aplikasi?',
      'answer': 'Ya, Anda dapat membayar melalui transfer bank ke rekening Bendahara yang tertera di detail tagihan. Jangan lupa upload bukti transfer di menu "Keuangan" > "Bayar".',
    },
    {
      'question': 'Bagaimana cara mengajukan aspirasi atau keluhan?',
      'answer': 'Aspirasi dapat diajukan melalui menu "Aspirasi". Tekan tombol "+" untuk membuat pesan baru, isi judul dan deskripsi keluhan atau saran Anda.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            MoonButton.icon(
              onTap: () => context.pop(), 
              icon: const Icon(MoonIcons.controls_chevron_left_32_regular),
            ),
            const SizedBox(width: 8),
            const Text(
              "Pusat Bantuan",
              style: TextStyle(
                color: _textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(context),
            const SizedBox(height: 24),

            Text(
              'FAQ (Pertanyaan Umum)',
              style: MoonTokens.light.typography.heading.text16.copyWith(
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),

            _buildFaqTiles(context), 
            const SizedBox(height: 30),
            
            _buildContactAdminButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: _primaryColor, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Temukan jawaban atas pertanyaan Anda dengan cepat di bawah ini.',
              style: TextStyle(fontSize: 14, color: _textColor.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTiles(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: faqData.asMap().entries.map((entry) {
            final index = entry.key;
            final faq = entry.value;

            return Column(
              children: [
                Theme(
                  // context sekarang dapat digunakan di sini
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    title: Text(
                      faq['question']!,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: _textColor, fontSize: 14),
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            faq['answer']!,
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tambahkan Divider antar item
                if (index < faqData.length - 1)
                  const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Tombol Hubungi Admin
  Widget _buildContactAdminButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Ganti ini dengan logika untuk membuka chat admin (misalnya WhatsApp atau chat in-app)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Membuka kontak admin...'),
              backgroundColor: const Color.fromARGB(255, 142, 142, 143), 
            ),
          );
        },
        icon: const Icon(Icons.support_agent, color: Colors.white),
        label: const Text(
          'Hubungi Admin',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}