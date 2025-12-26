import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:SapaWarga_kel_2/screens/auth/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://dummy.supabase.co',
      anonKey: 'dummy-anon-key',
    );
  });
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Helper widget agar LoginScreen bisa dites
  Widget makeTestableWidget(Widget child) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const Scaffold(
            body: Text('Register Page'),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('LoginScreen Widget Test', () {
    testWidgets('Menampilkan tampilan awal LoginScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const LoginScreen()),
      );

      // Cek logo/banner
      expect(find.byKey(const Key('banner_image')), findsOneWidget);

      // Cek tombol Login awal
      expect(find.byKey(const Key('btn_show_login_form')), findsOneWidget);

      // Cek tombol Daftar
      expect(find.byKey(const Key('btn_to_register')), findsOneWidget);
    });

    testWidgets('Menampilkan form login saat tombol Login ditekan',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const LoginScreen()),
      );

      // Tekan tombol Login
      await tester.tap(find.byKey(const Key('btn_show_login_form')));
      await tester.pumpAndSettle(const Duration(milliseconds: 800));

      // Cek input email & password
      expect(find.byKey(const Key('input_email')), findsOneWidget);
      expect(find.byKey(const Key('input_password')), findsOneWidget);

      // Cek tombol submit login
      expect(find.byKey(const Key('btn_submit_login')), findsOneWidget);

      // Cek title Login
      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('Input email dan password dapat diisi',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const LoginScreen()),
      );

      // Buka form login
      await tester.tap(find.byKey(const Key('btn_show_login_form')));
      await tester.pumpAndSettle(const Duration(milliseconds: 800));

      // Isi email
      await tester.enterText(
        find.byKey(const Key('input_email')),
        'test@email.com',
      );

      // Isi password
      await tester.enterText(
        find.byKey(const Key('input_password')),
        'password123',
      );

      // Verifikasi text masuk
      expect(find.text('test@email.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
