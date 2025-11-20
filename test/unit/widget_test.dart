import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:jawara_pintar_kel_5/main.dart';

// Fake HttpClient supaya Supabase tidak membuat request asli
class _FakeHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(Stream.empty(), 200);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock shared_preferences
    SharedPreferences.setMockInitialValues({});

    // Mock Supabase
    await Supabase.initialize(
      url: 'http://localhost:8000', // dummy
      anonKey: 'dummy',            // dummy
      httpClient: _FakeHttpClient(),
    );
  });

  testWidgets("App can load MyApp widget", (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
