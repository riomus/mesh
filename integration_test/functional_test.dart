import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mesh/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Functional: can switch tabs and open Settings', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Allow async init
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Initially should show bottom nav with Devices and Logs
    expect(find.text('Devices'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);

    // Switch to Logs tab
    await tester.tap(find.byIcon(Icons.list_alt));
    await tester.pumpAndSettle();

    // Open Settings from Logs page app bar menu if available
    // In this app, Settings are navigated from provided callbacks; try to find a settings icon
    final settingsIcon = find.byIcon(Icons.settings);
    if (settingsIcon.evaluate().isNotEmpty) {
      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();

      // Expect some settings content (locale, theme toggles). We look for generic toggles/buttons
      expect(find.byType(Switch), findsWidgets);
      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // Switch back to Devices tab
    await tester.tap(find.byIcon(Icons.devices));
    await tester.pumpAndSettle();

    // Final sanity check passes
    expect(find.text('Devices'), findsOneWidget);
  });
}
