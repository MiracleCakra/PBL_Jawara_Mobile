import 'package:SapaWarga_kel_2/screens/warga/marketplace/belanja/riview_produk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      anonKey: 'dummy',
    );
  });
  group('ProductReviewScreen Widget Test', () {
    Widget createWidgetUnderTest() {
      return const MaterialApp(home: ProductReviewScreen(productId: 'p1'));
    }

    testWidgets('Menampilkan judul dan jumlah ulasan', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Semua Ulasan Produk'), findsOneWidget);
      expect(find.textContaining('Total 4 Ulasan'), findsOneWidget);
    });

    testWidgets('Menampilkan ringkasan rating dan rating rata-rata', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('4.4'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('Menampilkan semua review dummy', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Lala S.'), findsOneWidget);
      expect(find.text('Budi J.'), findsOneWidget);
      expect(find.text('Santi P.'), findsOneWidget);
      expect(find.text('Rahmat H.'), findsOneWidget);
      expect(find.textContaining('Tomatnya Grade A banget!'), findsOneWidget);
      expect(find.textContaining('Wortel agak layu'), findsOneWidget);
    });

    testWidgets('Tombol Tulis Ulasan muncul dan membuka form', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();
      expect(find.text('Tulis Ulasan Anda'), findsOneWidget);
      expect(find.text('Kirim Ulasan'), findsOneWidget);
    });

    testWidgets('Validasi form ulasan: rating dan komentar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Submit tanpa apa-apa → validasi rating
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pumpAndSettle();
      expect(find.text('Berikan rating.'), findsOneWidget);

      // Tap bintang
      await tester.tap(find.byIcon(Icons.star_border).first);
      await tester.pumpAndSettle(
        const Duration(seconds: 2),
      );

      // Isi komentar pendek
      await tester.enterText(find.byType(TextField), 'Pendek');
      await tester.pumpAndSettle();

      // Submit lagi
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pumpAndSettle();

      expect(find.text('Komentar minimal 10 karakter.'), findsOneWidget);
    });
  });
}
