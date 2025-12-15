import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:SapaWarga_kel_2/main.dart' as app;

/// Helper function to perform login for integration tests.
/// 
/// This function will:
/// 1. Start the app.
/// 2. Navigate to the login form.
/// 3. Enter the provided email and password.
/// 4. Submit the form.
/// 5. Wait for the app to settle after login.
Future<void> login(WidgetTester tester, {
  String email = 'admin@gmail.com',
  String password = 'password',
}) async {
  // Step 1: Start the app and wait for it to settle.
  app.main();
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Step 2: Find and tap the button to show the login form.
  final btnShowForm = find.byKey(const Key('btn_show_login_form'));
  expect(btnShowForm, findsOneWidget);
  await tester.tap(btnShowForm);
  await tester.pumpAndSettle(const Duration(seconds: 1));

  // Step 3: Find the form fields.
  final emailField = find.byKey(const Key('input_email'));
  final passwordField = find.byKey(const Key('input_password'));
  final submitButton = find.byKey(const Key('btn_submit_login'));

  // Verify form elements are visible
  expect(emailField, findsOneWidget);
  expect(passwordField, findsOneWidget);
  expect(submitButton, findsOneWidget);

  // Step 4: Enter credentials.
  await tester.enterText(emailField, email);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.enterText(passwordField, password);
  await tester.pump(const Duration(milliseconds: 100));

  // Step 5: Tap the submit button and wait for navigation.
  await tester.tap(submitButton);
  await tester.pumpAndSettle(const Duration(seconds: 4));

  // Verify that the login button is no longer on the screen,
  // indicating a successful navigation.
  expect(submitButton, findsNothing);
}
