import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/widgets/chat_widget.dart';
import 'package:mesh/l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks if needed, but for now we can just use a fake device
// or rely on the fact that we can pass a device.
// However, ChatWidget uses DeviceCommunicationEventService singleton and DeviceStatusStore singleton.
// This makes it hard to test without mocking those singletons or their dependencies.
// For a simple widget test, we might just test the UI rendering and character count logic
// if we can bypass the service calls or if they are lazy.
// The service calls happen in initState (_subscribeToEvents).
// We might need to mock the services.

// Since I cannot easily change the singletons to be injectable without refactoring,
// I will try to test the UI parts that don't crash.
// Or I can skip the test if it's too complex for this iteration, but the user asked for tests.
// I'll try to create a basic test.

import 'package:mesh/services/message_sender.dart';

class MockMessageSender extends Mock implements MessageSender {
  @override
  Future<void> sendMessage(String content) async {}
}

void main() {
  testWidgets('ChatWidget renders input and button', (
    WidgetTester tester,
  ) async {
    // We need to provide AppLocalizations
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ChatWidget(roomId: 'test_room')),
      ),
    );

    // Verify input field is present
    expect(find.byType(TextField), findsOneWidget);

    // Verify send button is present
    expect(find.byIcon(Icons.send), findsOneWidget);

    // Verify character count is 0/200
    expect(find.text('0/200'), findsOneWidget);

    // Enter text
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pump();

    // Verify character count updates
    expect(find.text('5/200'), findsOneWidget);
  });
}
