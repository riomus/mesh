import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mesh/app.dart';
import 'package:mesh/pages/settings_page.dart';
import 'package:mesh/services/device_status_store.dart';
import 'package:mesh/services/recent_devices_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simulation Integration Tests', () {
    setUp(() async {
      // Clear any persisted state to ensure a clean slate
      SharedPreferences.setMockInitialValues({});
      await RecentDevicesService.instance.clear();
      await DeviceStatusStore.instance.disposeAll();
    });

    testWidgets('Simulator Connection Test', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 1. Navigate to "Sim" tab
      // The Sim tab should be present if ENABLE_SIMULATION is true
      final simTab = find.text('Sim');
      expect(simTab, findsOneWidget, reason: 'Sim tab should be visible');
      await tester.tap(simTab);
      await tester.pumpAndSettle();

      // 2. Click "Start Simulation"
      final startButton = find.text('Start Simulation');
      expect(startButton, findsOneWidget);
      await tester.ensureVisible(startButton);
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // 3. Verify connection success
      // Check for SnackBar
      // Use a more flexible finder or wait explicitly
      await tester.pump(
        const Duration(milliseconds: 500),
      ); // Wait for snackbar animation

      final snackBarFinder = find.byType(SnackBar);
      if (snackBarFinder.evaluate().isNotEmpty) {
        final snackBarText = find.descendant(
          of: snackBarFinder,
          matching: find.byType(Text),
        );
        if (snackBarText.evaluate().isNotEmpty) {
          final textWidget = snackBarText.evaluate().first.widget as Text;
          print('SnackBar found with text: ${textWidget.data}');
        }
      }

      expect(find.text('Connected to Simulation Device'), findsOneWidget);

      // 4. Verify "Simulation Device" appears in the device list (BLE tab)
      await tester.tap(find.text('BLE'));
      await tester.pumpAndSettle();
      expect(find.text('Simulation Device'), findsOneWidget);
    });

    testWidgets('Chat Functionality Test', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Connect to simulator first
      await tester.tap(find.text('Sim'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Simulation'));
      await tester.pumpAndSettle();

      // Go to BLE tab and tap the device to open it
      await tester.tap(find.text('BLE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simulation Device'));
      await tester.pumpAndSettle();

      // 4. Navigate to Chat page (it's an icon button, not a tab)
      final chatButton = find.byIcon(Icons.chat);
      await tester.ensureVisible(chatButton);
      await tester.tap(chatButton);
      await tester.pumpAndSettle();

      // 5. Send a message
      // Note: ScannerPage also has a TextField (search), so we must be specific.
      // We look for the TextField inside the ChatWidget.
      // ChatWidget is not exported in the test, but we can find by type if we import it or just use a descendant of the scaffold/appbar title 'Chat' or similar.
      // Better: find by hint text if possible, or just use the last one (top of stack).
      // Let's use find.descendant of the visible page.
      final textField = find.byType(TextField).last;
      await tester.enterText(textField, 'Hello Simulation!');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      // 6. Verify message appears
      expect(find.text('Hello Simulation!'), findsOneWidget);
    });

    testWidgets('Settings Interaction Test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 1. Open Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify we are in settings
      expect(find.byType(SettingsPage), findsOneWidget);

      // Check for content (Security icon)
      final securityIcon = find.byIcon(Icons.security);
      if (securityIcon.evaluate().isEmpty) {
        debugDumpApp();
      }
      expect(securityIcon, findsOneWidget);

      // 2. Toggle a setting (e.g. Theme)
      // Note: Theme toggle is in AppBar in SettingsPage too
      final themeButton = find.byIcon(Icons.light_mode).evaluate().isNotEmpty
          ? find.byIcon(Icons.light_mode)
          : find.byIcon(Icons.dark_mode);

      await tester.tap(themeButton.first);
      await tester.pumpAndSettle();

      // We verified interaction, that's enough.
    });
  });
}
