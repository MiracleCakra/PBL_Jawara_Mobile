import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/services/store_status_service.dart';

class MarketplaceMenuWarga extends StatelessWidget {
  const MarketplaceMenuWarga({super.key});

  static const Color _shopColor = Color(0xFF0072FF);
  static const Color _storeColor = Color(0xFF6366F1);

  void _handleTokoTap(BuildContext context) async {
    int status = await StoreStatusService.getStoreStatus();

    switch (status) {
      case 2:
        // Sudah punya toko aktif
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
      case 4:
        // Toko nonaktif (owner atau admin)
        context.goNamed('StoreDeactivated');
        break;
      case 0:
      default:
        // Belum punya toko, ke AuthStoreScreen
        context.goNamed('AuthStoreScreen');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text(
          'Marketplace Warga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.storefront,
                  label: 'Belanja Produk',
                  color: _shopColor,
                  onTap: () => context.go('/warga/marketplace/explore'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.receipt_long,
                  label: 'Pesanan Saya',
                  color: Colors.green,
                  onTap: () => context.goNamed('MyOrders'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  label: 'Toko Saya',
                  color: _storeColor,
                  onTap: () => _handleTokoTap(context),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
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
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                color: color.withOpacity(0.12),
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
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
