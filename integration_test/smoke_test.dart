import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mesh/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Smoke: app boots and shows primary tabs', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Let possible async init finish (e.g., settings load)
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify primary navigation labels are present
    expect(find.text('Devices'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);
  });
}
