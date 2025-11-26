import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawara_pintar_kel_5/models/anggota_keluarga_model.dart';

class DetailAnggotaKeluargaPage extends StatelessWidget {
  final Anggota anggota;

  const DetailAnggotaKeluargaPage({super.key, required this.anggota});

  void _showOptionsBottomSheet(BuildContext context, Anggota data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.withOpacity(0.2),
                child: const Icon(Icons.edit, color: Colors.deepPurple),
              ),
              title: const Text('Edit Data'),
              subtitle: const Text('Ubah informasi anggota keluarga'),
              onTap: () => context.pushNamed("EditAnggotaKeluarga", extra: data),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = anggota;

    final String formattedDate = data.tanggalLahir != null
        ? DateFormat('d MMMM yyyy').format(data.tanggalLahir!)
        : '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Anggota Keluarga"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsBottomSheet(context, data),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(data),
          const SizedBox(height: 20),
          _SectionCard(
            title: "Data Diri",
            children: [
              _IconRow(icon: Icons.person, label: "Nama", value: data.nama),
              _IconRow(
                icon: Icons.event,
                label: "Tempat, Tanggal Lahir",
                value: "${data.tempatLahir ?? '-'}, $formattedDate",
              ),
              _IconRow(icon: Icons.phone, label: "Telepon", value: data.telepon ?? "-"),
              _IconRow(icon: Icons.people, label: "Jenis Kelamin", value: data.jenisKelamin ?? "-"),
              _IconRow(icon: Icons.bloodtype, label: "Golongan Darah", value: data.golonganDarah ?? "-"),
              _IconRow(icon: Icons.self_improvement, label: "Agama", value: data.agama ?? "-"),
            ],
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: "Informasi Kependudukan",
            children: [
              _IconRow(icon: Icons.school, label: "Pendidikan", value: data.pendidikanTerakhir ?? "-"),
              _IconRow(icon: Icons.work, label: "Pekerjaan", value: data.pekerjaan ?? "-"),
              _IconRow(icon: Icons.family_restroom, label: "Peran Keluarga", value: data.peranKeluarga ?? "-"),
              _IconRow(icon: Icons.verified, label: "Status Penduduk", value: data.statusPenduduk ?? "-"),
              _IconRow(icon: Icons.groups, label: "Nama Keluarga", value: data.namaKeluarga ?? "-"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Anggota data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey.shade300,
            child: Icon(
              (data.jenisKelamin?.toLowerCase().contains("wanita") ?? false)
                  ? Icons.female
                  : Icons.male,
              size: 40,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Nama Lengkap", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(data.nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("NIK: ${data.nik}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          )
        ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 20),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value),
              ],
            ),
          )
        ],
      ),
    );
  }
}
