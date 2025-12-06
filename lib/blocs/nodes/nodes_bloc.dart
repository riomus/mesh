import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/mesh_node_view.dart';
import '../../meshtastic/model/meshtastic_models.dart';
import '../../meshtastic/model/meshtastic_event.dart';
import '../../services/device_communication_event_service.dart'
    as service_event;
import '../../services/logging_service.dart';
import 'nodes_event.dart';
import 'nodes_state.dart';

class NodesBloc extends Bloc<NodesEvent, NodesState> {
  StreamSubscription? _subscription;
  final Map<NodeNum, MeshNodeView> _nodesMap = {};

  NodesBloc() : super(const NodesState()) {
    on<NodesEventReceived>(_onNodesEventReceived);
    on<NodesDistanceReferenceUpdated>(_onNodesDistanceReferenceUpdated);

    _init();
  }

  void _init() {
    _subscription = service_event.DeviceCommunicationEventService.instance
        .listenAll()
        .listen(
          (event) => add(NodesEventReceived(event)),
          onError: (e, s) {
            LoggingService.instance.push(
              tags: {'class': 'NodesBloc'},
              level: 'error',
              message: 'Error in NodesBloc subscription: $e',
            );
          },
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void _onNodesDistanceReferenceUpdated(
    NodesDistanceReferenceUpdated event,
    Emitter<NodesState> emit,
  ) {
    emit(state.copyWith(customRefLat: event.lat, customRefLon: event.lon));
  }

  void _onNodesEventReceived(
    NodesEventReceived event,
    Emitter<NodesState> emit,
  ) {
    final e = event.event;
    final payload = e.payload;

    if (payload is service_event.MeshtasticDeviceEventPayload) {
      final evt = payload.event;
      if (evt is NodeInfoEvent) {
        _handleNodeInfoEvent(evt, e.tags, emit);
      } else if (evt is MeshPacketEvent) {
        _handleMeshPacketEvent(evt, emit);
      } else if (evt is MyInfoEvent) {
        _handleMyInfoEvent(evt, emit);
      }
    }
  }

  void _handleNodeInfoEvent(
    NodeInfoEvent evt,
    Map<String, List<String>> eventTags,
    Emitter<NodesState> emit,
  ) {
    final info = evt.nodeInfo;
    final num = info.num;
    if (num != null) {
      final existing = _nodesMap[num];

      int? _normalizeLastHeard(int? v) {
        if (v == null) return null;
        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        const threshold = 6 * 365 * 24 * 60 * 60;
        int age = v > threshold ? (nowSec - v) : v;
        if (age < 0) age = 0;
        return age;
      }

      final nodeHexId = num.toRadixString(16).toLowerCase();
      final tags = <String, List<String>>{};
      if (existing?.tags.isNotEmpty == true) {
        for (final e in existing!.tags.entries) {
          tags[e.key] = List<String>.from(e.value);
        }
      }

      tags['network'] = const ['meshtastic'];
      tags['deviceId'] = [nodeHexId];

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

      final reporterIds = eventTags['deviceId'];
      if (reporterIds != null && reporterIds.isNotEmpty) {
        tags['sourceDeviceId'] = List<String>.from(reporterIds);
        final first = reporterIds.first;
        final asNum = _parseHexNodeId(first);
        if (asNum != null) {
          final src = _nodesMap[asNum];
          if (src != null) {
            tags['sourceNodeName'] = [src.displayName];
          }
        }
      }

      _nodesMap[num] = MeshNodeView(
        num: num,
        user: info.user ?? existing?.user,
        position:
            (info.position?.latitudeI != null &&
                info.position?.longitudeI != null)
            ? info.position
            : (existing?.position ?? info.position),
        snr: info.snr ?? existing?.snr,
        lastHeard: _normalizeLastHeard(info.lastHeard) ?? existing?.lastHeard,
        deviceMetrics: info.deviceMetrics ?? existing?.deviceMetrics,
        hopsAway: info.hopsAway ?? existing?.hopsAway,
        isFavorite: info.isFavorite ?? existing?.isFavorite,
        isIgnored: info.isIgnored ?? existing?.isIgnored,
        viaMqtt: info.viaMqtt ?? existing?.viaMqtt,
        tags: tags,
      );

      emit(state.copyWith(nodes: _nodesMap.values.toList(growable: false)));
    }
  }

  void _handleMeshPacketEvent(MeshPacketEvent evt, Emitter<NodesState> emit) {
    final decoded = evt.decoded;
    if (decoded is PositionPayloadDto) {
      final from = evt.packet.from;
      if (from != null) {
        final existing = _nodesMap[from];
        final pos = decoded.position;

        int? _ageFromEpochSeconds(int? epochSec) {
          if (epochSec == null) return null;
          final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          final age = nowSec - epochSec;
          return age < 0 ? 0 : age;
        }

        final hexId = from.toRadixString(16).toLowerCase();
        final merged = MeshNodeView(
          num: from,
          user: existing?.user,
          position: pos,
          snr: evt.packet.rxSnr ?? existing?.snr,
          lastHeard:
              _ageFromEpochSeconds(evt.packet.rxTime) ?? existing?.lastHeard,
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
        _nodesMap[from] = merged;
        emit(state.copyWith(nodes: _nodesMap.values.toList(growable: false)));
      }
    }
  }

  void _handleMyInfoEvent(MyInfoEvent evt, Emitter<NodesState> emit) {
    final myInfo = evt.myInfo;
    if (myInfo.myNodeNum != null) {
      emit(state.copyWith(localNodeId: myInfo.myNodeNum));
    }
  }

  NodeNum? _parseHexNodeId(String hex) {
    try {
      final cleaned = hex.trim().toLowerCase().replaceAll('0x', '');
      if (cleaned.isEmpty) return null;
      return int.parse(cleaned, radix: 16);
    } catch (_) {
      return null;
    }
  }
}
