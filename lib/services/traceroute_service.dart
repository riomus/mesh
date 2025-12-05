import 'dart:async';
import 'dart:math';

import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../models/trace_models.dart';
import 'device_communication_event_service.dart';
import 'transport_layer.dart';
import 'ble_transport_layer.dart';
import 'settings_service.dart';

/// Service to manage traceroute requests and track their results.
///
/// This service handles sending TRACEROUTE_APP packets to nodes,
/// tracking the responses, and maintaining history of all traces.
class TracerouteService {
  static final TracerouteService _instance = TracerouteService._internal();
  static TracerouteService get instance => _instance;

  TracerouteService._internal() {
    _subscribeToEvents();
  }

  /// Active trace requests awaiting completion
  final Map<String, TraceRequest> _pendingTraces = {};

  /// Completed trace results with full history
  final Map<String, TraceResult> _traceHistory = {};

  /// Map of target node ID to trace request IDs for quick lookup
  final Map<int, List<String>> _nodeTraceIndex = {};

  /// Map of target node ID to last trace time for rate limiting
  final Map<int, DateTime> _lastTraceTime = {};

  final _historyController = StreamController<List<TraceResult>>.broadcast();
  TransportLayer _transportLayer = BleTransportLayer();

  /// Stream of all trace results for UI updates
  Stream<List<TraceResult>> listenAllTraces() => _historyController.stream;

  /// Get all trace results, sorted by timestamp (most recent first)
  List<TraceResult> getAllTraces() {
    final traces = _traceHistory.values.toList();
    traces.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return traces;
  }

  /// Get all traces for a specific target node
  List<TraceResult> getTracesForNode(int nodeId) {
    final requestIds = _nodeTraceIndex[nodeId] ?? [];
    final traces = requestIds
        .map((id) => _traceHistory[id])
        .whereType<TraceResult>()
        .toList();
    traces.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return traces;
  }

  /// Get the most recent trace for a specific node
  TraceResult? getLatestTraceForNode(int nodeId) {
    final traces = getTracesForNode(nodeId);
    return traces.isEmpty ? null : traces.first;
  }

  /// Send a traceroute request to discover the path to a target node.
  ///
  /// Throws an Exception if called too soon after a previous trace to the same node.
  /// Returns the trace request ID for tracking.
  Future<String> sendTraceRequest(String deviceId, int targetNodeId) async {
    final device = await _transportLayer.getDevice(deviceId);
    if (device == null) {
      throw Exception('Device not connected: $deviceId');
    }

    // Check rate limiting
    final minInterval =
        SettingsService.instance.current?.tracerouteMinIntervalSeconds ?? 30;
    final lastTrace = _lastTraceTime[targetNodeId];

    if (lastTrace != null) {
      final timeSinceLastTrace = DateTime.now().difference(lastTrace);
      final requiredInterval = Duration(seconds: minInterval);

      if (timeSinceLastTrace < requiredInterval) {
        final remainingSeconds =
            (requiredInterval - timeSinceLastTrace).inSeconds;
        throw Exception(
          'Please wait $remainingSeconds more second${remainingSeconds == 1 ? '' : 's'} before tracing to this node again (rate limit: ${minInterval}s)',
        );
      }
    }

    // Update last trace time
    _lastTraceTime[targetNodeId] = DateTime.now();

    // Generate unique trace request ID
    final requestId = _generateTraceId();
    final now = DateTime.now();

    print(
      '[TracerouteService] Sending trace request to node $targetNodeId from device $deviceId',
    );

    // Create empty RouteDiscovery message and send it via TRACEROUTE_APP
    // The actual tracing is done by the firmware by sending an empty payload
    // to the TRACEROUTE_APP portnum with the destination set
    final packetId = await _sendTraceroutePacket(device, targetNodeId);

    // Create trace request
    final request = TraceRequest(
      id: requestId,
      targetNodeId: targetNodeId,
      packetId: packetId,
      sentTime: now,
      status: TraceStatus.pending,
      deviceId: deviceId,
    );

    _pendingTraces[requestId] = request;

    // Create initial trace result
    final result = TraceResult(
      requestId: requestId,
      targetNodeId: targetNodeId,
      timestamp: now,
      events: [
        TraceEvent(
          timestamp: now,
          type: 'sent',
          description: 'Trace request sent to node $targetNodeId',
          data: {'packetId': packetId},
        ),
      ],
      status: TraceStatus.pending,
      lastUpdated: now,
    );

    _traceHistory[requestId] = result;

    // Index by node ID for quick lookup
    if (!_nodeTraceIndex.containsKey(targetNodeId)) {
      _nodeTraceIndex[targetNodeId] = [];
    }
    _nodeTraceIndex[targetNodeId]!.add(requestId);

    _emitHistory();

    // Set timeout for trace completion (60 seconds)
    Timer(const Duration(seconds: 60), () => _handleTimeout(requestId));

    return requestId;
  }

