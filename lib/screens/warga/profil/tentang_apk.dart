import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moon_design/moon_design.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static const Color _primaryColor = Color(0xFF6A5AE0);
  static const Color _textColor = Color(0xFF1F2937);
  static const Color _backgroundColor = Color(0xFFF7F7F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            MoonButton.icon(
              onTap: () => context.pop(),
              icon: const Icon(MoonIcons.controls_chevron_left_32_regular),
            ),
            const SizedBox(width: 8),
            const Text(
              "Tentang Aplikasi",
              style: TextStyle(
                color: _textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAppLogo(),
            const SizedBox(height: 30),

            _buildInfoCard(
              children: [
                _buildInfoRow('Nama Aplikasi', 'Jawara Pintar'),
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
                _buildInfoRow('Versi', '1.6.1 (Build 20251206)', isBold: true),
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E7EB)),
                _buildInfoRow('Dibuat oleh', 'Kelompok 2 TI-3G'),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              'Aplikasi ini dibuat untuk mempermudah warga dalam mengelola informasi, iuran, dan aspirasi di lingkungan RW 001. Kami berkomitmen untuk meningkatkan transparansi dan pelayanan publik berbasis komunitas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 40),

            // Hak Cipta
            Text(
              '© ${DateTime.now().year} Jawara Pintar. Hak Cipta Dilindungi.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.mobile_friendly, 
            size: 60,
            color: _primaryColor,
          ),
          const SizedBox(height: 8),
          const Text(
            'Jawara Pintar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: _textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: _primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}