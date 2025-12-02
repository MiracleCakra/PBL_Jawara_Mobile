import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/broadcast_model.dart';
import 'package:jawara_pintar_kel_5/models/kegiatan/kegiatan_model.dart';
import 'package:jawara_pintar_kel_5/providers/product_provider.dart';
import 'package:jawara_pintar_kel_5/services/broadcast_service.dart';
import 'package:jawara_pintar_kel_5/services/kegiatan_service.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/review_service.dart';
import 'package:jawara_pintar_kel_5/utils.dart' show formatRupiah;
import 'package:jawara_pintar_kel_5/widget/product_image.dart';
import 'package:provider/provider.dart';

final List<Map<String, String>> dummyDataKegiatan = [
  {
    'judul': 'Pemberitahuan Kerja Bakti Lingkungan',
    'pj': 'Pak Habibi',
    'tanggal': '12/10/2025',
    'kategori': 'Sosial',
    'lokasi': 'Balai Warga RW 01',
    'deskripsi':
        'Kerja bakti membersihkan lingkungan dari sampah dan selokan untuk menjaga kebersihan dan keamanan lingkungan.',
    'dibuat_oleh': 'Admin Jawara',
    'has_docs': 'true',
  },
  {
    'judul': 'Parkir Liar di Depan Gerbang',
    'tanggal': '18/11/2025',
    'kategori': 'Keamanan',
    'lokasi': 'Pos Satpam',
    'deskripsi': 'Rapat membahas penertiban parkir liar.',
    'dibuat_oleh': 'Admin Jawara',
    'has_docs': 'false',
  },
];

final List<Map<String, dynamic>> dummyFinancialData = [
  {
    'label': 'Pemasukan Kas RT',
    'amount': 1500000,
    'color': Colors.green.shade600,
  },
  {
    'label': 'Pengeluaran Kas RT',
    'amount': 500000,
    'color': Colors.red.shade600,
  },
];

