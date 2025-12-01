import 'dart:async';

/// Domain-agnostic device communication event (for now primarily Meshtastic).
class DeviceEvent {
  final DateTime timestamp;
  /// Structured tags (e.g., {'network': ['meshtastic'], 'deviceId': ['ABC']}).
  final Map<String, List<String>> tags;
  /// Optional human-friendly summary.
  final String? summary;
  /// Arbitrary structured payload for the event (e.g., decoded DTOs, maps).
  final Object? payload;

  const DeviceEvent({
    required this.timestamp,
    required this.tags,
    this.summary,
    this.payload,
  });

  @override
  String toString() =>
      'DeviceEvent(time: ${timestamp.toIso8601String()}, tags: $tags, summary: $summary)';
}

/// Service for collecting and subscribing to device communication events.
///
/// API mirrors LoggingService to keep a consistent developer experience.
class DeviceCommunicationEventService {
  DeviceCommunicationEventService._();

  static final DeviceCommunicationEventService instance =
      DeviceCommunicationEventService._();

  final StreamController<DeviceEvent> _controller =
      StreamController<DeviceEvent>.broadcast();

  final List<DeviceEvent> _buffer = <DeviceEvent>[];
  int _bufferCapacity = 1000;

  set bufferCapacity(int value) {
    if (value < 1) value = 1;
    _bufferCapacity = value;
    // Trim if needed
    final overflow = _buffer.length - _bufferCapacity;
    if (overflow > 0) {
      _buffer.removeRange(0, overflow);
    }
  }

  int get bufferCapacity => _bufferCapacity;

  /// Push a new device event. Tags are normalized similarly to LoggingService.
  void push({
    Map<String, Object?>? tags,
    String? summary,
    Object? payload,
    DateTime? timestamp,
  }) {
    final normalizedTags = _normalizeTags(tags);
    final evt = DeviceEvent(
      timestamp: timestamp ?? DateTime.now(),
      tags: normalizedTags,
      summary: summary,
      payload: payload,
    );
    _controller.add(evt);
    _buffer.add(evt);
    final overflow = _buffer.length - _bufferCapacity;
    if (overflow > 0) {
      _buffer.removeRange(0, overflow);
    }
  }

  /// Stream all events.
  Stream<DeviceEvent> listenAll() => _controller.stream;

