import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailChannelPage extends StatelessWidget {
  final Map<String, String> channelData;

  const DetailChannelPage({super.key, required this.channelData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Detail Channel Transfer',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 18, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text('Edit', style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'hapus',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                context.push('/admin/lainnya/channel-transfer/edit', extra: channelData);
              } else if (value == 'hapus') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Channel'),
                    content: const Text('Apakah Anda yakin ingin menghapus channel ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.pop();
                          // Logic hapus data
                        },
                        child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.04),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Channel & Tipe Channel (dalam satu baris)
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            label: 'Nama Channel',
                            value: channelData['name'] ?? '-',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDetailItem(
                            label: 'Tipe Channel',
                            value: channelData['type'] ?? '-',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDetailItem(
                      label: 'Nomor Rekening / Akun',
                      value: channelData['account'] ?? '-',
                    ),
                    const SizedBox(height: 20),
                    _buildDetailItem(
                      label: 'Nama Pemilik',
                      value: channelData['owner'] ?? '-',
                    ),
                    const SizedBox(height: 20),
                    _buildDetailItem(
                      label: 'Catatan',
                      value: channelData['notes'] ?? '-',
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

  Widget _buildDetailItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}