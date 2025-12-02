// lib/screens/my_store_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/product_model.dart';
import 'package:jawara_pintar_kel_5/models/marketplace/store_model.dart';
import 'package:jawara_pintar_kel_5/providers/product_provider.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/store_service.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;

class MyStoreDashboardScreen extends StatefulWidget {
  final StoreModel? store; 

  const MyStoreDashboardScreen({super.key, this.store});

  @override
  State<MyStoreDashboardScreen> createState() => _MyStoreDashboardScreenState();
}

class _MyStoreDashboardScreenState extends State<MyStoreDashboardScreen> {
  static const Color primaryColor = Color(0xFF6A5AE0);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);


  StoreModel? storeData;
  bool _isLoading = true;

  int totalProducts = 0;
  final int pendingOrders = 3;
  final double monthlyRevenue = 450000;
  final double storeRating = 4.9;

  bool _isStoreDetailsExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    try {
      final supabase = Supabase.instance.client;
      final email = supabase.auth.currentUser?.email;
      
      if (email == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User tidak terautentikasi')),
          );
        }
        return;
      }

      // Get warga ID
      final wargaResponse = await supabase
          .from('warga')
          .select('id')
          .eq('email', email)
          .single();
      
      final userId = wargaResponse['id'].toString();
      
      // Get store data
      final storeService = StoreService();
      final store = await storeService.getStoreByUserId(userId);
      
      if (store != null) {
        // Get product count for this store
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        await productProvider.fetchAllProducts();
        final storeProducts = productProvider.products.where((p) => p.storeId == store.storeId).toList();
        
        if (mounted) {
          setState(() {
            storeData = store;
            totalProducts = storeProducts.length;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading store data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data toko: $e')),
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant MyStoreDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.store != null && widget.store != oldWidget.store) {
      setState(() {
        storeData = widget.store;
      });
    }
  }

  void _toggleStoreDetails() {
    setState(() {
      _isStoreDetailsExpanded = !_isStoreDetailsExpanded;
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final extra = GoRouterState.of(context).extra;

    if (extra is StoreModel) {
      setState(() {
        storeData = extra;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Dashboard Toko',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : storeData == null
              ? const Center(child: Text('Data toko tidak ditemukan'))
              : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStoreHeader(context),
          const SizedBox(height: 20),
          _buildPerformanceSummary(context),
          const SizedBox(height: 30),
          _buildSectionHeader('Kelola Toko'),
          const SizedBox(height: 10),
          _buildQuickMenu(context),
          const SizedBox(height: 30),
          _buildSectionHeader('Produk Terbaru'),
          const SizedBox(height: 10),
          _buildProductList(context),
        ],
      ),
    );
  }

    Widget _buildStoreHeader(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Column(
      children: [
        InkWell(
          onTap: _toggleStoreDetails,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(builder: (context, constraints) {
              // constraints.maxWidth => lebar Row yang tersedia
              double availableWidth = constraints.maxWidth;
              // Atur ukuran font berdasarkan lebar layar
              double titleFontSize = availableWidth < 350 ? 14 : 18;
              double infoFontSize = availableWidth < 350 ? 12 : 14;

              return Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: primaryColor,
                    child: const Icon(Icons.store, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeData?.nama ?? 'Toko Saya',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                storeRating.toString(),
                                style: TextStyle(
                                  fontSize: infoFontSize,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '| $totalProducts Produk Aktif',
                                style: TextStyle(
                                  fontSize: infoFontSize,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isStoreDetailsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade500,
                    size: 25,
                  )
                ],
              );
            }),
          ),
        ),
        if (_isStoreDetailsExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildStoreDetailsContent(),
          ),
      ],
    ),
  );
}

  Widget _buildStoreDetailsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.grey, height: 20),
        const Text('Informasi Detail Toko', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        const SizedBox(height: 10),
        _buildDetailItem(icon: Icons.description, label: 'Deskripsi', value: storeData?.deskripsi ?? 'Tidak ada deskripsi'),
        _buildDetailItem(icon: Icons.phone, label: 'Nomor Kontak', value: storeData?.kontak ?? 'Tidak ada kontak'),
        _buildDetailItem(icon: Icons.location_on, label: 'Alamat', value: storeData?.alamat ?? 'Tidak ada alamat'),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDetailItem({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: primaryColor.withOpacity(0.8), size: 18),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        Expanded(flex: 5, child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black54))),
      ]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)))]);
  }

  Widget _buildPerformanceSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildStatItem(label: 'Penghasilan Bulan Ini', value: formatRupiah(monthlyRevenue.toInt()), icon: Icons.paid, color: successColor),
        Container(height: 60, width: 1, color: Colors.grey.shade200),
        _buildStatItem(label: 'Pesanan Baru', value: pendingOrders.toString(), icon: Icons.delivery_dining, color: warningColor, isRupiah: false, onTap: () {
        }),
      ]),
    );
  }

  Widget _buildStatItem({required String label, required String value, required IconData icon, required Color color, VoidCallback? onTap, bool isRupiah = true}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.15), radius: 24, child: Icon(icon, color: color)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: isRupiah ? 14 : 20, fontWeight: isRupiah ? FontWeight.bold : FontWeight.w900, color: color)),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      ),
    );
  }

  Widget _buildQuickMenu(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: _buildMenuItem(context, icon: Icons.shopping_cart_checkout, label: 'Pesanan', onTap: () => context.pushNamed('MyStoreOrders'))),
        const SizedBox(width: 10),
        Expanded(child: _buildMenuItem(context, icon: Icons.inventory, label: 'Stok Produk', onTap: () => context.pushNamed('WargaMarketplaceStoreStock'))),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _buildMenuItem(context, icon: Icons.star_border, label: 'Ulasan', onTap: () => context.pushNamed('MyStoreReviews'))),
        const SizedBox(width: 10),
        Expanded(child: _buildMenuItem(context, icon: Icons.settings, label: 'Pengaturan', onTap: () => context.pushNamed('MyStoreSettings'))),
      ]),
    ]);
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(backgroundColor: primaryColor.withOpacity(0.1), child: Icon(icon, color: primaryColor, size: 24)),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final recentProducts = productProvider.products.take(5).toList(); // Show latest 5 products
    
    if (recentProducts.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade400), const SizedBox(height: 10), Text('Belum ada produk aktif.', style: TextStyle(color: Colors.grey.shade600))])));
    }
    return Column(children: recentProducts.map((p) => _buildProductCard(context, p)).toList());
  }

  Widget _buildProductCard(BuildContext context, ProductModel p) {
    final gradeColor = p.grade == 'Grade A' ? primaryColor : Colors.orange.shade600;
    return Card(margin: const EdgeInsets.only(bottom: 10), elevation: 2, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(
      contentPadding: const EdgeInsets.all(8),
      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(p.gambar ?? 'assets/images/placeholder.png', width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 60, color: primaryColor.withOpacity(0.1), child: Center(child: Icon(Icons.shopping_bag_outlined, color: primaryColor))))),
      title: Text(p.nama ?? 'Produk', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(formatRupiah(p.harga?.toInt() ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: gradeColor, borderRadius: BorderRadius.circular(4)), child: Text(p.grade?.replaceAll('Grade ', '') ?? 'A', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))]),
      ]),
      onTap: () => context.pushNamed('MyStoreProductDetail', extra: p),
    ));
  }
}
