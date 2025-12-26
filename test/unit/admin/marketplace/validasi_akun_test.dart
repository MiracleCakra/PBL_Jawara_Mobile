import 'package:SapaWarga_kel_2/models/marketplace/store_model.dart';
import 'package:SapaWarga_kel_2/providers/marketplace/store_provider.dart';
import 'package:SapaWarga_kel_2/screens/admin/marketplace/validasi_akun.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class MockStoreProvider extends ChangeNotifier implements StoreProvider {
  @override
  StoreModel? get currentStore => null;
  @override
  List<StoreModel> get stores => [];
  @override
  bool get isLoading => false;
  @override
  String? get errorMessage => null;

  @override
  Future<void> fetchStoreByUserId(String userId) async {}
  @override
  Future<void> fetchStoreById(int storeId) async {}
  @override
  Future<void> fetchAllStores() async {}
  @override
  Future<void> fetchPendingStores() async {}
  @override
  Future<StoreModel?> createStore(StoreModel store) async => null;
  @override
  Future<bool> updateStore(int storeId, StoreModel store) async => false;
  @override
  Future<bool> updateVerificationStatus(
    int storeId,
    String status, {
    String? alasan,
  }) async => false;
  @override
  Future<void> searchStores({String? query, String? status}) async {}
  @override
  Future<void> fetchStoresByStatus(String status) async {}
  @override
  void clearError() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget makeTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StoreProvider>(
          create: (_) => MockStoreProvider(),
        ),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('ValidasiAkunTokoScreen Widget Test', () {
    testWidgets('Menampilkan judul AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const ValidasiAkunTokoScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Validasi Akun Toko Warga'), findsOneWidget);
    });

    testWidgets('Menampilkan filter bar dan tombol filter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        makeTestableWidget(const ValidasiAkunTokoScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    // testWidgets('Menampilkan indikator loading saat _isLoading true', (
    //   WidgetTester tester,
    // ) async {
    // });

    testWidgets('Menampilkan teks tidak ada data toko jika list kosong', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        makeTestableWidget(const ValidasiAkunTokoScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tidak ada data toko'), findsOneWidget);
    });
  });
}
