import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  static const Color _primaryColor = Color(0xFF6366F1);
  final TextEditingController _searchController = TextEditingController();
  
  List<ProductModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    final extra = GoRouter.of(context).routerDelegate.currentConfiguration.extra;
    if (extra is Map<String, dynamic> && extra.containsKey('grade')) {
      final String initialQuery = 'Grade ${extra['grade']}';
      _searchController.text = initialQuery;
      _performSearch(initialQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });
    
    final allProducts = ProductModel.getSampleProducts().where((p) => p.isVerified).toList();
    final lowerCaseQuery = query.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }
    
    final filtered = allProducts.where((product) {
      return product.name.toLowerCase().contains(lowerCaseQuery) ||
             product.description.toLowerCase().contains(lowerCaseQuery) ||
             product.grade.toLowerCase().contains(lowerCaseQuery);
    }).toList();

    setState(() {
      _searchResults = filtered;
      _isSearching = false;
    });
  }

  Widget _buildProductResultTile(ProductModel product) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          product.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
              width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.image)),
        ),
      ),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${formatRupiah(product.price)} • ${product.grade}',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        context.pushNamed('WargaProductDetail', extra: product);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Cari sayur, grade, atau toko...",
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
          ),
          onSubmitted: _performSearch,
          onChanged: (value) {
            if (value.length > 2 || value.isEmpty) {
              _performSearch(value);
            }
          },
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : _searchController.text.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 15),
                      const Text('Mulai ketik untuk mencari produk.',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
                          const SizedBox(height: 15),
                          Text('Tidak ditemukan hasil untuk "${_searchController.text}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, color: Colors.red.shade600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return _buildProductResultTile(_searchResults[index]);
                      },
                    ),
    );
  }
}