import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SapaWarga_kel_2/screens/auth/register.dart';

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

  /// Helper router
  Widget makeTestableWidget(Widget child) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('Login Page')),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('RegisterScreen Widget Test', () {
    testWidgets('RegisterScreen dapat dirender',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const RegisterScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Daftar'), findsWidgets);
      expect(find.byKey(const Key('scroll_view_register')), findsOneWidget);
    });

    testWidgets('Field data diri utama tampil',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const RegisterScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('input_nama_lengkap')), findsOneWidget);
      expect(find.byKey(const Key('input_nik')), findsOneWidget);
      expect(find.byKey(const Key('input_phone')), findsOneWidget);
    });

    testWidgets('Field akun tampil',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const RegisterScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('input_email_reg')), findsOneWidget);
      expect(find.byKey(const Key('input_password_reg')), findsOneWidget);
      expect(find.byKey(const Key('input_confirm_password')), findsOneWidget);
    });

    testWidgets('Area upload foto dan tombol daftar tampil',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const RegisterScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('area_upload_foto')), findsOneWidget);
      expect(find.byKey(const Key('btn_submit_register')), findsOneWidget);
    });

    testWidgets('Tombol back mengarah ke login',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const RegisterScreen()),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_back_nav')));
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
