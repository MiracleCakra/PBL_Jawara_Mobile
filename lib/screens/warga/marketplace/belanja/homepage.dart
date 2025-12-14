import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:jawara_pintar_kel_5/providers/product_provider.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;
import 'package:jawara_pintar_kel_5/widget/product_image.dart';
import 'package:provider/provider.dart';

class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  late PageController _pageController;
  int _currentBanner = 0;
  late Timer _bannerTimer;

  String? _selectedGrade;

  static const Color primaryColor = Color(0xFF6A5AE0);
  static const Color accentColor = Color(0xFF8EA3F5);
  static const Color greenFresh = Color(0xFF4CAF50);

  final List<String> _banners = [
    'https://plus.unsplash.com/premium_photo-1663127335918-ca883782c34a?q=80&w=1162&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1664527305903-bd7f9b68c51a?q=80&w=1170&auto=format&fit:crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1685946109335-8d7be8f1e05a?q=80&w=1171&auto=format&fit:crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%D',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Always refresh products from Supabase when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.fetchAllProducts(); // Always refresh
    });

    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentBanner < _banners.length - 1) {
        _currentBanner++;
      } else {
        _currentBanner = 0;
      }
      _pageController.animateToPage(
        _currentBanner,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _categoryButton({required String grade}) {
    Color color;
    String label;
    IconData icon;

    switch (grade) {
      case 'A':
        color = greenFresh;
        label = 'Grade A';
        icon = Icons.star;
        break;
      case 'B':
        color = Colors.amber.shade700;
        label = 'Grade B';
        icon = Icons.check_circle_outline;
        break;
      case 'C':
        color = Colors.red.shade700;
        label = 'Grade C / Busuk';
        icon = Icons.recycling;
        break;
      default:
        color = primaryColor;
        label = 'Lainnya';
        icon = Icons.more_horiz;
    }

    final bool isActive = _selectedGrade == grade;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGrade = isActive ? null : grade;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isActive ? color : color.withOpacity(0.15),
              border: isActive ? Border.all(color: color, width: 2) : null,
            ),
            child: Icon(icon, color: isActive ? Colors.white : color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive ? primaryColor : const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel p) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final gradeColor = p.grade == 'Grade A'
        ? primaryColor
        : p.grade == 'Grade B'
        ? Colors.orange.shade600
        : p.grade == 'Grade C'
        ? Colors.pink.shade700
        : Colors.grey;

    return Container(
      width: isTablet ? 170 : 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.pushNamed('WargaProductDetail', extra: p),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: ProductImage(
                      imagePath: p.gambar,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [gradeColor, gradeColor.withOpacity(0.8)],
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gradeColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        p.grade?.replaceAll('Grade ', '') ?? 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nama ?? 'Produk',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(p.harga?.toInt() ?? 0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                      const SizedBox(width: 2),
                      const Text(
                        "0.0",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.1), Colors.white],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          if (onViewAll != null)
            InkWell(
              onTap: onViewAll,
              child: Text(
                'Lihat Semua >',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final allProducts = productProvider.products;
    final isLoading = productProvider.isLoading;

    List<ProductModel> filteredProducts;
    if (_selectedGrade == null) {
      filteredProducts = allProducts;
    } else {
      filteredProducts = allProducts
          .where((p) => p.grade == 'Grade $_selectedGrade')
          .toList();
    }

    String qualityHeader = _selectedGrade == null
        ? '🥇 Kualitas Terbaik (Semua Grade)'
        : '🥇 Kualitas Terbaik (Grade $_selectedGrade)';
    String recommendationHeader = _selectedGrade == null
        ? '⭐ Rekomendasi Pilihan'
        : '⭐ Rekomendasi Grade $_selectedGrade';

    final displayQualityProducts = filteredProducts.take(6).toList();
    final recommendedProducts = filteredProducts.take(6).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        title: const Text(
          'Marketplace Warga',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed('WargaProductSearch'),
            icon: const Icon(Icons.search, color: Colors.black),
          ),
          IconButton(
            onPressed: () => context.go('/warga/marketplace/cart'),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _banners.length,
                onPageChanged: (index) =>
                    setState(() => _currentBanner = index),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    _banners[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade400,
                      child: const Center(
                        child: Text(
                          'Gagal Memuat Banner',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _banners.map((url) {
              int index = _banners.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 2.0,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentBanner == index
                      ? primaryColor
                      : Colors.grey.shade300,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          _buildSectionHeader('Kualitas Sayur'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _categoryButton(grade: 'A'),
                _categoryButton(grade: 'B'),
                _categoryButton(grade: 'C'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Memuat produk ...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else if (allProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada produk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Produk akan muncul di sini setelah ditambahkan',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredProducts.isEmpty && _selectedGrade != null)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 50,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tidak ada produk Grade $_selectedGrade yang tersedia saat ini.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                _buildSectionHeader(qualityHeader),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayQualityProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) =>
                        _buildProductCard(displayQualityProducts[index]),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionHeader(recommendationHeader),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: recommendedProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) =>
                        _buildProductCard(recommendedProducts[index]),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
