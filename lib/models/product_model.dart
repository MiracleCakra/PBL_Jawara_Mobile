class ProductModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String grade; // Grade A, B, C
  final int price;
  final double rating;
  final bool isVerified;
  
  // PROPERTI BARU:
  final int stock; // Jumlah stok (misal: 10 kg)
  final String unit; // Satuan (misal: 'kg', 'ikat', 'pcs')
  final String? rejectionReason; // Alasan penolakan admin (null jika verified/pending)

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.grade,
    required this.price,
    required this.rating,
    required this.isVerified,
    // Tambahkan di constructor:
    this.stock = 0,
    this.unit = 'kg',
    this.rejectionReason, 
  });

  // ---- SAMPLE DATA UNTUK TESTING ----
  static List<ProductModel> getSampleProducts() {
    return [
      // 1. VERIFIED & STOK ADA (Muncul di dashboard dan explore)
      ProductModel(
        id: 'p1',
        name: 'Tomat Segar',
        description: 'Tomat merah segar langsung dari kebun warga.',
        imageUrl: 'assets/images/tomatsegar.jpg',
        grade: 'Grade A',
        price: 15000,
        rating: 4.8,
        isVerified: true,
        stock: 15,
        unit: 'kg',
      ),
      // 2. VERIFIED & STOK ADA (Muncul di dashboard dan explore)
      ProductModel(
        id: 'p2',
        name: 'Wortel segar',
        description: 'Wortel organik dengan kualitas premium.',
        imageUrl: 'assets/images/wortelsegar.jpg',
        grade: 'Grade A',
        price: 12000,
        rating: 4.6,
        isVerified: true,
        stock: 25,
        unit: 'ikat',
      ),
      ProductModel(
        id: 'p2',
        name: 'Wortel layu',
        description: 'Wortel layu.',
        imageUrl: 'assets/images/wortellayu.jpg',
        grade: 'Grade B',
        price: 12000,
        rating: 4.6,
        isVerified: true,
        stock: 25,
        unit: 'ikat',
      ),
      // 3. PENDING (isVerified: false, rejectionReason: null)
      ProductModel(
        id: 'p3',
        name: 'Tomat Busuk',
        description: 'Pakan magot, Biofuel',
        imageUrl: 'assets/images/tomatbusuk.jpg',
        grade: 'Grade C',
        price: 5000,
        rating: 0.0,
        isVerified: false,
        stock: 5,
        unit: 'kg',
        rejectionReason: null, // Status pending
      ),
      
      // 4. REJECTED
      ProductModel(
        id: 'p4',
        name: 'Wortel Layu',
        description: 'Wortel layu tapi masih segar di dalamnya.',
        imageUrl: 'assets/images/wortellayu.jpg',
        grade: 'Grade B',
        price: 8000,
        rating: 4.3,
        isVerified: false,
        stock: 10,
        unit: 'pcs',
        rejectionReason: 'Kualitas foto buram. Harap foto ulang dengan pencahayaan yang lebih baik.', // Alasan penolakan
      ),
    ];
  }

  // ---- FILTERS BANTUAN ----
  static List<ProductModel> getVerifiedProducts() {
    return getSampleProducts().where((p) => p.isVerified).toList();
  }

  static List<ProductModel> getPendingProducts() {
    return getSampleProducts().where((p) => !p.isVerified && p.rejectionReason == null).toList();
  }

  static List<ProductModel> getRejectedProducts() {
    return getSampleProducts().where((p) => !p.isVerified && p.rejectionReason != null).toList();
  }
}