  /// Stream of events filtered by optional fields.
  ///
  /// - [key]: require that key exists; if [value] provided, require that tags[key] contains [value].
  /// - [allEquals]: require that each key has the exact value (AND across entries).
  /// - [keyAnyOf]: for each key, require any of listed values (OR within, AND across keys).
  /// - [containsText]: substring match across values (or only values of [keyForText] if set).
  /// - [pattern]: regex/pattern match across values (or only values of [keyForPattern] if set).
  Stream<DeviceEvent> listen({
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
    Stream<DeviceEvent> s = _controller.stream;
    if (allEquals != null && allEquals.isNotEmpty) {
      s = s.where((e) => _matchAllEquals(e.tags, allEquals));
    }
    if (key != null) {
      if (value == null) {
        s = s.where((e) => (e.tags[key] ?? const <String>[]).isNotEmpty);
      } else {
        s = s.where((e) => (e.tags[key] ?? const <String>[]).contains(value));
      }
    }
    if (keyAnyOf != null && keyAnyOf.isNotEmpty) {
      s = s.where((e) => _matchKeyAnyOf(e.tags, keyAnyOf));
    }
    if (containsText != null && containsText.isNotEmpty) {
      final needle = caseSensitive ? containsText : containsText.toLowerCase();
      s = s.where((e) {
        final subset = keyForText != null ? {keyForText: e.tags[keyForText] ?? const <String>[]} : e.tags;
        return subset.values.any((vs) => vs.any((v) {
              final hay = caseSensitive ? v : v.toLowerCase();
              return hay.contains(needle);
            }));
      });
    }
    if (pattern != null) {
      s = s.where((e) {
        final subset = keyForPattern != null ? {keyForPattern: e.tags[keyForPattern] ?? const <String>[]} : e.tags;
        return subset.values.any((vs) => vs.any((v) => pattern.matchAsPrefix(v) != null || RegExp(pattern.toString()).hasMatch(v)));
      });
    }
    return s;
  }

  /// Returns a stream that first replays buffered events matching the filters,
  /// then continues with live events.
  Stream<DeviceEvent> listenWithReplay({
    String? key,
    String? value,
    Map<String, String>? allEquals,
    Map<String, List<String>>? keyAnyOf,
    String? containsText,
    String? keyForText,
    Pattern? pattern,
    String? keyForPattern,
    bool caseSensitive = false,
  }) async* {
    final filtered = _applyFilters(
      _buffer,
      key: key,
      value: value,
      allEquals: allEquals,
      keyAnyOf: keyAnyOf,
      containsText: containsText,
      keyForText: keyForText,
      pattern: pattern,
      keyForPattern: keyForPattern,
      caseSensitive: caseSensitive,
    );
    for (final e in filtered) {
      yield e;
    }
    yield* listen(
      key: key,
      value: value,
      allEquals: allEquals,
      keyAnyOf: keyAnyOf,
      containsText: containsText,
      keyForText: keyForText,
      pattern: pattern,
      keyForPattern: keyForPattern,
      caseSensitive: caseSensitive,
    );
  }

  /// Clear the replay buffer.
  void clear() => _buffer.clear();

  List<DeviceEvent> _applyFilters(
    List<DeviceEvent> items, {
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
    return items.where((e) {
      if (allEquals != null && allEquals.isNotEmpty && !_matchAllEquals(e.tags, allEquals)) {
        return false;
      }
      if (key != null) {
        if (value == null) {
          if ((e.tags[key] ?? const <String>[]).isEmpty) return false;
        } else {
          if (!(e.tags[key] ?? const <String>[]).contains(value)) return false;
        }
      }
      if (keyAnyOf != null && keyAnyOf.isNotEmpty && !_matchKeyAnyOf(e.tags, keyAnyOf)) {
        return false;
      }
      if (containsText != null && containsText.isNotEmpty) {
        final needle = caseSensitive ? containsText : containsText.toLowerCase();
        final subset = keyForText != null ? {keyForText: e.tags[keyForText] ?? const <String>[]} : e.tags;
        final ok = subset.values.any((vs) => vs.any((v) {
              final hay = caseSensitive ? v : v.toLowerCase();
              return hay.contains(needle);
            }));
        if (!ok) return false;
      }
      if (pattern != null) {
        final subset = keyForPattern != null ? {keyForPattern: e.tags[keyForPattern] ?? const <String>[]} : e.tags;
        final ok = subset.values.any((vs) => vs.any((v) => pattern.matchAsPrefix(v) != null || RegExp(pattern.toString()).hasMatch(v)));
        if (!ok) return false;
      }
      return true;
    }).toList(growable: false);
  }

  Map<String, List<String>> _normalizeTags(Map<String, Object?>? raw) {
    if (raw == null || raw.isEmpty) return <String, List<String>>{};
    final out = <String, List<String>>{};
    for (final entry in raw.entries) {
      final k = (entry.key).trim();
      if (k.isEmpty) continue;
      final v = entry.value;
      if (v == null) continue;
      Iterable<String> vals;
      if (v is String) {
        vals = [v];
      } else if (v is Iterable) {
        vals = v.whereType<Object>().map((e) => e.toString());
      } else {
        vals = [v.toString()];
      }
      final cleaned = {
        for (final s in vals.map((e) => e.trim())) if (s.isNotEmpty) s
      }.toList()
        ..sort();
      if (cleaned.isEmpty) continue;
      out[k] = cleaned;
    }
    return out;
  }

  bool _matchAllEquals(Map<String, List<String>> tags, Map<String, String> allEquals) {
    for (final kv in allEquals.entries) {
      final vs = tags[kv.key] ?? const <String>[];
      if (!vs.contains(kv.value)) return false;
    }
    return true;
  }

  bool _matchKeyAnyOf(
      Map<String, List<String>> tags, Map<String, List<String>> keyAnyOf) {
    for (final kv in keyAnyOf.entries) {
      final vs = tags[kv.key] ?? const <String>[];
      final wanted = kv.value.toSet();
      if (vs.toSet().intersection(wanted).isEmpty) return false;
    }
    return true;
  }
}
