// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/app.dart';
import 'package:mesh/services/notification_provider.dart';
import 'package:mesh/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationProvider implements NotificationProvider {
  @override
  Future<void> init() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> showNotification(
    int id,
    String title,
    String body,
    String? payload,
  ) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test: renders main tabs', (tester) async {
    // Provide empty initial values for SharedPreferences used by SettingsService
    SharedPreferences.setMockInitialValues({});

    NotificationService.instance.setProviderForTesting(
      MockNotificationProvider(),
    );

    await tester.pumpWidget(const MyApp());
    // Allow async work to complete
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Expect to find our bottom navigation destinations
    expect(find.text('Devices'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);
  });
}
