import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/services/store_status_service.dart';
import 'package:moon_design/moon_design.dart';

class AuthStoreScreen extends StatefulWidget {
  const AuthStoreScreen({super.key});

  @override
  State<AuthStoreScreen> createState() => _AuthStoreScreenState();
}

class _AuthStoreScreenState extends State<AuthStoreScreen> {
  @override
  void initState() {
    super.initState();
    _checkStoreStatus();
  }

  // Cek status toko
  void _checkStoreStatus() async {
    int status = await StoreStatusService.getStoreStatus();
    if (!mounted) return;

    switch (status) {
      case 2:
        // Sudah punya toko - langsung ke dashboard
        context.goNamed('WargaMarketplaceStore');
        break;
      case 1:
        // Menunggu validasi
        context.goNamed('StorePendingValidation');
        break;
      case 3:
        // Toko ditolak
        context.goNamed('StoreRejected');
        break;
      case 0:
      default:
        // Belum punya toko - langsung ke register
        context.goNamed('WargaStoreRegister');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon toko
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MoonTokens.light.colors.gohan.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  size: 40,
                  color: MoonTokens.light.colors.piccolo,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Memeriksa Status Toko',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Memuat informasi toko Anda...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A5AE0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
