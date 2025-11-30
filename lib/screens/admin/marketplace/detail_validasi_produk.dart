import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:jawara_pintar_kel_5/models/marketplace/marketplace_model.dart' as marketplace_model;

final Color unguColor = marketplace_model.unguColor;

class DetailValidasiProdukScreen extends StatelessWidget {
  final marketplace_model.ActiveProductItem product;
  final Function(String newStatus)? onActionComplete; 

  const DetailValidasiProdukScreen({
    super.key, 
    required this.product,
    this.onActionComplete,
  });
    
  Future<void> _handleApprove(
      BuildContext context, marketplace_model.ActiveProductItem item) async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mengirim persetujuan...')),
    );
    await Future.delayed(const Duration(seconds: 2));
    onActionComplete?.call('Disetujui'); 
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Produk "${item.productName}" berhasil disetujui')),
      );
      context.pop();
    }
  }

  void _showRejectDialog(BuildContext parentContext, marketplace_model.ActiveProductItem item, {Function(String status)? onActionComplete}) {
    String alasan = '';

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan menolak produk "${item.productName}". Masukkan alasan penolakan:',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              onChanged: (value) => alasan = value,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Alasan penolakan, misalnya: gambar blur/produk tidak sesuai.',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[500],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),

        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Batal'),
          ),

          ElevatedButton(
            onPressed: () async {
              if (alasan.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan tidak boleh kosong.')),
                );
                return;
              }

              Navigator.of(context).pop();

              await Future.delayed(const Duration(seconds: 1));
              onActionComplete?.call('Ditolak');

              if (parentContext.mounted) {
                parentContext.pop(); 

                Future.delayed(const Duration(milliseconds: 200), () {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Produk "${item.productName}" berhasil ditolak. Alasan: $alasan',
                      ),
                    ),
                  );
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tolak & Kirim'),
          ),
        ],
      ),
    );
  }

  void _showValidationActionsSheet(BuildContext parentContext) {
  if (product.status != 'Pending') return;

  showModalBottomSheet(
    context: parentContext,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Validasi Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop(); // tutup sheet
                        _showRejectDialog(parentContext, product, onActionComplete: onActionComplete);
                      },
                      child: const Text('Tolak Produk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop(); // tutup sheet
                        _handleApprove(parentContext, product);
                      },
                      child: const Text('Setujui Produk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: unguColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
  // --- WIDGET HELPER DETAIL ---
  
  Widget _buildImageCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          product.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.productName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          
          // Tampilkan Kategori Produk
          Text(
            'Kategori: ${product.category}', 
            style: TextStyle(fontSize: 14, color: Colors.blue[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          // Deskripsi Produk
          Text(
            product.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),

          // Data Penjual
          Text(
            'Diunggah: ${product.timeUploaded}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            'Penjual: ${product.sellerName}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildComputerVisionResult(Color confidenceColor) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verifikasi Otomatis (Computer Vision)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const Divider(height: 16, color: Colors.blue),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Klasifikasi CV:', style: TextStyle(fontSize: 13, color: Colors.blue.shade800)),
                  // Hasil Klasifikasi CV
                  Text(product.cvResult,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900)),
                ],
              ),
              // Tingkat Kepercayaan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: confidenceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${(product.cvConfidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: confidenceColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET UTAMA BUILD DETAIL ---

  @override
  Widget build(BuildContext context) {
    Color confidenceColor = product.cvConfidence > 0.90 
        ? Colors.green.shade700 
        : (product.cvConfidence > 0.70 ? Colors.orange.shade700 : Colors.red.shade700);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: const Text(
          'Detail Validasi Produk',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // Ikon Titik Tiga
        actions: [
          if (product.status == 'Pending')
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () => _showValidationActionsSheet(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCard(context),
            const SizedBox(height: 16),
            _buildInfoCard(),
            _buildComputerVisionResult(confidenceColor),
            const SizedBox(height: 24),
            if (product.status != 'Pending') 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: product.status == 'Disetujui' 
                      ? unguColor.withOpacity(0.1) 
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: product.status == 'Disetujui' 
                        ? unguColor.withOpacity(0.5) 
                        : Colors.red.shade200
                  ),
                ),
                child: Center(
                  child: Text(
                    'PRODUK SUDAH ${product.status.toUpperCase()}',
                    style: TextStyle(
                      color: product.status == 'Disetujui' 
                          ? unguColor 
                          : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}