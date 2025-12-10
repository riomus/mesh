import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/widgets/device_state_widget.dart';
import 'package:mesh/models/device_state.dart';
import 'package:mesh/meshtastic/model/meshtastic_models.dart';
import 'package:mesh/meshtastic/model/device_type.dart';
import 'package:mesh/l10n/app_localizations.dart';

void main() {
  const deviceId = 'TEST_DEVICE_ID';
  final defaultState = DeviceState(deviceId: deviceId);

  Future<void> pumpWidget(
    WidgetTester tester,
    DeviceState state, {
    DeviceType? deviceType,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: DeviceStateWidget(
              state: state,
              deviceId: deviceId,
              deviceTypeOverride: deviceType,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('DeviceStateWidget shows all configs for Meshtastic device', (
    WidgetTester tester,
  ) async {
    final configState = defaultState.copyWith(
      config: const ConfigDto(device: DeviceConfigDto(role: 'ROUTER')),
    );

    await pumpWidget(tester, configState, deviceType: DeviceType.meshtastic);
    await tester.pump();

    expect(find.text('Device Config'), findsOneWidget);
    expect(find.text('Position Config'), findsOneWidget);
  });

  testWidgets('DeviceStateWidget hides configs for MeshCore device', (
    WidgetTester tester,
  ) async {
    final configState = defaultState.copyWith(
      config: const ConfigDto(device: DeviceConfigDto(role: 'ROUTER')),
    );

    await pumpWidget(tester, configState, deviceType: DeviceType.meshcore);
    await tester.pump();

    // Verify sections are hidden (except LoRa)
    expect(find.text('Device Config'), findsNothing);
    expect(find.text('Position Config'), findsNothing);
    expect(find.text('Power Config'), findsNothing);
    expect(find.text('Network Config'), findsNothing);
    expect(find.text('Display Config'), findsNothing);
    // expect(find.text('LoRa Config'), findsNothing); // Now visible
    expect(find.text('Bluetooth Config'), findsNothing);
    expect(find.text('Security Config'), findsNothing);

    // Verify Module Configs are hidden
    expect(find.text('MQTT Config'), findsNothing);
  });

  testWidgets('DeviceStateWidget shows LoRa config for MeshCore device', (
    WidgetTester tester,
  ) async {
    final loraConfig = LoRaConfigDto(
      overrideFrequency: 915.0,
      bandwidth: 250,
      spreadFactor: 11,
      codingRate: 5,
      txPower: 20,
    );
    final configState = defaultState.copyWith(
      config: ConfigDto(lora: loraConfig),
    );

    await pumpWidget(tester, configState, deviceType: DeviceType.meshcore);
    await tester.pump();

    // Verify LoRa section is present and expanded
    // Note: _Section isn't expanded by default usually, unless maybe it's the only one?
    // Let's scroll to it and tap if needed, or just find the header title.
    final loraHeader = find.text('LoRa Config');
    expect(loraHeader, findsOneWidget);

    await tester.ensureVisible(loraHeader);
    await tester.tap(loraHeader);
    await tester.pumpAndSettle();

    // Verify values
    expect(find.text('915.000 MHz'), findsOneWidget);
    expect(find.text('250 kHz'), findsOneWidget);
    expect(find.text('11'), findsOneWidget); // SF
    expect(find.text('4/5'), findsOneWidget); // CR
    expect(find.text('20 dBm'), findsOneWidget);
  });
}
