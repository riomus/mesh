import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/widgets/rssi_bar.dart';
import 'package:mesh/l10n/app_localizations.dart';

void main() {
  testWidgets('RssiBar renders correctly in ListTile trailing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListView(
            children: const [
              ListTile(title: Text('Test Event'), trailing: RssiBar(rssi: -70)),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(RssiBar), findsOneWidget);
  });
}
