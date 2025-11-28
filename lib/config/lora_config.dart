import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// LoRa related configuration and helpers.
///
/// UUIDs can be provided via an optional asset file: `assets/config/lora_services.json`
/// with structure: { "serviceUuids": ["uuid-1", "uuid-2", ...] }
/// If the asset isn't present, a safe default (Meshtastic UUID) is used.
class LoraConfig {
  static const String _assetPath = 'assets/config/lora_services.json';

  /// Default Meshtastic primary service UUID.
  static const String _defaultMeshtasticUuid =
      '6ba1b218-15a8-461f-9fa8-5dcae273eafd';

  static Set<String>? _normalizedServiceUuidSet; // cached, normalized

  /// Ensure the configuration is loaded once. Safe to call multiple times.
  static Future<void> ensureLoaded() async {
    if (_normalizedServiceUuidSet != null) return;
    try {
      final jsonStr = await rootBundle.loadString(_assetPath);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final list = (data['serviceUuids'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (list != null && list.isNotEmpty) {
        _normalizedServiceUuidSet = list.map(_norm).toSet();
        return;
      }
    } catch (_) {
      // Ignore missing asset or parse errors; fall back to default.
    }
    _normalizedServiceUuidSet = {_norm(_defaultMeshtasticUuid)};
  }

  /// Returns true if the provided scan result advertises any configured LoRa service UUID.
  static bool isLoraDevice(ScanResult r) {
    final set = _normalizedServiceUuidSet ?? {_norm(_defaultMeshtasticUuid)};
    // Check service UUIDs advertised
    for (final guid in r.advertisementData.serviceUuids) {
      if (set.contains(_norm(guid.str))) return true;
    }
    return false;
  }

  static String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-f0-9]'), '');
}

/// Convenience top-level forwarders.
Future<void> ensureLoraConfigLoaded() => LoraConfig.ensureLoaded();
bool isLoraDevice(ScanResult r) => LoraConfig.isLoraDevice(r);
