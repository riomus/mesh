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
    _sub = DeviceCommunicationEventService.instance.listenAll().listen(_onDeviceEvent);
  }

  static final NodesService instance = NodesService._();

  final Map<NodeNum, MeshNodeView> _nodes = <NodeNum, MeshNodeView>{};
  final StreamController<List<MeshNodeView>> _controller = StreamController<List<MeshNodeView>>.broadcast();
  StreamSubscription<DeviceEvent>? _sub;

  void _onDeviceEvent(DeviceEvent e) {
    final payload = e.payload;
    if (payload is MeshtasticDeviceEventPayload) {
      final evt = payload.event;
      if (evt is NodeInfoEvent) {
        final info = evt.nodeInfo;
        final num = info.num;
        if (num != null) {
          final tags = <String, List<String>>{
            'network': const ['meshtastic'],
            if (info.user?.role != null) 'role': [info.user!.role!],
            if (info.hopsAway != null) 'hops': ['${info.hopsAway}'],
            if (info.isFavorite == true) 'favorite': const ['true'] else 'favorite': const ['false'],
            if (info.isIgnored == true) 'ignored': const ['true'] else 'ignored': const ['false'],
            if (info.viaMqtt == true) 'viaMqtt': const ['true'] else 'viaMqtt': const ['false'],
          };
          // Inherit deviceId tag from envelope if available
          final deviceIds = e.tags['deviceId'];
          if (deviceIds != null && deviceIds.isNotEmpty) {
            tags['deviceId'] = List<String>.from(deviceIds);
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

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}