class RumahDashboardScreen extends StatelessWidget {
  const RumahDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(isTablet: isTablet),
              _FinancialSummarySection(isTablet: isTablet),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _SectionTitle("Rekomendasi Produk"),
                    const SizedBox(height: 10),
                    _HorizontalProductList(),
                    const SizedBox(height: 30),
                    _SectionTitle("Informasi Terbaru"),
                    const SizedBox(height: 10),
                    const _LatestInfoList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= Header Section =================
class _HeaderSection extends StatelessWidget {
  final bool isTablet;
  const _HeaderSection({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A5AE0), Color(0xFF8EA3F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: const [_UserHeaderWidget(), SizedBox(height: 20)],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: const _StatusIuranCard(),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}

class _UserHeaderWidget extends StatelessWidget {
  const _UserHeaderWidget();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Selamat Datang,",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "Bapak Susanto",
                style: TextStyle(
                  fontSize: isTablet ? 28 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "RT 001 / RW 001",
                style: TextStyle(color: Colors.white.withOpacity(.9)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================= Status Iuran =================
class _StatusIuranCard extends StatelessWidget {
  final double horizontalPadding;
  const _StatusIuranCard({this.horizontalPadding = 16.0});

  @override
  Widget build(BuildContext context) {
    const isOverdue = true;
    const nominal = "Rp 50.000";
    const primaryColor = Color(0xFF6A5AE0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // <--- penting
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TAGIHAN IURAN KAS RT",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isOverdue ? nominal : "LUNAS",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      isOverdue
                          ? "Jatuh Tempo: 30 November 2025"
                          : "Hingga Desember 2025",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (isOverdue)
                SizedBox(
                  height: 40,
                  child: FilledButton(
                    onPressed: () => context.go("/warga/keluarga/tagihan"),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text(
                      "Bayar",
                      style: TextStyle(color: Colors.white),
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

// ================= Financial Summary =================
class _FinancialSummarySection extends StatelessWidget {
  final bool isTablet;
  const _FinancialSummarySection({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    final totalIncome =
        dummyFinancialData.firstWhere(
              (data) => data['label'] == 'Pemasukan Kas RT',
            )['amount']
            as int;
    final totalExpense =
        dummyFinancialData.firstWhere(
              (data) => data['label'] == 'Pengeluaran Kas RT',
            )['amount']
            as int;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _SectionTitle("Laporan Keuangan"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FinancialCard(
                  title: "Pemasukan",
                  amount: totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  color: Colors.green.shade600,
                  onTap: () => context.go("/warga/dashboard/pemasukan"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FinancialCard(
                  title: "Pengeluaran",
                  amount: totalExpense,
                  icon: Icons.arrow_upward_rounded,
                  color: Colors.red.shade600,
                  onTap: () => context.go("/warga/dashboard/pengeluaran"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final String title;
  final int amount;
  final IconData icon;
  final Color color;
  final bool isBalanceCard;
  final VoidCallback? onTap;

  const _FinancialCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.isBalanceCard = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isBalanceCard ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: isBalanceCard ? 26 : 22,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: isBalanceCard
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: Colors.black54,
                        fontSize: isBalanceCard ? 16 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatRupiah(amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isBalanceCard ? 26 : 18,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= Horizontal Product List =================
class _HorizontalProductList extends StatefulWidget {
  const _HorizontalProductList();

  @override
  State<_HorizontalProductList> createState() => _HorizontalProductListState();
}

class _HorizontalProductListState extends State<_HorizontalProductList> {
  final Map<int, double> _productRatings = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      if (provider.products.isEmpty) {
        provider.fetchAllProducts();
      }
    });
  }

  Future<void> _loadRating(int productId) async {
    if (!_productRatings.containsKey(productId)) {
      try {
        final rating = await ReviewService().getAverageRating(productId);
        if (mounted) {
          setState(() {
            _productRatings[productId] = rating;
          });
        }
      } catch (e) {
        // Ignore error, rating will remain null
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final products = context
        .watch<ProductProvider>()
        .products
        .take(10)
        .toList();

    if (products.isEmpty) {
      return SizedBox(
        height: isTablet ? 240 : 190,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: isTablet ? 240 : 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = products[index];
          final gradeColor = p.grade == 'Grade A'
              ? const Color(0xFF6A5AE0)
              : p.grade == 'Grade B'
              ? Colors.orange.shade600
              : p.grade == 'Grade C'
              ? Colors.pink.shade700
              : Colors.grey;

          return SizedBox(
            width: isTablet ? 170 : 140,
            child: Card(
              color: Colors.white.withOpacity(0.95),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () => context.pushNamed('WargaProductDetail', extra: p),
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10),
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
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: gradeColor,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                p.grade!.replaceAll('Grade ', ''),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.nama!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            formatRupiah(p.harga!.toInt()),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          FutureBuilder<void>(
                            future: _loadRating(p.productId!),
                            builder: (context, snapshot) {
                              final rating = _productRatings[p.productId];
                              if (rating == null || rating == 0) {
                                return const Text(
                                  'Belum ada rating',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                );
                              }
                              return Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber,
                                  ),
                                  Text(
                                    " ${rating.toStringAsFixed(1)}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LatestInfoList extends StatefulWidget {
  const _LatestInfoList();

  @override
  State<_LatestInfoList> createState() => _LatestInfoListState();
}

class _LatestInfoListState extends State<_LatestInfoList> {
  final KegiatanService _kegiatanService = KegiatanService();
  final BroadcastService _broadcastService = BroadcastService();
  late Future<List<Map<String, dynamic>>> _latestInfoFuture;

  @override
  void initState() {
    super.initState();
    _latestInfoFuture = _fetchLatestInfo();
  }

  Future<List<Map<String, dynamic>>> _fetchLatestInfo() async {
    try {
      final kegiatanList = await _kegiatanService.getKegiatan();
      final broadcastList = await _broadcastService.getBroadcasts();

      List<Map<String, dynamic>> combinedList = [];

      combinedList.addAll(
        kegiatanList.map(
          (k) => {'type': 'Kegiatan', 'data': k, 'date': k.tanggal},
        ),
      );

      combinedList.addAll(
        broadcastList.map(
          (b) => {'type': 'Broadcast', 'data': b, 'date': b.tanggal},
        ),
      );

      combinedList.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
      );

      return combinedList.take(3).toList();
    } catch (e) {
      throw Exception('Failed to load latest info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _latestInfoFuture,

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final latestInfo = snapshot.data!;

          return Column(
            children: latestInfo.map((info) {
              final type = info['type'] as String;

              final data = info['data'];

              final title = type == 'Kegiatan'
                  ? (data as KegiatanModel).judul
                  : (data as BroadcastModel).judul;

              final date = DateFormat(
                'dd/MM/yyyy',
              ).format(info['date'] as DateTime);

              void handleTap() {
                if (type == 'Kegiatan') {
                  context.goNamed(
                    'WargaKegiatanDetail',
                    pathParameters: {
                      'id': (data as KegiatanModel).id.toString(),
                    },
                  );
                } else if (type == 'Broadcast') {
                  context.goNamed(
                    'WargaBroadcastDetail',
                    pathParameters: {
                      'id': (data as BroadcastModel).id.toString(),
                    },
                  );
                }
              }

              return Card(
                color: Colors.white.withOpacity(0.95),
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black12, width: 1),
                ),
                child: ListTile(
                  onTap: handleTap,
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "$type - $date",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      type == "Kegiatan"
                          ? Icons.calendar_today
                          : Icons.campaign,

                      color: Colors.deepPurple,
                      size: 20,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        } else {
          return const Center(child: Text("Tidak ada informasi terbaru"));
        }
      },
    );
  }
}
