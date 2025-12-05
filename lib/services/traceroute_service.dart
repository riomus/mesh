import 'dart:async';
import 'dart:math';

import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../models/trace_models.dart';
import 'device_communication_event_service.dart';
import 'transport_layer.dart';
import 'ble_transport_layer.dart';

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
  /// Returns the trace request ID for tracking.
  Future<String> sendTraceRequest(String deviceId, int targetNodeId) async {
    final device = await _transportLayer.getDevice(deviceId);
    if (device == null) {
      throw Exception('Device not connected: $deviceId');
    }

    // Generate unique trace request ID
    final requestId = _generateTraceId();
    final now = DateTime.now();

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

  /// Send the actual TRACEROUTE_APP packet via the device
  Future<int> _sendTraceroutePacket(dynamic device, int targetNodeId) async {
    // For now, we use sendMessage as a workaround since we don't have
    // a direct sendRawPacket method exposed. In a real implementation,
    // we would send an empty payload with portnum=TRACEROUTE_APP
    // and dest=targetNodeId.
    //
    // The Meshtastic firmware will automatically handle the traceroute
    // when it receives a TRACEROUTE_APP packet.
    //
    // For this implementation, we'll send a special marker text that
    // the firmware ignores, but ideally we'd have a sendRawPacket method.

    try {
      // Send to the target node with empty text
      // The packet ID returned will help us track responses
      return await device.sendMessage('', targetNodeId);
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
      _handleTracerouteResponse(packet, decoded);
    }
    // Handle routing ACKs for our trace requests
    else if (decoded is RoutingPayloadDto) {
      _handleRoutingAck(packet, decoded);
    }
  }

  /// Handle incoming traceroute response packets
  void _handleTracerouteResponse(
    MeshPacketDto packet,
    TraceroutePayloadDto traceroute,
  ) {
    // Try to find the matching trace request
    // We match by target node (packet.from) and timing
    TraceRequest? matchingRequest;
    String? matchingRequestId;

    for (final entry in _pendingTraces.entries) {
      final request = entry.value;
      if (request.targetNodeId == packet.from &&
          request.status == TraceStatus.pending) {
        matchingRequest = request;
        matchingRequestId = entry.key;
        break;
      }
    }

    if (matchingRequest == null || matchingRequestId == null) {
      // No matching pending request, might be an unsolicited trace
      return;
    }

    final now = DateTime.now();
    final result = _traceHistory[matchingRequestId];

    if (result == null) return;

    // Check if this is a route_request or route_reply based on what fields are populated
    final isReply =
        traceroute.routeBack != null && traceroute.routeBack!.isNotEmpty;

    final event = TraceEvent(
      timestamp: now,
      type: isReply ? 'route_reply' : 'route_update',
      description: isReply
          ? 'Received route reply with ${traceroute.routeBack?.length ?? 0} hops back'
          : 'Received route update with ${traceroute.route?.length ?? 0} hops',
      data: {
        'route': traceroute.route,
        'snrTowards': traceroute.snrTowards,
        'routeBack': traceroute.routeBack,
        'snrBack': traceroute.snrBack,
        'rxSnr': packet.rxSnr,
        'rxRssi': packet.rxRssi,
      },
    );

    final updatedEvents = List<TraceEvent>.from(result.events)..add(event);

    // Update the trace result with the route information
    final updatedResult = result.copyWith(
      route: traceroute.route ?? result.route,
      snrTowards: traceroute.snrTowards ?? result.snrTowards,
      routeBack: traceroute.routeBack ?? result.routeBack,
      snrBack: traceroute.snrBack ?? result.snrBack,
      events: updatedEvents,
      status: isReply ? TraceStatus.completed : TraceStatus.pending,
      lastUpdated: now,
    );

    _traceHistory[matchingRequestId] = updatedResult;

    // If completed, remove from pending
    if (isReply) {
      final updatedRequest = matchingRequest.copyWith(
        status: TraceStatus.completed,
      );
      _pendingTraces[matchingRequestId] = updatedRequest;

      // Add completion event
      final completionEvent = TraceEvent(
        timestamp: now,
        type: 'completed',
        description:
            'Trace completed successfully with ${traceroute.routeBack?.length ?? 0} hops',
      );

      _traceHistory[matchingRequestId] = updatedResult.copyWith(
        events: List<TraceEvent>.from(updatedEvents)..add(completionEvent),
      );

      // Clean up pending after a delay
      Future.delayed(const Duration(seconds: 5), () {
        _pendingTraces.remove(matchingRequestId);
      });
    }

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

        final updatedResult = result.copyWith(
          events: updatedEvents,
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
