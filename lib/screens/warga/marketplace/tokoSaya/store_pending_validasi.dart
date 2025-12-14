import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorePendingValidationScreen extends StatefulWidget {
  const StorePendingValidationScreen({super.key});

  @override
  State<StorePendingValidationScreen> createState() =>
      _StorePendingValidationScreenState();
}

class _StorePendingValidationScreenState
    extends State<StorePendingValidationScreen> {
  bool _isReactivationRequest = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStoreStatus();
  }

  Future<void> _checkStoreStatus() async {
    try {
      final authUser = Supabase.instance.client.auth.currentUser;
      final userEmail = authUser?.email;

      if (userEmail == null) {
        setState(() => _isLoading = false);
        return;
      }

      final wargaResponse = await Supabase.instance.client
          .from('warga')
          .select('id')
          .eq('email', userEmail)
          .maybeSingle();

      if (wargaResponse == null) {
        setState(() => _isLoading = false);
        return;
      }

      final nik = wargaResponse['id'] as String;

      final storeResponse = await Supabase.instance.client
          .from('store')
          .select('deactivated_by, verifikasi, alasan')
          .eq('user_id', nik)
          .maybeSingle();

      if (storeResponse != null) {
        // Check if this is a reactivation request
        final deactivatedBy = storeResponse['deactivated_by'] as String?;
        final alasan = storeResponse['alasan'] as String?;

        setState(() {
          _isReactivationRequest =
              deactivatedBy == 'admin' &&
              alasan != null &&
              alasan.contains('PENGAJUAN AKTIVASI ULANG');
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('ERROR checking store status: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Menunggu Persetujuan'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menunggu Persetujuan'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time_filled,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              Text(
                _isReactivationRequest
                    ? 'Permohonan Aktivasi Ulang Sedang Diproses'
                    : 'Pendaftaran Toko Anda Sedang Diproses',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _isReactivationRequest
                    ? 'Tim Admin akan segera meninjau permohonan aktivasi ulang toko Anda. Kami akan memberitahu Anda setelah proses validasi selesai.'
                    : 'Tim Admin akan segera memverifikasi data toko Anda. Kami akan memberitahu Anda setelah proses validasi selesai.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  context.go('/warga/marketplace');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Kembali ke Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
