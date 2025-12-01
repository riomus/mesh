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

  String get displayName =>
      user?.longName?.isNotEmpty == true
          ? user!.longName!
          : (user?.shortName?.isNotEmpty == true ? user!.shortName! : (num?.toRadixString(16) ?? 'unknown'));
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
    _sub = DeviceCommunicationEventService.instance.listenAll().listen(_onDeviceEvent);
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
          // Represent node id as lowercase hex without 0x prefix for consistency
          final nodeHexId = num.toRadixString(16).toLowerCase();
          final tags = <String, List<String>>{
            'network': const ['meshtastic'],
            // deviceId on Nodes should represent the NODE id
            'deviceId': [nodeHexId],
            if (info.user?.longName != null && info.user!.longName!.isNotEmpty)
              'name': [info.user!.longName!]
            else if (info.user?.shortName != null && info.user!.shortName!.isNotEmpty)
              'name': [info.user!.shortName!]
            else
              'name': ['0x$nodeHexId'],
            if (info.user?.role != null) 'role': [info.user!.role!],
            if (info.hopsAway != null) 'hops': ['${info.hopsAway}'],
            if (info.isFavorite == true) 'favorite': const ['true'] else 'favorite': const ['false'],
            if (info.isIgnored == true) 'ignored': const ['true'] else 'ignored': const ['false'],
            if (info.viaMqtt == true) 'viaMqtt': const ['true'] else 'viaMqtt': const ['false'],
          };
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

          _nodes[num] = MeshNodeView(
            num: num,
            user: info.user,
            position: info.position,
            snr: info.snr,
            lastHeard: info.lastHeard,
            deviceMetrics: info.deviceMetrics,
            hopsAway: info.hopsAway,
            isFavorite: info.isFavorite,
            isIgnored: info.isIgnored,
            viaMqtt: info.viaMqtt,
            tags: tags,
          );
          _emit();
        }
      }
    }
  }

  void _emit() {
    _controller.add(_nodes.values.toList(growable: false));
  }

  /// Stream of all nodes; use client-side filtering/sorting in the UI.
  Stream<List<MeshNodeView>> listenAll() => _controller.stream;

  /// Snapshot of current nodes.
  List<MeshNodeView> get snapshot => _nodes.values.toList(growable: false);

  /// Best-effort guess of the connected source device's current position.
  /// Returns null if not known.
  PositionDto? get sourcePosition => _lastReporterNodeNum != null ? _nodes[_lastReporterNodeNum!]?.position : null;

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
