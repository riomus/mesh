/// Data models for mesh network traceroute functionality.
///
/// These models track trace requests, results, and events for network
/// path discovery and diagnostic purposes.
library;

/// Status of a trace request.
enum TraceStatus {
  /// Trace request has been sent but not yet completed
  pending,

  /// Trace completed successfully with route information
  completed,

  /// Trace failed (e.g., unreachable node, error response)
  failed,

  /// Trace request timed out waiting for response
  timeout,
}

/// A traceroute request sent to discover the path to a target node.
class TraceRequest {
  /// Unique identifier for this trace request
  final String id;

  /// Target node ID to trace the route to
  final int targetNodeId;

  /// MeshPacket ID of the trace request packet
  final int packetId;

  /// When the trace request was sent
  final DateTime sentTime;

  /// Current status of the trace
  final TraceStatus status;

  /// Device ID that sent this trace
  final String deviceId;

  const TraceRequest({
    required this.id,
    required this.targetNodeId,
    required this.packetId,
    required this.sentTime,
    required this.status,
    required this.deviceId,
  });

  /// Create a copy of this request with updated fields
  TraceRequest copyWith({
    String? id,
    int? targetNodeId,
    int? packetId,
    DateTime? sentTime,
    TraceStatus? status,
    String? deviceId,
  }) {
    return TraceRequest(
      id: id ?? this.id,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      packetId: packetId ?? this.packetId,
      sentTime: sentTime ?? this.sentTime,
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  String toString() =>
      'TraceRequest(id: $id, target: $targetNodeId, status: $status)';
}

/// The result of a traceroute, including the discovered path and metrics.
class TraceResult {
  /// ID of the corresponding TraceRequest
  final String requestId;

  /// Target node that was traced
  final int targetNodeId;

  /// When the trace was initiated
  final DateTime timestamp;

  /// Forward route: list of node IDs from source to destination
  final List<int>? route;

  /// SNR values (in dB, scaled by 4) for the forward route
  final List<int>? snrTowards;

  /// Return route: list of node IDs from destination back to source
  final List<int>? routeBack;

  /// SNR values (in dB, scaled by 4) for the return route
  final List<int>? snrBack;

  /// Node IDs that acknowledged the trace request but did not provide route info.
  /// These are "theoretical participants" that can be visualized on the map
  /// with dashed lines to show they received/acknowledged the request.
  final List<int> ackNodeIds;

  /// All events associated with this trace
  final List<TraceEvent> events;

  /// Final status of the trace
  final TraceStatus status;

  /// When the trace was last updated
  final DateTime lastUpdated;

  /// Device ID that sent this trace
  final String? deviceId;

  /// The node ID of the source device (local node)
  final int? sourceNodeId;

  const TraceResult({
    required this.requestId,
    required this.targetNodeId,
    required this.timestamp,
    this.route,
    this.snrTowards,
    this.routeBack,
    this.snrBack,
    this.ackNodeIds = const [],
    required this.events,
    required this.status,
    required this.lastUpdated,
    this.deviceId,
    this.sourceNodeId,
  });

  /// Number of hops in the forward route
  int? get hopCount => route?.length;

  /// Number of hops in the return route
  int? get hopCountBack => routeBack?.length;

  /// Check if this trace has route information
  bool get hasRoute => route != null && route!.isNotEmpty;

  /// Check if this trace has return route information
  bool get hasRouteBack => routeBack != null && routeBack!.isNotEmpty;

  /// Create a copy of this result with updated fields
  TraceResult copyWith({
    String? requestId,
    int? targetNodeId,
    DateTime? timestamp,
    List<int>? route,
    List<int>? snrTowards,
    List<int>? routeBack,
    List<int>? snrBack,
    List<int>? ackNodeIds,
    List<TraceEvent>? events,
    TraceStatus? status,
    DateTime? lastUpdated,
    String? deviceId,
    int? sourceNodeId,
  }) {
    return TraceResult(
      requestId: requestId ?? this.requestId,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      timestamp: timestamp ?? this.timestamp,
      route: route ?? this.route,
      snrTowards: snrTowards ?? this.snrTowards,
      routeBack: routeBack ?? this.routeBack,
      snrBack: snrBack ?? this.snrBack,
      ackNodeIds: ackNodeIds ?? this.ackNodeIds,
      events: events ?? this.events,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      deviceId: deviceId ?? this.deviceId,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
    );
  }

  @override
  String toString() =>
      'TraceResult(requestId: $requestId, target: $targetNodeId, hops: $hopCount, status: $status)';
}

/// An event that occurred during a trace operation.
class TraceEvent {
  /// When the event occurred
  final DateTime timestamp;

  /// Type of event (e.g., 'sent', 'ack', 'route_update', 'completed')
  final String type;

  /// Human-readable description of the event
  final String description;

  /// Additional data associated with the event
  final Map<String, dynamic>? data;

  const TraceEvent({
    required this.timestamp,
    required this.type,
    required this.description,
    this.data,
  });

  @override
  String toString() => 'TraceEvent($type: $description at $timestamp)';
}
