import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/meshtastic/config_resources.dart';

void main() {
  group('ConfigResources', () {
    test('all config descriptions have valid links', () {
      for (final key in ConfigResources.descriptions.keys) {
        final description = ConfigResources.descriptions[key]!;
        expect(
          description.description,
          isNotEmpty,
          reason: 'Description for $key should not be empty',
        );
        expect(
          description.link,
          startsWith('https://meshtastic.org'),
          reason: 'Link for $key should start with https://meshtastic.org',
        );
      }
    });

    test('contains keys for all major config sections', () {
      final keys = ConfigResources.descriptions.keys.toList();

      // Device Config
      expect(keys.any((k) => k.startsWith('device.')), isTrue);

      // Position Config
      expect(keys.any((k) => k.startsWith('position.')), isTrue);

      // Power Config
      expect(keys.any((k) => k.startsWith('power.')), isTrue);

      // Network Config
      expect(keys.any((k) => k.startsWith('network.')), isTrue);

      // Display Config
      expect(keys.any((k) => k.startsWith('display.')), isTrue);

      // LoRa Config
      expect(keys.any((k) => k.startsWith('lora.')), isTrue);

      // Bluetooth Config
      expect(keys.any((k) => k.startsWith('bluetooth.')), isTrue);

      // Security Config
      expect(keys.any((k) => k.startsWith('security.')), isTrue);

      // MQTT Config
      expect(keys.any((k) => k.startsWith('mqtt.')), isTrue);

      // Telemetry Config
      expect(keys.any((k) => k.startsWith('telemetry.')), isTrue);

      // Serial Config
      expect(keys.any((k) => k.startsWith('serial.')), isTrue);
    });
  });
}
