import 'dart:async';

import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';
import 'device_communication_event_service.dart';

/// Simple view model for a node entry in the mesh.
class MeshNodeView {
  final NodeNum? num;
  final UserDto? user;
  final PositionDto? position;
  final double? snr;
  final int? lastHeard;
  final DeviceMetricsDto? deviceMetrics;
  final int? hopsAway;
  final bool? isFavorite;
  final bool? isIgnored;
  final bool? viaMqtt;
  final Map<String, List<String>> tags;

  const MeshNodeView({
    required this.num,
    required this.user,
    required this.position,
    required this.snr,
    required this.lastHeard,
    required this.deviceMetrics,
    required this.hopsAway,
    required this.isFavorite,
    required this.isIgnored,
    required this.viaMqtt,
    required this.tags,
  });

  String get displayName => user?.longName?.isNotEmpty == true
      ? user!.longName!
      : (user?.shortName?.isNotEmpty == true
            ? user!.shortName!
            : (num?.toRadixString(16) ?? 'unknown'));
}

/// Aggregates nodes from Meshtastic events and exposes a stream for UI.
class NodesService {
  NodesService._() {
    _controller = StreamController<List<MeshNodeView>>.broadcast(
      onListen: () {
        // Seed new listeners with the current snapshot so UI doesn't flash empty
        if (_nodes.isNotEmpty) {
          _controller.add(_nodes.values.toList(growable: false));
        }
      },
    );
    _sub = DeviceCommunicationEventService.instance.listenAll().listen(
      _onDeviceEvent,
    );
  }

  static final NodesService instance = NodesService._();

  final Map<NodeNum, MeshNodeView> _nodes = <NodeNum, MeshNodeView>{};
  late final StreamController<List<MeshNodeView>> _controller;
  StreamSubscription<DeviceEvent>? _sub;
  NodeNum? _lastReporterNodeNum;
  // Optional custom reference for distance calculations (lat/lon degrees)
  double? _customRefLat;
  double? _customRefLon;

  /// Helper to parse lowercase hex string node id to int, returns null if invalid.
  NodeNum? _parseHexNodeId(String hex) {
    try {
      final cleaned = hex.trim().toLowerCase().replaceAll('0x', '');
      if (cleaned.isEmpty) return null;
      return int.parse(cleaned, radix: 16);
    } catch (_) {
      return null;
    }
  }

