class OrderModel {
  final String id;
  final String productName;
  final int quantity;
  final int totalPrice;
  final String status;
  final String customerName;
  final String deliveryAddress; // string biar aman dan kompatibel

  const OrderModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.customerName,
    required this.deliveryAddress,

  });

  // Helper warna status (opsional, kalau mau dipakai)
  String get displayStatus => status;

  /// Dummy data
  static const List<OrderModel> dummyOrders = [
    OrderModel(
      id: 'ORD001',
      productName: 'Tomat Segar',
      quantity: 2,
      totalPrice: 30000,
      customerName: 'Budi Santoso',
      deliveryAddress: 'RT 01 RW 02 BLOK A3 No.13',
      status: 'Perlu Dikirim',
    ),
    OrderModel(
      id: 'ORD002',
      productName: 'Tomat Segar',
      quantity: 1,
      totalPrice: 15000,
      customerName: 'Siti',
      deliveryAddress: 'RT 02 RW 02 BLOK C4 No.3',
      status: 'Perlu Dikirim',
    ),
    OrderModel(
      id: 'ORD003',
      productName: 'Wortel Layu',
      quantity: 3,
      totalPrice: 45000,
      customerName: 'Gita',
      deliveryAddress: 'RT 04 RW 03 BLOK F4 No.5',
      status: 'Dikirim',
    ),
    OrderModel(
      id: 'ORD004',
      productName: 'Wortel Segar',
      quantity: 5,
      totalPrice: 50000,
      customerName: 'Andi',
      deliveryAddress: 'RT 02 RW 02 BLOK C4 No.6',
      status: 'Selesai',
    ),
    OrderModel(
      id: 'ORD005',
      productName: 'Wortel Segar',
      quantity: 1,
      totalPrice: 25000,
      customerName: 'Linans',
      deliveryAddress: 'RT 03 RW 03 BLOK F4 No.9',
      status: 'Selesai',
    ),
  ];
}
