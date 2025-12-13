import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jawara_pintar_kel_5/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Log Aktivitas Test',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // TODO: Add test logic here
    });
  });
}