  /// Send the actual TRACEROUTE_APP packet via the device.
  ///
  /// This sends a proper TRACEROUTE_APP packet with an empty payload.
  /// The Meshtastic firmware handles the actual route discovery when it
  /// receives a packet with portnum=TRACEROUTE_APP.
  Future<int> _sendTraceroutePacket(dynamic device, int targetNodeId) async {
    try {
      // Use the device's sendTraceroute method which sends a proper
      // TRACEROUTE_APP packet with PortNum.TRACEROUTE_APP and empty payload
      return await device.sendTraceroute(targetNodeId);
    } catch (e) {
      throw Exception('Failed to send traceroute packet: $e');
    }
  }

  /// Subscribe to device events to track traceroute responses
  void _subscribeToEvents() {
    DeviceCommunicationEventService.instance.listenAll().listen(_handleEvent);
  }

  /// Handle incoming device events
  void _handleEvent(DeviceEvent event) {
    if (event.payload is! MeshtasticDeviceEventPayload) return;

    final meshPayload = event.payload as MeshtasticDeviceEventPayload;
    if (meshPayload.event is! MeshPacketEvent) return;

    final packetEvent = meshPayload.event as MeshPacketEvent;
    final packet = packetEvent.packet;
    final decoded = packetEvent.decoded;

    // Handle traceroute responses
    if (decoded is TraceroutePayloadDto) {
      print(
        '[TracerouteService] Received TraceroutePayloadDto from node ${packet.from}',
      );
      print(
        '[TracerouteService] Route: ${decoded.route}, RouteBack: ${decoded.routeBack}',
      );
      print('[TracerouteService] Pending traces: ${_pendingTraces.length}');
      _handleTracerouteResponse(packet, decoded);
    }
    // Handle routing ACKs for our trace requests
    else if (decoded is RoutingPayloadDto) {
      print('[TracerouteService] Received RoutingPayloadDto');
      _handleRoutingAck(packet, decoded);
    }
  }

  /// Handle incoming traceroute response packets
  void _handleTracerouteResponse(
    MeshPacketDto packet,
    TraceroutePayloadDto traceroute,
  ) {
    // Try to find the matching trace request
    // For traceroute responses, packet.from is NOT the target node - it's the responding node
    // (often the local node for 0-hop traces). We need to match differently.
    TraceRequest? matchingRequest;
    String? matchingRequestId;

    print(
      '[TracerouteService] Looking for matching trace for packet from node ${packet.from}, to: ${packet.to}',
    );
    print(
      '[TracerouteService] Pending traces target nodes: ${_pendingTraces.values.map((r) => r.targetNodeId).toList()}',
    );

    // Strategy 1: If packet has an ID, try to match by packet ID
    if (packet.id != null) {
      for (final entry in _pendingTraces.entries) {
        final request = entry.value;
        if (request.packetId == packet.id &&
            request.status == TraceStatus.pending) {
          matchingRequest = request;
          matchingRequestId = entry.key;
          print(
            '[TracerouteService] MATCHED by packet ID: $matchingRequestId (packetId=${packet.id})',
          );
          break;
        }
      }
    }

    // Strategy 2: If no match yet, find the most recent pending trace
    // This works for 0-hop traces where the response comes from a different node
    if (matchingRequest == null && _pendingTraces.isNotEmpty) {
      // Get the most recently sent pending trace
      final sortedTraces = _pendingTraces.entries.toList()
        ..sort((a, b) => b.value.sentTime.compareTo(a.value.sentTime));

      for (final entry in sortedTraces) {
        final request = entry.value;
        if (request.status == TraceStatus.pending) {
          // Check if this trace was sent recently (within last 10 seconds)
          final timeSinceSent = DateTime.now().difference(request.sentTime);
          if (timeSinceSent.inSeconds <= 10) {
            matchingRequest = request;
            matchingRequestId = entry.key;
            print(
              '[TracerouteService] MATCHED by recent pending trace: $matchingRequestId (target=${request.targetNodeId})',
            );
            break;
          }
        }
      }
    }

    if (matchingRequest == null || matchingRequestId == null) {
      // No matching pending request, might be an unsolicited trace
      print(
        '[TracerouteService] No matching trace request found for packet from ${packet.from}',
      );
      return;
    }

    final now = DateTime.now();
    final result = _traceHistory[matchingRequestId];

    if (result == null) {
      print(
        '[TracerouteService] ERROR: No trace result found for $matchingRequestId',
      );
      return;
    }

    // Check if this is a route_request or route_reply based on what fields are populated
    // For directly connected nodes (0 hops), both route and routeBack may be empty but it's still complete
    final hasRouteBack =
        traceroute.routeBack != null && traceroute.routeBack!.isNotEmpty;
    final hasRoute = traceroute.route != null && traceroute.route!.isNotEmpty;

    // Any traceroute response completes the trace
    // Empty routes just mean 0 hops (directly connected)
    final hopCount = hasRouteBack
        ? traceroute.routeBack!.length
        : (hasRoute ? traceroute.route!.length : 0);

    print(
      '[TracerouteService] Processing trace response: $hopCount hops, hasRoute=$hasRoute, hasRouteBack=$hasRouteBack',
    );

    final routeReplyEvent = TraceEvent(
      timestamp: now,
      type: 'route_reply',
      description: hopCount == 0
          ? 'Trace complete: directly connected (0 hops)'
          : 'Received route reply with $hopCount hops',
      data: {
        'route': traceroute.route,
        'snrTowards': traceroute.snrTowards,
        'routeBack': traceroute.routeBack,
        'snrBack': traceroute.snrBack,
        'rxSnr': packet.rxSnr,
        'rxRssi': packet.rxRssi,
      },
    );

    // Add completion event
    final completionEvent = TraceEvent(
      timestamp: now,
      type: 'completed',
      description: hopCount == 0
          ? 'Trace completed: node is directly connected'
          : 'Trace completed successfully with $hopCount hops',
    );

    // Create all events at once
    final updatedEvents = List<TraceEvent>.from(result.events)
      ..add(routeReplyEvent)
      ..add(completionEvent);

    // Update the trace result with the route information - do this ONCE
    final updatedResult = result.copyWith(
      route: traceroute.route ?? result.route,
      snrTowards: traceroute.snrTowards ?? result.snrTowards,
      routeBack: traceroute.routeBack ?? result.routeBack,
      snrBack: traceroute.snrBack ?? result.snrBack,
      events: updatedEvents,
      status: TraceStatus
          .completed, // Always mark as completed when we get a response
      lastUpdated: now,
    );

    _traceHistory[matchingRequestId] = updatedResult;

    // Remove from pending since it's completed
    final updatedRequest = matchingRequest.copyWith(
      status: TraceStatus.completed,
    );
    _pendingTraces[matchingRequestId] = updatedRequest;

    print('[TracerouteService] Trace $matchingRequestId marked as completed');

    // Clean up pending after a delay
    Future.delayed(const Duration(seconds: 5), () {
      _pendingTraces.remove(matchingRequestId);
    });

    _emitHistory();
  }

