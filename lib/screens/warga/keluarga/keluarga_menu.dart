import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/keluarga_model.dart';

class Keluargamenuwarga extends StatelessWidget {
  const Keluargamenuwarga({super.key});

  static const Color profilColor = Color(0xFF6366F1); 
  static const Color keluargaColor = Color(0xFF4E46B4);
  static const Color _tagihanColor = Color(0xFF4E46B4);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text(
          'Menu Keluarga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: [
            _buildMenuItem(
              icon: Icons.family_restroom,
              label: 'Profil Keluarga',
              color: profilColor,
              onTap: () {
                final dummyKeluarga = Keluarga(
                  id: "1",
                  namaKeluarga: "Keluarga Susanto",
                  kepalaKeluargaId: "1001",
                  alamatRumah: "Jl. Mawar No. 12",
                  statusKepemilikan: "Milik Sendiri",
                  statusKeluarga: "Aktif",
                  kepalaKeluarga: null,
                  jenisMutasi: null,
                  alasanMutasi: null,
                  tanggalMutasi: null,
                );

                context.pushNamed(
                  'ProfilKeluarga',
                  extra: dummyKeluarga,
                );
              },
            ),

            _buildMenuItem(
              icon: Icons.groups,
              label: 'Daftar Keluarga',
              color: keluargaColor,
              onTap: () => context.push('/warga/keluarga/anggota'),
            ),
            _buildMenuItem(
               icon: Icons.receipt_long,
               label: 'Tagihan Saya',
               color: _tagihanColor,
               onTap: () => context.push('/warga/keluarga/tagihan'),
            ),

            
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E9F3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
