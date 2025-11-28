import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart' as yaml;

/// Lightweight database of Bluetooth SIG Company Identifiers.
///
/// Source: Bundled asset `assets/data/company_identifiers.yaml` (snapshot of
/// Bluetooth SIG company identifiers). Falls back to a small built-in map if
/// the asset is unavailable or fails to parse.
class ManufacturerDb {
  ManufacturerDb._();

  static Map<int, String>? _remote; // Loaded from YAML
  static Future<void>? _loading;

  // Commonly encountered IDs as a built-in fallback.
  // NOTE: This is not exhaustive. Prefer using [ensureLoaded] to fetch the full list.
  static const Map<int, String> _builtIn = {
    0x0002: 'Intel Corporation',
    0x0006: 'Microsoft',
    0x000A: 'Sony Corporation',
    0x000D: 'Texas Instruments Inc.',
    0x004C: 'Apple, Inc.',
    0x0059: 'Nordic Semiconductor ASA',
    0x0075: 'Samsung Electronics Co. Ltd.',
    0x00AF: 'Garmin International, Inc.',
    0x00E0: 'Google',
    0x00F7: 'Bose Corporation',
    0x0157: 'Xiaomi Inc.',
    0x016D: 'Fitbit, Inc.',
  };

  /// Triggers background loading of the remote YAML mapping if not already loaded.
  static Future<void> ensureLoaded() {
    if (_remote != null) return Future.value();
    if (_loading != null) return _loading!;

    _loading = _loadFromAsset().catchError((_) {}) // swallow errors; keep fallbacks
        .whenComplete(() => _loading = null);
    return _loading!;
  }

  /// Synchronous lookup using loaded remote map if available, otherwise built-in.
  static String? nameNow(int id) {
    final map = _remote ?? _builtIn;
    return map[id];
  }

  /// Asynchronous lookup that will attempt to ensure remote data is loaded first.
  static Future<String?> name(int id) async {
    if (_remote == null) {
      await ensureLoaded();
    }
    return nameNow(id);
  }

  static Future<void> _loadFromAsset() async {
    // The asset path is registered in pubspec.yaml
    final content = await rootBundle.loadString(
      'assets/data/company_identifiers.yaml',
      cache: true,
    );
    final doc = yaml.loadYaml(content);
    if (doc is! yaml.YamlMap) return;

    // The YAML structure is a list under the key 'company_identifiers' in most snapshots.
    // Handle both direct list and nested map forms defensively.
    final dynamic listNode = doc['company_identifiers'] ?? doc;
    final Map<int, String> parsed = {};

    if (listNode is yaml.YamlList) {
      for (final item in listNode) {
        if (item is yaml.YamlMap) {
          final id = item['value'] ?? item['code'] ?? item['company_id'];
          final name = item['name'] ?? item['company'] ?? item['company_name'];
          if (name is String) {
            final idNum = _parseId(id);
            if (idNum != null) parsed[idNum] = name;
          }
        }
      }
    } else if (listNode is yaml.YamlMap) {
      // Sometimes mapping from id->name directly
      for (final entry in listNode.entries) {
        final idNum = _parseId(entry.key);
        final name = entry.value;
        if (idNum != null && name is String) parsed[idNum] = name;
      }
    }

    if (parsed.isNotEmpty) {
      _remote = parsed;
    }
  }

  static int? _parseId(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) {
      final s = v.trim();
      try {
        if (s.startsWith('0x') || s.startsWith('0X')) {
          return int.parse(s.substring(2), radix: 16);
        }
        return int.parse(s);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
