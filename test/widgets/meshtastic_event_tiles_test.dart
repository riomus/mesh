import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/l10n/app_localizations.dart';
import 'package:mesh/meshtastic/model/meshtastic_event.dart';
import 'package:mesh/meshtastic/model/meshtastic_models.dart';
import 'package:mesh/widgets/meshtastic_event_tiles.dart';

void main() {
  testWidgets('ConfigEvent tile shows correct subtitle for Device config', (
    WidgetTester tester,
  ) async {
    final config = ConfigDto(device: DeviceConfigDto(role: 'CLIENT'));
    final event = ConfigEvent(config);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: MeshtasticEventTile(event: event)),
      ),
    );

    expect(find.text('Device'), findsOneWidget);
  });

  testWidgets('ConfigEvent tile shows correct subtitle for LoRa config', (
    WidgetTester tester,
  ) async {
    final config = ConfigDto(lora: LoRaConfigDto(region: 'US'));
    final event = ConfigEvent(config);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: MeshtasticEventTile(event: event)),
      ),
    );

    expect(find.text('LoRa'), findsOneWidget);
  });

  testWidgets('ModuleConfigEvent tile shows correct subtitle for MQTT config', (
    WidgetTester tester,
  ) async {
    final config = ModuleConfigDto(mqtt: MqttConfigDto(enabled: true));
    final event = ModuleConfigEvent(config);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: MeshtasticEventTile(event: event)),
      ),
    );

    expect(find.text('MQTT'), findsOneWidget);
  });

  testWidgets(
    'ModuleConfigEvent tile shows correct subtitle for Telemetry config',
    (WidgetTester tester) async {
      final config = ModuleConfigDto(
        telemetry: TelemetryConfigDto(deviceUpdateInterval: 60),
      );
      final event = ModuleConfigEvent(config);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MeshtasticEventTile(event: event)),
        ),
      );

      expect(find.text('Telemetry'), findsOneWidget);
    },
  );
}
