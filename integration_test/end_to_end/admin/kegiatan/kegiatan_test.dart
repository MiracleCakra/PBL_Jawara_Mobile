import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:SapaWarga_kel_2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Kegiatan Test',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // TODO: Add test logic here
    });
  });
}
