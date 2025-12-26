import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:SapaWarga_kel_2/screens/warga/marketplace/tokoSaya/auth_store.dart';
import 'package:SapaWarga_kel_2/services/store_status_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      anonKey: 'dummy-anon-key',
    );
  });

  tearDown(() {
    // Reset mock setelah setiap test
    StoreStatusService.mockGetStoreStatus = null;
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: AuthStoreScreen(),
    );
  }

  group('AuthStoreScreen Widget Test', () {
    testWidgets(
      'Menampilkan loading dan teks status saat pengecekan toko',
      (tester) async {
        // Mock status normal
        StoreStatusService.mockGetStoreStatus = () async => 0;

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Memeriksa Status Toko'), findsOneWidget);
        expect(
          find.text('Memuat informasi toko Anda...'),
          findsOneWidget,
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Menampilkan pesan error saat gagal memuat data',
      (tester) async {
        // Mock error dari service
        StoreStatusService.mockGetStoreStatus = () async {
          throw Exception('Service error');
        };

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Gagal Memuat Data'), findsOneWidget);
        expect(
          find.textContaining(
            'Terjadi kesalahan saat memuat data toko Anda',
          ),
          findsOneWidget,
        );
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Coba Lagi'), findsOneWidget);
      },
    );
  });
}