  /// Handle routing ACKs that may correspond to our trace requests
  void _handleRoutingAck(MeshPacketDto packet, RoutingPayloadDto routing) {
    if (routing.requestId == null || routing.requestId == 0) return;

    final now = DateTime.now();

    // Find trace request with matching packet ID
    for (final entry in _pendingTraces.entries) {
      final request = entry.value;
      if (request.packetId == routing.requestId) {
        final result = _traceHistory[entry.key];
        if (result == null) continue;

        final hasError =
            routing.errorReason != null && routing.errorReason != 'NONE';

        final event = TraceEvent(
          timestamp: now,
          type: hasError ? 'error' : 'ack',
          description: hasError
              ? 'Trace request failed: ${routing.errorReason}'
              : 'Trace request acknowledged by node ${packet.from}',
          data: {'from': packet.from, 'errorReason': routing.errorReason},
        );

        final updatedEvents = List<TraceEvent>.from(result.events)..add(event);

        // If this is a successful ACK (not an error), add the acknowledging node
        // to the list of theoretical participants
        var updatedAckNodeIds = result.ackNodeIds;
        if (!hasError && packet.from != null) {
          final ackNodeId = packet.from!;
          // Only add if not already in the list and not the target node itself
          if (!result.ackNodeIds.contains(ackNodeId) &&
              ackNodeId != result.targetNodeId) {
            updatedAckNodeIds = List<int>.from(result.ackNodeIds)
              ..add(ackNodeId);
            print(
              '[TracerouteService] Added ACK node $ackNodeId to trace ${entry.key}',
            );
          }
        }

        final updatedResult = result.copyWith(
          events: updatedEvents,
          ackNodeIds: updatedAckNodeIds,
          status: hasError ? TraceStatus.failed : result.status,
          lastUpdated: now,
        );

        _traceHistory[entry.key] = updatedResult;

        if (hasError) {
          _pendingTraces[entry.key] = request.copyWith(
            status: TraceStatus.failed,
          );
        }

        _emitHistory();
        break;
      }
    }
  }

  /// Handle trace request timeout
  void _handleTimeout(String requestId) {
    final request = _pendingTraces[requestId];
    if (request == null || request.status != TraceStatus.pending) {
      return; // Already completed or failed
    }

    final result = _traceHistory[requestId];
    if (result == null) return;

    final now = DateTime.now();
    final event = TraceEvent(
      timestamp: now,
      type: 'timeout',
      description: 'Trace request timed out after 60 seconds',
    );

    final updatedEvents = List<TraceEvent>.from(result.events)..add(event);

    _traceHistory[requestId] = result.copyWith(
      events: updatedEvents,
      status: TraceStatus.timeout,
      lastUpdated: now,
    );

    _pendingTraces[requestId] = request.copyWith(status: TraceStatus.timeout);

    _emitHistory();

    // Clean up after timeout
    Future.delayed(const Duration(seconds: 5), () {
      _pendingTraces.remove(requestId);
    });
  }

  /// Generate a unique trace request ID
  String _generateTraceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'trace_${timestamp}_$random';
  }

  /// Emit updated history to subscribers
  void _emitHistory() {
    _historyController.add(getAllTraces());
  }

  /// For testing: set custom transport layer
  set transportLayer(TransportLayer layer) {
    _transportLayer = layer;
  }

  /// Dispose resources
  void dispose() {
    _historyController.close();
  }
}
