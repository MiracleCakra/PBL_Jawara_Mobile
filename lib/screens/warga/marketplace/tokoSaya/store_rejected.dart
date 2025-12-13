import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/providers/marketplace/store_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreRejectedScreen extends StatefulWidget {
  const StoreRejectedScreen({super.key});

  @override
  State<StoreRejectedScreen> createState() => _StoreRejectedScreenState();
}

class _StoreRejectedScreenState extends State<StoreRejectedScreen> {
  String? _rejectionReason;

  @override
  void initState() {
    super.initState();
    _loadRejectionReason();
  }

  Future<void> _loadRejectionReason() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user?.email == null) return;

      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', user!.email!)
          .maybeSingle();

      if (wargaResponse == null) return;

      final nik = wargaResponse['id'] as String;
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      await storeProvider.fetchStoreByUserId(nik);

      final currentStore = storeProvider.currentStore;

      if (currentStore != null && mounted) {
        setState(() {
          _rejectionReason = currentStore.alasan;
        });
      }
    } catch (e) {
      print('Error loading rejection reason: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Pendaftaran Ditolak'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 60,
                  color: Color(0xFFE53935),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Pendaftaran Toko Ditolak',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Mohon maaf, pendaftaran toko Anda ditolak oleh admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),

              if (_rejectionReason != null && _rejectionReason!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Alasan Penolakan:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _rejectionReason!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade900,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Text(
                'Anda dapat mengajukan pendaftaran ulang dengan memperbaiki data toko sesuai alasan penolakan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    context.goNamed('WargaStoreRegister');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A5AE0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ajukan Pendaftaran Ulang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go('/warga/marketplace');
                },
                child: Text(
                  'Kembali ke Menu',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