  void _onDeviceEvent(DeviceEvent e) {
    final payload = e.payload;
    if (payload is MeshtasticDeviceEventPayload) {
      final evt = payload.event;
      if (evt is NodeInfoEvent) {
        final info = evt.nodeInfo;
        final num = info.num;
        if (num != null) {
          final existing = _nodes[num];
          // Helper: normalize lastHeard to AGE seconds. Some firmwares/devices
          // report NodeInfo.lastHeard as epoch seconds, others as age seconds.
          // We detect epoch-like values and convert to age for consistent UI.
          int? _normalizeLastHeard(int? v) {
            if (v == null) return null;
            final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            // Heuristic threshold: values greater than ~6 years in seconds
            // are considered epoch seconds (since typical ages are much smaller).
            const threshold = 6 * 365 * 24 * 60 * 60; // ~189216000
            int age = v > threshold ? (nowSec - v) : v;
            if (age < 0) age = 0;
            return age;
          }

          // Represent node id as lowercase hex without 0x prefix for consistency
          final nodeHexId = num.toRadixString(16).toLowerCase();
          // Start with existing tags (if any) so we don't lose derived fields
          final tags = <String, List<String>>{};
          if (existing?.tags.isNotEmpty == true) {
            for (final e in existing!.tags.entries) {
              tags[e.key] = List<String>.from(e.value);
            }
          }
          // Base tags for this node info
          tags['network'] = const ['meshtastic'];
          tags['deviceId'] = [nodeHexId]; // node id
          // Name/role/hops/favorite/ignored/mqtt — prefer new values if provided
          if (info.user?.longName != null && info.user!.longName!.isNotEmpty) {
            tags['name'] = [info.user!.longName!];
          } else if (info.user?.shortName != null &&
              info.user!.shortName!.isNotEmpty) {
            tags['name'] = [info.user!.shortName!];
          } else if (!(tags.containsKey('name') &&
              (tags['name']?.isNotEmpty == true))) {
            tags['name'] = ['0x$nodeHexId'];
          }
          if (info.user?.role != null) tags['role'] = [info.user!.role!];
          if (info.hopsAway != null) tags['hops'] = ['${info.hopsAway}'];
          tags['favorite'] = [info.isFavorite == true ? 'true' : 'false'];
          tags['ignored'] = [info.isIgnored == true ? 'true' : 'false'];
          tags['viaMqtt'] = [info.viaMqtt == true ? 'true' : 'false'];
          // Preserve reporter device as sourceDeviceId when available
          final reporterIds = e.tags['deviceId'];
          if (reporterIds != null && reporterIds.isNotEmpty) {
            tags['sourceDeviceId'] = List<String>.from(reporterIds);
            // Try to resolve reporter id to a friendly node name as well
            final first = reporterIds.first;
            final asNum = _parseHexNodeId(first);
            if (asNum != null) {
              _lastReporterNodeNum = asNum;
              final src = _nodes[asNum];
              if (src != null) {
                tags['sourceNodeName'] = [src.displayName];
              }
            }
          }

          // Merge with existing so we don't drop previously known position or metrics
          _nodes[num] = MeshNodeView(
            num: num,
            user: info.user ?? existing?.user,
            // Preserve previous position if new info lacks coordinates
            position:
                (info.position?.latitudeI != null &&
                    info.position?.longitudeI != null)
                ? info.position
                : (existing?.position ?? info.position),
            snr: info.snr ?? existing?.snr,
            lastHeard:
                _normalizeLastHeard(info.lastHeard) ?? existing?.lastHeard,
            deviceMetrics: info.deviceMetrics ?? existing?.deviceMetrics,
            hopsAway: info.hopsAway ?? existing?.hopsAway,
            isFavorite: info.isFavorite ?? existing?.isFavorite,
            isIgnored: info.isIgnored ?? existing?.isIgnored,
            viaMqtt: info.viaMqtt ?? existing?.viaMqtt,
            tags: tags,
          );
          _emit();
        }
      }
      // Many devices emit position updates as MeshPacket payloads separate from NodeInfo.
      // When we receive such a packet, upsert the node's latest known position so the
      // map can render markers even if a full NodeInfo with position hasn't arrived.
      else if (evt is MeshPacketEvent) {
        final decoded = evt.decoded;
        if (decoded is PositionPayloadDto) {
          final from = evt.packet.from; // node id of the position sender
          if (from != null) {
            final existing = _nodes[from];
            final pos = decoded.position;
            // Normalize lastHeard to AGE (seconds since last heard). For mesh packets, we
            // only have rxTime (epoch seconds), so convert to age to be consistent with
            // NodeInfo.lastHeard which is already an age value in seconds.
            int? _ageFromEpochSeconds(int? epochSec) {
              if (epochSec == null) return null;
              final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
              final age = nowSec - epochSec;
              return age < 0 ? 0 : age;
            }

            // Build or merge node entry
            final hexId = from.toRadixString(16).toLowerCase();
            final merged = MeshNodeView(
              num: from,
              user: existing?.user,
              position: pos,
              snr: evt.packet.rxSnr ?? existing?.snr,
              lastHeard:
                  _ageFromEpochSeconds(evt.packet.rxTime) ??
                  existing?.lastHeard,
              deviceMetrics: existing?.deviceMetrics,
              hopsAway: existing?.hopsAway,
              isFavorite: existing?.isFavorite,
              isIgnored: existing?.isIgnored,
              viaMqtt: evt.packet.viaMqtt ?? existing?.viaMqtt,
              tags:
                  existing?.tags ??
                  <String, List<String>>{
                    'network': const ['meshtastic'],
                    'deviceId': [hexId],
                    'name': ['0x$hexId'],
                  },
            );
            _nodes[from] = merged;
            _emit();
          }
        }
      }
    }
  }

  void _emit() {
    _controller.add(_nodes.values.toList(growable: false));
  }

  /// Stream of all nodes; use client-side filtering/sorting in the UI.
  Stream<List<MeshNodeView>> listenAll() async* {
    yield snapshot;
    yield* _controller.stream;
  }

  /// Snapshot of current nodes.
  List<MeshNodeView> get snapshot => _nodes.values.toList(growable: false);

  /// Best-effort guess of the connected source device's current position.
  /// Returns null if not known.
  PositionDto? get sourcePosition => _lastReporterNodeNum != null
      ? _nodes[_lastReporterNodeNum!]?.position
      : null;

  /// Sets a custom reference point (lat, lon in degrees) used for distance sorting.
  /// Pass nulls to clear and fall back to source device position when available.
  void setCustomDistanceReference({double? lat, double? lon}) {
    _customRefLat = lat;
    _customRefLon = lon;
    // Re-emit so listeners can recompute distances/sorting
    _emit();
  }

  /// Returns the effective distance reference point to use: custom if present,
  /// otherwise the source device position converted to (lat, lon) doubles.
  (double lat, double lon)? get effectiveDistanceReference {
    if (_customRefLat != null && _customRefLon != null) {
      return (_customRefLat!, _customRefLon!);
    }
    final src = sourcePosition;
    if (src?.latitudeI != null && src?.longitudeI != null) {
      return (src!.latitudeI! / 1e7, src.longitudeI! / 1e7);
    }
    return null;
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}
