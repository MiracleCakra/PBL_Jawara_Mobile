import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:SapaWarga_kel_2/models/marketplace/order_model.dart';
import 'package:SapaWarga_kel_2/screens/warga/marketplace/belanja/buyer_order_detail.dart';

class DummyOrderModel extends OrderModel {
  DummyOrderModel({
    int? orderId,
    int? totalQty,
    double? totalPrice,
    String? orderStatus,
    String? paymentStatus,
    String? deliveryMethod,
    double? shippingFee,
    String? alamat,
    DateTime? createdAt,
    String? paymentMethod,
  }) : super(
          orderId: orderId,
          totalQty: totalQty,
          totalPrice: totalPrice,
          orderStatus: orderStatus,
          paymentStatus: paymentStatus,
          deliveryMethod: deliveryMethod,
          shippingFee: shippingFee,
          alamat: alamat,
          createdAt: createdAt,
          paymentMethod: paymentMethod,
        );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      anonKey: 'dummy',
    );
  });

  testWidgets('BuyerOrderDetailScreen shows loading indicator',
      (WidgetTester tester) async {
    final order = DummyOrderModel(orderId: 1);

    await tester.pumpWidget(
      MaterialApp(home: BuyerOrderDetailScreen(order: order)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('BuyerOrderDetailScreen shows order info sections',
      (WidgetTester tester) async {
    final order = DummyOrderModel(
      orderId: 1,
      totalQty: 2,
      totalPrice: 20000,
      orderStatus: 'completed',
      paymentStatus: 'paid',
      deliveryMethod: 'Ambil di Toko',
      alamat: 'Jl. Mawar No. 12',
      createdAt: DateTime.now(),
      paymentMethod: 'COD',
    );

    await tester.pumpWidget(
      MaterialApp(home: BuyerOrderDetailScreen(order: order)),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Detail Pesanan'), findsWidgets);
    expect(find.textContaining('Informasi Pesanan'), findsWidgets);
    expect(find.textContaining('Alamat'), findsWidgets);
    expect(find.textContaining('Detail Produk'), findsWidgets);
    expect(find.textContaining('Metode Pengiriman'), findsWidgets);
    expect(find.textContaining('Ringkasan Pembayaran'), findsWidgets);
  });

  testWidgets('BuyerOrderDetailScreen shows pay button if unpaid',
      (WidgetTester tester) async {
    final order = DummyOrderModel(
      orderId: 2,
      orderStatus: 'completed',
      paymentStatus: 'unpaid',
    );

    await tester.pumpWidget(
      MaterialApp(home: BuyerOrderDetailScreen(order: order)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Bayar Sekarang'), findsOneWidget);
  });

  testWidgets('BuyerOrderDetailScreen shows review button if paid',
      (WidgetTester tester) async {
    final order = DummyOrderModel(
      orderId: 3,
      orderStatus: 'completed',
      paymentStatus: 'paid',
    );

    await tester.pumpWidget(
      MaterialApp(home: BuyerOrderDetailScreen(order: order)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tulis Ulasan'), findsOneWidget);
  });
}
