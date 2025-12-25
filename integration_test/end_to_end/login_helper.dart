import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper function to perform login for integration tests.
Future<void> login(WidgetTester tester, {
  String email = 'admin@gmail.com',
  String password = 'password',
}) async {
  // Step 1: Start the app and wait for it to settle.
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Check if already logged in
  if (tester.any(find.byKey(const Key('kegiatan_tab')))) {
    return;
  }

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
  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton);
  await tester.pumpAndSettle(const Duration(seconds: 8));

  // Verify that the login button is no longer on the screen,
  // indicating a successful navigation.
  expect(submitButton, findsNothing);
}
