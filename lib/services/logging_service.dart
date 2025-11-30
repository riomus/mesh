import 'dart:async';

/// Immutable log event with timestamp, structured tags, level and message.
class LogEvent {
  final DateTime timestamp;
  /// Structured tags for this event.
  /// Example: {'network': ['meshtastic'], 'deviceId': ['ABC123']}
  final Map<String, List<String>> tags;
  final String level;
  final String message;

  const LogEvent({
    required this.timestamp,
    required this.tags,
    required this.level,
    required this.message,
  });

  @override
  String toString() {
    if (tags.isEmpty) {
      return 'LogEvent(time: ' + timestamp.toIso8601String() + ', tags: (no-tags), level: ' + level + ', message: ' + message + ')';
    }
    final keys = tags.keys.toList()..sort();
    final parts = <String>[];
    for (final k in keys) {
      final vs = List<String>.from(tags[k] ?? const <String>[])..sort();
      if (vs.isEmpty) continue;
      final vStr = vs.length == 1 ? vs.first : '[' + vs.join(', ') + ']';
      parts.add('$k=$vStr');
    }
    return 'LogEvent(time: ' + timestamp.toIso8601String() + ', tags: ' + parts.join(' • ') + ', level: ' + level + ', message: ' + message + ')';
  }
}

/// Simple pub/sub logging service.
///
/// - Push logs via structured [tags], [level], and [message].
/// - Listen to all logs or filter by [level], by tag [key] and [value], by [allEquals],
///   by [keyAnyOf], or by free text / [pattern] optionally scoped to a key.
class LoggingService {
  LoggingService._();

  static final LoggingService instance = LoggingService._();

  final StreamController<LogEvent> _controller =
      StreamController<LogEvent>.broadcast();

  /// Push a log entry.
  ///
  /// Required: [level], [message]. Optional: [tags], [timestamp].
  /// Inputs are normalized: keys/values are trimmed; empty keys/values dropped; values deduped and sorted.
  void push({
    Map<String, Object?>? tags,
    required String level,
    required String message,
    DateTime? timestamp,
  }) {
    final normalizedTags = _normalizeTags(tags);

    final evt = LogEvent(
      timestamp: timestamp ?? DateTime.now(),
      tags: normalizedTags,
      level: level.trim(),
      message: message,
    );
    _controller.add(evt);
  }

  /// Stream all log events.
  Stream<LogEvent> listenAll() => _controller.stream;

  /// Stream of log events filtered by optional fields.
  ///
  /// - [level]: exact level match (e.g., 'info').
  /// - [key]: require that key exists; if [value] provided, require that tags[key] contains [value].
  /// - [allEquals]: require that each key has the exact value (AND across entries).
  /// - [keyAnyOf]: for each key, require any of listed values (OR within, AND across keys).
  /// - [containsText]: substring match across values (or only values of [keyForText] if set).
  /// - [pattern]: regex/pattern match across values (or only values of [keyForPattern] if set).
  ///
  /// Passing `null` means wildcard (no filtering by that field).
  Stream<LogEvent> listen({
    String? level,
    String? key,
    String? value,
    Map<String, String>? allEquals,
    Map<String, List<String>>? keyAnyOf,
    String? containsText,
    String? keyForText,
    Pattern? pattern,
    String? keyForPattern,
    bool caseSensitive = false,
  }) {
    Stream<LogEvent> s = _controller.stream;
    if (level != null) {
      s = s.where((e) => e.level == level);
    }
    if (allEquals != null && allEquals.isNotEmpty) {
      s = s.where((e) => _matchAllEquals(e.tags, allEquals));
    }
    if (key != null) {
      s = s.where((e) => e.tags.containsKey(key));
      if (value != null) {
        s = s.where((e) => (e.tags[key] ?? const <String>[]).contains(value));
      }
    }
    if (keyAnyOf != null && keyAnyOf.isNotEmpty) {
      s = s.where((e) => _matchKeyAnyOf(e.tags, keyAnyOf));
    }
    if ((containsText != null && containsText.isNotEmpty) || pattern != null) {
      s = s.where((e) => _matchTextOrPattern(
            e.tags,
            containsText: containsText,
            keyForText: keyForText,
            pattern: pattern,
            keyForPattern: keyForPattern,
            caseSensitive: caseSensitive,
          ));
    }
    return s;
  }

  /// Close the underlying stream controller. Typically not needed for apps.
  Future<void> dispose() => _controller.close();

  // ---- Helpers ----

  static Map<String, List<String>> _normalizeTags(Map<String, Object?>? input) {
    if (input == null || input.isEmpty) return const <String, List<String>>{};
    final Map<String, Set<String>> tmp = {};
    input.forEach((rawKey, rawVal) {
      final k = rawKey.trim();
      if (k.isEmpty) return;
      if (rawVal == null) return;
      Iterable<String> values;
      if (rawVal is String) {
        values = [rawVal];
      } else if (rawVal is Iterable) {
        values = rawVal.whereType<Object>().map((e) => e.toString());
      } else {
        values = [rawVal.toString()];
      }
      for (final v in values) {
        final vv = v.trim();
        if (vv.isEmpty) continue;
        (tmp[k] ??= <String>{}).add(vv);
      }
    });
    final out = <String, List<String>>{};
    tmp.forEach((k, set) {
      if (set.isEmpty) return;
      final list = set.toList()..sort();
      out[k] = list;
    });
    return out;
  }

  static bool _matchAllEquals(
      Map<String, List<String>> tags, Map<String, String> allEquals) {
    for (final entry in allEquals.entries) {
      final values = tags[entry.key];
      if (values == null || !values.contains(entry.value)) return false;
    }
    return true;
  }

  static bool _matchKeyAnyOf(
      Map<String, List<String>> tags, Map<String, List<String>> keyAnyOf) {
    for (final entry in keyAnyOf.entries) {
      final key = entry.key;
      final requiredAny = entry.value;
      if (requiredAny.isEmpty) return false;
      final values = tags[key];
      if (values == null) return false;
      bool ok = false;
      for (final v in requiredAny) {
        if (values.contains(v)) {
          ok = true;
          break;
        }
      }
      if (!ok) return false;
    }
    return true;
  }

  static bool _matchTextOrPattern(
    Map<String, List<String>> tags, {
    String? containsText,
    String? keyForText,
    Pattern? pattern,
    String? keyForPattern,
    bool caseSensitive = false,
  }) {
    Iterable<String> valuesForSearch() {
      if (keyForText != null || keyForPattern != null) {
        final key = keyForText ?? keyForPattern!;
        return tags[key] ?? const <String>[];
      }
      return tags.values.expand((e) => e);
    }

    final values = valuesForSearch();
    if (pattern != null) {
      final regExp = pattern is RegExp
          ? pattern
          : RegExp(pattern.toString(), caseSensitive: caseSensitive);
      for (final v in values) {
        if (regExp.hasMatch(v)) return true;
      }
      return false;
    }
    if (containsText != null && containsText.isNotEmpty) {
      if (caseSensitive) {
        for (final v in values) {
          if (v.contains(containsText)) return true;
        }
      } else {
        final needle = containsText.toLowerCase();
        for (final v in values) {
          if (v.toLowerCase().contains(needle)) return true;
        }
      }
      return false;
    }
    return true;
  }
}
