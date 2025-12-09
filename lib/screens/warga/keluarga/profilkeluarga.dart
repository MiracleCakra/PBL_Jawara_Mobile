import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/keluarga/keluarga_model.dart';
import 'package:jawara_pintar_kel_5/services/keluarga_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilKeluargaPage extends StatefulWidget {
  final Keluarga? keluarga;

  const ProfilKeluargaPage({super.key, this.keluarga});

  @override
  State<ProfilKeluargaPage> createState() => _ProfilKeluargaPageState();
}

class _ProfilKeluargaPageState extends State<ProfilKeluargaPage> {
  final KeluargaService _keluargaService = KeluargaService();
  Keluarga? _keluargaData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.keluarga != null) {
      _keluargaData = widget.keluarga;
      _isLoading = false;
    } else {
      _fetchKeluargaSaya();
    }
  }

  Future<void> _fetchKeluargaSaya() async {
    try {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null) {
        setState(() {
          _errorMessage = 'Tidak ada pengguna yang login.';
          _isLoading = false;
        });
        return;
      }

      final keluarga = await _keluargaService.getKeluargaByEmail(email);
      
      if (mounted) {
        setState(() {
          _keluargaData = keluarga;
          _isLoading = false;
          if (keluarga == null) {
            _errorMessage = 'Anda belum tergabung dalam keluarga manapun.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data keluarga: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detail Keluarga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.family_restroom_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_keluargaData == null) {
      return const Center(child: Text("Data tidak ditemukan"));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(context, _keluargaData!),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, Keluarga data) {
    final String kepalaKeluargaName = data.kepalaKeluarga?.nama ?? 'N/A';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          // 1. Nama Keluarga
          _buildInfoRow(
            icon: Icons.family_restroom,
            label: 'Nama Keluarga',
            value: 'Keluarga ${data.namaKeluarga}',
            isHeader: true,
          ),
          const Divider(height: 1),
          
          // 2. Kepala Keluarga
          _buildInfoRow(
            icon: Icons.person,
            label: 'Kepala Keluarga',
            value: kepalaKeluargaName,
          ),
          const Divider(height: 1),
          
          // 3. Rumah Saat Ini
          _buildInfoRow(
            icon: Icons.home,
            label: 'Rumah Saat Ini',
            value: data.alamatRumah,
          ),
          const Divider(height: 1),
          
          // 4. Status Kepemilikan
          _buildInfoRow(
            icon: Icons.vpn_key,
            label: 'Status Kepemilikan',
            value: data.statusKepemilikan,
          ),
          const Divider(height: 1),
          
          // 5. Status Keluarga
          _buildStatusRow(
            icon: Icons.info_outline,
            label: 'Status Keluarga',
            status: data.statusKeluarga,
            statusColor: data.statusColor,
            statusBackgroundColor: data.statusBackgroundColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isHeader = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[700], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isHeader ? 16 : 15,
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
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

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String status,
    required Color statusColor,
    required Color statusBackgroundColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[700], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBackgroundColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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