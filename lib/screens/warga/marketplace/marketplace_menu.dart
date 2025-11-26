import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MarketplaceMenuWarga extends StatelessWidget {
  const MarketplaceMenuWarga({super.key});

  static const Color _shopColor = Color(0xFF0072FF); 
  static const Color _storeColor = Color(0xFF6366F1);


  void _checkStoreStatus(BuildContext context) {
    const int storeStatus = 2; //  0, 1, atau 2

    switch (storeStatus) {
      case 2:
        context.goNamed('WargaMarketplaceStore');
        break;

      case 1:
        context.goNamed('StorePendingValidation');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Toko Anda masih menunggu persetujuan Admin.'), duration: Duration(seconds: 1)),
        );
        break;

      case 0:
      default:
        context.goNamed('WargaStoreRegister');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus mendaftar toko terlebih dahulu.'), duration: Duration(seconds: 1)),
        );
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
                  icon: Icons.shopping_bag_outlined,
                  label: 'Toko Saya',
                  color: _storeColor,
                  onTap: () => _checkStoreStatus(context),
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

  /*Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ketentuan Marketplace',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        _buildInfoItem(
          icon: Icons.shield_outlined,
          text: 'Semua produk harus diverifikasi oleh Admin RT/RW sebelum tayang.',
        ),
        _buildInfoItem(
          icon: Icons.location_on_outlined,
          text: 'Marketplace ini hanya berlaku untuk pembeli dan penjual di lingkungan RT/RW.',
        ),
        _buildInfoItem(
          icon: Icons.handshake_outlined,
          text: 'Pembayaran dilakukan secara langsung (COD) atau transfer antar warga.',
        ),
      ],
    );
  }*/

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
