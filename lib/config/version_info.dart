import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

class VersionInfo {
  final String name; // semver tag, e.g., 0.0.1
  final int number; // commits since tag (>=1)
  final String describe; // git describe string
  final DateTime? buildTimeUtc;

  VersionInfo({
    required this.name,
    required this.number,
    required this.describe,
    required this.buildTimeUtc,
  });

  static VersionInfo? _instance;

  static VersionInfo? get instance => _instance;

  static Future<void> ensureLoaded() async {
    if (_instance != null) return;
    try {
      final text = await rootBundle.loadString('assets/data/version.yaml');
      final data = loadYaml(text);
      if (data is YamlMap) {
        final v = (data['version'] is YamlMap) ? data['version'] as YamlMap : data;
        final name = (v['name'] ?? '').toString();
        final numberRaw = v['number'];
        final number = numberRaw is int
            ? numberRaw
            : int.tryParse(numberRaw?.toString() ?? '') ?? 1;
        final describe = (v['describe'] ?? '').toString();
        final buildTimeStr = (v['build_time_utc'] ?? '').toString();
        DateTime? buildTime;
        if (buildTimeStr.isNotEmpty) {
          try {
            buildTime = DateTime.parse(buildTimeStr).toUtc();
          } catch (_) {
            buildTime = null;
          }
        }
        _instance = VersionInfo(
          name: name,
          number: number,
          describe: describe,
          buildTimeUtc: buildTime,
        );
      }
    } catch (_) {
      // Silently ignore if asset is missing (e.g., during local dev before script runs)
    }
  }

  /// A compact display string, e.g. `0.0.1-3-gabc1234`.
  String get displayDescribe => describe.isNotEmpty ? describe : '$name+$number';
}
