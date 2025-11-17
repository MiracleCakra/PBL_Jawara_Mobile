import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LainnyaScreen extends StatelessWidget {
  const LainnyaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text('Lainnya', style: TextStyle(fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.black54, size: 26),
                  ),
                  title: const Text('Ningga', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ningga@gmail.com', style: TextStyle(color: Colors.grey.shade600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/admin/lainnya/edit-profile');
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text('Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Icon(Icons.person_outline, color: Colors.black),
                      title: const Text('Manajemen Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/admin/lainnya/manajemen-pengguna');
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Icon(Icons.compare_arrows, color: Colors.black),
                      title: const Text('Channel Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/admin/lainnya/manajemen-channel');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Icon(Icons.logout, color: Colors.red.shade600),
                  title: Text(
                    'Keluar',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: const SizedBox(width: 24), 
                  onTap: () {
                    context.go('/login'); 
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
