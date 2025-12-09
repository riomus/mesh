import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart' as latlng;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/nodes/nodes_bloc.dart';
import '../blocs/nodes/nodes_state.dart';
import '../blocs/nodes/nodes_event.dart';
import '../models/mesh_node_view.dart'; // For MeshNodeView
import '../services/device_status_store.dart';
import '../services/device_state_service.dart';
import '../services/traceroute_service.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../utils/text_sanitize.dart';
import '../pages/node_details_page.dart';
import '../l10n/app_localizations.dart';
import '../models/trace_models.dart';
import 'map_zoom_controls.dart';

class NodesMapWidget extends StatefulWidget {
  final TraceResult? highlightedTrace;
  final bool showAllNodes;

  const NodesMapWidget({
    super.key,
    this.highlightedTrace,
    this.showAllNodes = true,
  });

  @override
  State<NodesMapWidget> createState() => _NodesMapWidgetState();
}

class _NodesMapWidgetState extends State<NodesMapWidget>
    with AutomaticKeepAliveClientMixin {
  late final MapController _controller = MapController();

  @override
  bool get wantKeepAlive => true;

  List<MeshNodeView> _nodes = const <MeshNodeView>[];
  StreamSubscription<List<TraceResult>>? _traceSub;
  TraceResult? _activeTrace;
  bool _didAutoFit = false;

  @override
  void initState() {
    super.initState();
    _activeTrace = widget.highlightedTrace;

    // Listen for trace updates to keep the map live
    if (widget.highlightedTrace != null) {
      _traceSub = TracerouteService.instance.listenAllTraces().listen((traces) {
        if (!mounted || _activeTrace == null) return;
        final updated = traces.firstWhereOrNull(
          (t) => t.requestId == _activeTrace!.requestId,
        );
        if (updated != null && updated != _activeTrace) {
          setState(() {
            _activeTrace = updated;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(NodesMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedTrace != oldWidget.highlightedTrace) {
      setState(() {
        _activeTrace = widget.highlightedTrace;
      });
    }
  }

  @override
  void dispose() {
    _traceSub?.cancel();
    super.dispose();
  }

  Iterable<(MeshNodeView node, double lat, double lon)> get _nodePoints sync* {
    // If we have a highlighted trace and showAllNodes is false, filter to only those nodes
    final traceNodeIds = <int>{};
    if (_activeTrace != null) {
      final trace = _activeTrace!;

      // Add target node (always show target for trace context)
      traceNodeIds.add(trace.targetNodeId);

      // Add nodes in route (forward path)
      if (trace.route != null) {
        traceNodeIds.addAll(trace.route!);
      }

      // Add nodes in routeBack (return path)
      if (trace.routeBack != null) {
        traceNodeIds.addAll(trace.routeBack!);
      }

      // Add acknowledging nodes (theoretical participants)
      traceNodeIds.addAll(trace.ackNodeIds);

      // Add local node (start of trace)
      final sourceNodeId = _getSourceNodeId(trace);
      if (sourceNodeId != null) {
        traceNodeIds.add(sourceNodeId);
      }

      // Add nodes that sent ACKs or other events (from trace events)
      for (final event in trace.events) {
        if (event.data != null && event.data!['from'] is int) {
          traceNodeIds.add(event.data!['from'] as int);
        }
      }
    }

    if (widget.showAllNodes) {
      // Yield all nodes from the main list
      for (final n in _nodes) {
        final p = n.position;
        if (p?.latitudeI != null && p?.longitudeI != null) {
          final lat = p!.latitudeI! / 1e7;
          final lon = p.longitudeI! / 1e7;
          if (lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180) {
            yield (n, lat, lon);
          }
        }
      }
      // Also yield any trace nodes that are NOT in the main list
      for (final id in traceNodeIds) {
        if (_nodes.any((n) => n.num == id)) continue;
        final view = _getNodeView(id);
        if (view != null) {
          final p = view.position;
          if (p?.latitudeI != null && p?.longitudeI != null) {
            final lat = p!.latitudeI! / 1e7;
            final lon = p.longitudeI! / 1e7;
            if (lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180) {
              yield (view, lat, lon);
            }
          }
        }
      }
    } else {
      // Only yield trace nodes
      for (final id in traceNodeIds) {
        final view = _getNodeView(id);
        if (view != null) {
          final p = view.position;
          if (p?.latitudeI != null && p?.longitudeI != null) {
            final lat = p!.latitudeI! / 1e7;
            final lon = p.longitudeI! / 1e7;
            if (lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180) {
              yield (view, lat, lon);
            }
          }
        }
      }
    }
  }

  /// Helper to find a node view, checking local list first then connected devices
  MeshNodeView? _getNodeView(int nodeId) {
    // 1. Check main node list
    final existing = _nodes.firstWhereOrNull((n) => n.num == nodeId);
    if (existing != null) return existing;

    // 2. Check connected devices via DeviceStateService
    // Iterate over all connected devices to see if any of them IS this node
    // or has info about this node (though usually we only have info about the device itself)
    final connectedIds = DeviceStatusStore.instance.connectedDeviceIds;
    for (final deviceId in connectedIds) {
      final state = DeviceStateService.instance.getState(deviceId);
      if (state == null) continue;

      // Check if this device IS the node we are looking for
      if (state.myNodeInfo?.myNodeNum == nodeId) {
        // Try to find full node info in the device's node list
        final selfNode = state.nodes.firstWhereOrNull((n) => n.num == nodeId);
        if (selfNode != null) {
          return MeshNodeView(
            num: nodeId,
            user: selfNode.user,
            position: selfNode.position,
            lastHeard: 0,
            snr: 0,
            deviceMetrics: selfNode.deviceMetrics,
          );
        }

        // Fallback if not in node list (minimal info)
        return MeshNodeView(
          num: nodeId,
          user: UserDto(
            longName: AppLocalizations.of(context).localDevice,
            shortName: 'ME',
          ),
          position: null,
          lastHeard: 0,
          snr: 0,
        );
      }
    }

    return null;
  }

  Color _getTraceStatusColor(TraceStatus status) {
    switch (status) {
      case TraceStatus.completed:
        return Colors.green;
      case TraceStatus.failed:
        return Colors.red;
      case TraceStatus.timeout:
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  int? _getSourceNodeId(TraceResult trace) {
    if (trace.sourceNodeId != null) {
      return trace.sourceNodeId;
    }
    if (trace.deviceId != null) {
      debugPrint('_getSourceNodeId: trace.deviceId=${trace.deviceId}');

      // Check if the trace device ID matches a currently connected device
      // If so, we can assume the local node ID is the source
      // This check MUST be first because sometimes the target node might have the same user ID
      // as the connected device (e.g. if it's the phone itself or misconfigured),
      // and we want to ensure we identify the LOCAL node as the source.
      final connectedIds = DeviceStatusStore.instance.connectedDeviceIds;
      debugPrint('_getSourceNodeId: connectedIds=$connectedIds');

      if (connectedIds.contains(trace.deviceId)) {
        final localId = context.read<NodesBloc>().state.localNodeId;
        debugPrint(
          '_getSourceNodeId: Match found in connectedIds. localId=$localId',
        );
        if (localId != null) {
          return localId;
        }
      }

      // Try matching by user ID (most reliable)
      final sourceNodeByUser = _nodes.firstWhereOrNull(
        (n) => n.user?.id == trace.deviceId,
      );
      if (sourceNodeByUser?.num != null) {
        debugPrint(
          '_getSourceNodeId: Match found by user ID. nodeNum=${sourceNodeByUser!.num}',
        );
        return sourceNodeByUser.num;
      }

      // Try matching by parsing device ID (e.g. !12345678 -> 0x12345678)
      if (trace.deviceId != null && trace.deviceId!.startsWith('!')) {
        final hex = trace.deviceId!.substring(1);
        final num = int.tryParse(hex, radix: 16);
        if (num != null) {
          // Verify this node exists in our list
          final node = _nodes.firstWhereOrNull((n) => n.num == num);
          if (node != null) {
            debugPrint(
              '_getSourceNodeId: Match found by parsed ID. nodeNum=${node.num}',
            );
            return node.num;
          }
        }
      }

      // Try matching by tag (legacy/fallback)
      final sourceNodeByTag = _nodes.firstWhereOrNull(
        (n) => n.tags['sourceDeviceId']?.contains(trace.deviceId!) ?? false,
      );
      if (sourceNodeByTag?.num != null) {
        debugPrint(
          '_getSourceNodeId: Match found by tag. nodeNum=${sourceNodeByTag!.num}',
        );
        return sourceNodeByTag.num;
      }
    }
    // Fallback to local node if deviceId is null or not found
    // (Assuming trace was initiated locally if we can't find the remote source)
    final localId = context.read<NodesBloc>().state.localNodeId;
    debugPrint('_getSourceNodeId: Fallback to localId=$localId');
    return localId;
  }

  // Helper to find node position
  (double, double)? _getPos(int nodeId) {
    final node = _getNodeView(nodeId);
    if (node == null) {
      if (_activeTrace != null && nodeId == _activeTrace!.targetNodeId) {
        debugPrint(
          '_getPos: Target Node $nodeId NOT FOUND in _nodes list or connected devices',
        );
      }
      return null;
    }
    if (node.position?.latitudeI == null || node.position?.longitudeI == null) {
      if (_activeTrace != null && nodeId == _activeTrace!.targetNodeId) {
        debugPrint(
          '_getPos: Target Node $nodeId FOUND but has NO POSITION data',
        );
      }
      return null;
    }
    return (node.position!.latitudeI! / 1e7, node.position!.longitudeI! / 1e7);
  }

  void _fitBounds() {
    final pts = _nodePoints.toList(growable: false);
    if (pts.isEmpty) return;
    if (pts.length == 1) {
      // Center on the single point with a friendly zoom
      final only = pts.first;
      _controller.move(latlng.LatLng(only.$2, only.$3), 13);
      return;
    }
    final bounds = LatLngBounds.fromPoints([
      for (final p in pts) latlng.LatLng(p.$2, p.$3),
    ]);
    try {
      _controller.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(24)),
      );
    } catch (_) {
      // Fallback: compute average center if fitCamera throws (shouldn't on v8)
      double minLat = pts.first.$2,
          maxLat = pts.first.$2,
          minLon = pts.first.$3,
          maxLon = pts.first.$3;
      for (final p in pts) {
        minLat = p.$2 < minLat ? p.$2 : minLat;
        maxLat = p.$2 > maxLat ? p.$2 : maxLat;
        minLon = p.$3 < minLon ? p.$3 : minLon;
        maxLon = p.$3 > maxLon ? p.$3 : maxLon;
      }
      final center = latlng.LatLng(
        (minLat + maxLat) / 2,
        (minLon + maxLon) / 2,
      );
      _controller.move(center, 10);
    }
  }

  void _onLongPress(TapPosition tapPosition, latlng.LatLng point) {
    context.read<NodesBloc>().add(
      NodesDistanceReferenceUpdated(lat: point.latitude, lon: point.longitude),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).customRefSet(
            point.latitude.toStringAsFixed(5),
            point.longitude.toStringAsFixed(5),
          ),
        ),
      ),
    );
  }

  String _formatLastHeard(BuildContext context, int secondsAgo) {
    const twoDays = 2 * 24 * 60 * 60; // 172800
    if (secondsAgo < twoDays) {
      if (secondsAgo < 60)
        return AppLocalizations.of(context).agoSeconds(secondsAgo);
      final minutes = secondsAgo ~/ 60;
      if (minutes < 60) return AppLocalizations.of(context).agoMinutes(minutes);
      final hours = minutes ~/ 60;
      if (hours < 24) return AppLocalizations.of(context).agoHours(hours);
      final days = hours ~/ 24;
      return AppLocalizations.of(context).agoDays(days);
    }
    final dt = DateTime.now().subtract(Duration(seconds: secondsAgo));
    String two(int n) => n.toString().padLeft(2, '0');
    final relDays = secondsAgo ~/ (24 * 60 * 60);
    final dateStr =
        '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
    return '$dateStr (${AppLocalizations.of(context).agoDays(relDays)})';
  }

  List<MeshNodeView> _getMissingLocationNodes() {
    if (_activeTrace == null) return [];
    final trace = _activeTrace!;
    final traceNodeIds = <int>{};

    traceNodeIds.add(trace.targetNodeId);
    if (trace.route != null) traceNodeIds.addAll(trace.route!);
    if (trace.routeBack != null) traceNodeIds.addAll(trace.routeBack!);
    traceNodeIds.addAll(trace.ackNodeIds);

    final sourceNodeId = _getSourceNodeId(trace);
    if (sourceNodeId != null) traceNodeIds.add(sourceNodeId);

    final missing = <MeshNodeView>[];
    for (final id in traceNodeIds) {
      if (_getPos(id) == null) {
        var node = _getNodeView(id);
        if (node == null) {
          node = MeshNodeView(
            num: id,
            user: UserDto(
              id: '!${id.toRadixString(16)}',
              longName: 'Node 0x${id.toRadixString(16)}',
              shortName: '0x${id.toRadixString(16)}',
            ),
            position: null,
          );
        }
        missing.add(node);
      }
    }

    final unique = <int, MeshNodeView>{};
    for (final n in missing) {
      if (n.num != null) unique[n.num!] = n;
    }
    return unique.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = context.watch<NodesBloc>().state;
    _nodes = state.nodes;
    final missingNodes = _getMissingLocationNodes();

    if (!_didAutoFit && _nodePoints.isNotEmpty) {
      _didAutoFit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fitBounds();
      });
    }

    final points = _nodePoints.toList(growable: false);

    // Deterministic color per node for clarity
    final palette = <Color>[
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.indigo,
      Colors.lime,
      Colors.amber,
      Colors.brown,
      Colors.deepPurple,
      Colors.deepOrange,
    ];
    Color colorFor(MeshNodeView n) {
      final key = (n.num ?? n.displayName.hashCode) & 0x7fffffff;
      return palette[key % palette.length];
    }

    String _getNodeDebugLabel(int? nodeNum, int? sourceNodeId) {
      if (_activeTrace == null || nodeNum == null) return '';
      if (nodeNum == _activeTrace!.targetNodeId) return ' [Target]';
      if (nodeNum == sourceNodeId) return ' [Source]';
      if (_activeTrace!.ackNodeIds.contains(nodeNum)) return ' [Ack]';
      return '';
    }

    Widget _getNodeIcon(MeshNodeView node, int? sourceNodeId) {
      if (_activeTrace == null) {
        return Icon(Icons.location_pin, size: 36, color: colorFor(node));
      }

      if (node.num == _activeTrace!.targetNodeId) {
        return const Icon(Icons.flag, size: 36, color: Colors.red);
      }

      if (node.num == sourceNodeId) {
        return Icon(
          Icons.play_circle_fill,
          size: 36,
          color: _getTraceStatusColor(_activeTrace!.status),
        );
      }

      if (_activeTrace!.ackNodeIds.contains(node.num) &&
          !(_activeTrace!.route?.contains(node.num) ?? false) &&
          !(_activeTrace!.routeBack?.contains(node.num) ?? false)) {
        return Icon(Icons.recycling, size: 36, color: colorFor(node));
      }

      return Icon(Icons.location_pin, size: 36, color: colorFor(node));
    }

    final sourceNodeId = _activeTrace != null
        ? _getSourceNodeId(_activeTrace!)
        : null;

    if (_activeTrace != null) {
      debugPrint('--- Trace Visualization Debug ---');
      debugPrint('Trace ID: ${_activeTrace!.requestId}');
      debugPrint('Status: ${_activeTrace!.status}');
      debugPrint('Source Node ID: $sourceNodeId');
      debugPrint('Target Node ID: ${_activeTrace!.targetNodeId}');
      debugPrint('Ack Node IDs: ${_activeTrace!.ackNodeIds}');
      debugPrint('Route: ${_activeTrace!.route}');
      debugPrint('-------------------------------');

      // Check if target has position
      final targetPos = _getPos(_activeTrace!.targetNodeId);
      if (targetPos == null && _activeTrace!.status != TraceStatus.completed) {
        // Schedule a warning if we are trying to visualize a trace but target has no location
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                ).targetNodeNoLocation(_activeTrace!.targetNodeId.toString()),
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
        });
      }
    }

    void showNodeSheet(MeshNodeView n, double lat, double lon) {
      showModalBottomSheet(
        context: context,
        useSafeArea: true,
        builder: (ctx) {
          final parts = <Widget>[];
          parts.add(
            Row(
              children: [
                Icon(Icons.location_pin, color: colorFor(n)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    safeText(n.displayName),
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          );
          parts.add(const SizedBox(height: 8));
          final hex = n.num?.toRadixString(16);
          if (hex != null)
            parts.add(Text(AppLocalizations.of(ctx).nodeIdHex(hex)));
          if (n.user?.role != null)
            parts.add(
              Text(
                safeText('${AppLocalizations.of(ctx).role}: ${n.user!.role!}'),
              ),
            );
          if (n.hopsAway != null)
            parts.add(Text('${AppLocalizations.of(ctx).hops}: ${n.hopsAway}'));
          if (n.deviceMetrics?.batteryLevel != null) {
            final lvl = n.deviceMetrics!.batteryLevel!;
            if (lvl == 101) {
              parts.add(
                Text(
                  '${AppLocalizations.of(ctx).battery}: 🔌 ${AppLocalizations.of(ctx).charging}',
                ),
              );
            } else {
              parts.add(Text('${AppLocalizations.of(ctx).battery}: ${lvl}%'));
            }
          }
          if (n.lastHeard != null)
            parts.add(
              Text(
                '${AppLocalizations.of(ctx).lastSeen}: ${_formatLastHeard(ctx, n.lastHeard!)}',
              ),
            );
          parts.add(
            Text(
              '${AppLocalizations.of(ctx).coordinates}: ${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}',
            ),
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...parts,
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {
                        _controller.move(latlng.LatLng(lat, lon), 14);
                        Navigator.of(ctx).maybePop();
                      },
                      icon: const Icon(Icons.center_focus_strong),
                      label: Text(AppLocalizations.of(ctx).center),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        context.read<NodesBloc>().add(
                          NodesDistanceReferenceUpdated(lat: lat, lon: lon),
                        );
                        Navigator.of(ctx).maybePop();
                      },
                      icon: const Icon(Icons.my_location),
                      label: Text(AppLocalizations.of(ctx).useAsRef),
                    ),
                    FilledButton.icon(
                      onPressed: n.num == null
                          ? null
                          : () {
                              Navigator.of(ctx).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      NodeDetailsPage(nodeNum: n.num!),
                                ),
                              );
                            },
                      icon: const Icon(Icons.open_in_new),
                      label: Text(AppLocalizations.of(ctx).details),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: '$lat,$lon'),
                        );
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(ctx).coordsCopied,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_all),
                      label: Text(AppLocalizations.of(ctx).copyCoords),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    final markers = <Marker>[
      for (final p in points)
        Marker(
          point: latlng.LatLng(p.$2, p.$3),
          width: 44,
          height: 44,
          child: Tooltip(
            message:
                '${safeText(p.$1.displayName)}${_getNodeDebugLabel(p.$1.num, sourceNodeId)}',
            child: InkWell(
              onTap: () => showNodeSheet(p.$1, p.$2, p.$3),
              child: _getNodeIcon(p.$1, sourceNodeId),
            ),
          ),
        ),
    ];

    // If source node is known but not in the list (e.g. local node without full info),
    // try to render it using effective distance reference if available.
    if (_activeTrace != null && sourceNodeId != null) {
      final isSourceRendered = points.any((p) => p.$1.num == sourceNodeId);
      if (!isSourceRendered) {
        final eff = _getEffectiveDistanceReference(state);
        if (eff != null) {
          markers.add(
            Marker(
              point: latlng.LatLng(eff.$1, eff.$2),
              width: 44,
              height: 44,
              child: Tooltip(
                message: AppLocalizations.of(context).startLocal,
                child: Icon(
                  Icons.play_circle_fill,
                  size: 36,
                  color: _getTraceStatusColor(_activeTrace!.status),
                ),
              ),
            ),
          );
        }
      }
    }

    final edgeMarkers = _activeTrace != null
        ? _buildTraceEdgeMarkers(_activeTrace!)
        : <Marker>[];

    final eff = _getEffectiveDistanceReference(state);

    return Column(
      children: [
        Row(
          children: [
            if (eff != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.my_location, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${AppLocalizations.of(context).mapRefPrefix}: ${eff.$1.toStringAsFixed(5)}, ${eff.$2.toStringAsFixed(5)}',
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => context.read<NodesBloc>().add(
                        const NodesDistanceReferenceUpdated(
                          lat: null,
                          lon: null,
                        ),
                      ),
                      icon: const Icon(Icons.clear),
                      label: Text(AppLocalizations.of(context).clearRef),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            TextButton.icon(
              onPressed: _fitBounds,
              icon: const Icon(Icons.fit_screen),
              label: Text(AppLocalizations.of(context).fitBounds),
            ),
          ],
        ),
        Expanded(
          child: Stack(
            children: [
              points.isEmpty
                  ? _EmptyMapState(
                      controller: _controller,
                      onLongPress: _onLongPress,
                    )
                  : FlutterMap(
                      mapController: _controller,
                      options: MapOptions(
                        initialCenter: points.isNotEmpty
                            ? latlng.LatLng(points.first.$2, points.first.$3)
                            : const latlng.LatLng(0, 0),
                        initialZoom: 3,
                        onLongPress: _onLongPress,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'ai.bartusiak.mesh.app',
                        ),
                        // Render trace polylines if we have a highlighted trace
                        if (_activeTrace != null)
                          _buildTracePolylineLayer(_activeTrace!),
                        // Trace edge markers (tooltips) - render before nodes so nodes are on top
                        MarkerLayer(markers: edgeMarkers),
                        // Cluster markers that are close to each other for better readability
                        MarkerClusterLayerWidget(
                          options: MarkerClusterLayerOptions(
                            maxClusterRadius: 45,
                            size: const Size(40, 40),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(50),
                            maxZoom: 15,
                            markers: markers,
                            builder: (context, clustered) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.blue,
                                ),
                                child: Center(
                                  child: Text(
                                    clustered.length.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        MapZoomControls(
                          controller: _controller,
                          padding: const EdgeInsets.only(right: 16, bottom: 16),
                        ),
                      ],
                    ),
              if (missingNodes.isNotEmpty)
                Positioned(
                  top: 16,
                  left: 16,
                  right:
                      64, // Leave space for zoom controls/fit button if needed, though they are usually bottom/top-right
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).nodesWithoutLocation,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                ...missingNodes.map(
                                  (n) => InkWell(
                                    onTap: () {
                                      if (n.num != null) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => NodeDetailsPage(
                                              nodeNum: n.num!,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.help_outline,
                                            size: 16,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              safeText(n.displayName),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build markers for trace edges to show tooltips
  List<Marker> _buildTraceEdgeMarkers(TraceResult trace) {
    final markers = <Marker>[];

    // Find local node (start of trace)
    final sourceNodeId = _getSourceNodeId(trace);

    final localPos =
        (sourceNodeId != null ? _getPos(sourceNodeId) : null) ??
        _getEffectiveDistanceReference(context.read<NodesBloc>().state);

    if (localPos != null) {
      var currentPos = localPos;

      // Markers for Route (Forward)
      if (trace.route != null) {
        for (final nodeId in trace.route!) {
          final nextPos = _getPos(nodeId);
          if (nextPos != null) {
            final midLat = (currentPos.$1 + nextPos.$1) / 2;
            final midLon = (currentPos.$2 + nextPos.$2) / 2;
            markers.add(
              Marker(
                point: latlng.LatLng(midLat, midLon),
                width: 20,
                height: 20,
                child: Tooltip(
                  message: AppLocalizations.of(context).traceTooltip,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            );
            currentPos = nextPos;
          }
        }
      }

      // If completed, ensure we connect to target
      if (trace.status == TraceStatus.completed) {
        final targetPos = _getPos(trace.targetNodeId);
        if (targetPos != null) {
          if ((currentPos.$1 - targetPos.$1).abs() > 1e-7 ||
              (currentPos.$2 - targetPos.$2).abs() > 1e-7) {
            final midLat = (currentPos.$1 + targetPos.$1) / 2;
            final midLon = (currentPos.$2 + targetPos.$2) / 2;
            markers.add(
              Marker(
                point: latlng.LatLng(midLat, midLon),
                width: 20,
                height: 20,
                child: Tooltip(
                  message: AppLocalizations.of(context).traceTooltip,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            );
          }
        }
      }

      // Markers for acknowledging nodes
      for (final ackNodeId in trace.ackNodeIds) {
        final ackPos = _getPos(ackNodeId);
        if (ackPos != null) {
          final midLat = (localPos.$1 + ackPos.$1) / 2;
          final midLon = (localPos.$2 + ackPos.$2) / 2;
          markers.add(
            Marker(
              point: latlng.LatLng(midLat, midLon),
              width: 20,
              height: 20,
              child: Tooltip(
                message: AppLocalizations.of(context).ackTooltip,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 12,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }
    return markers;
  }

  /// Build a polyline layer to visualize a trace on the map
  PolylineLayer _buildTracePolylineLayer(TraceResult trace) {
    final polylines = <Polyline>[];

    final sourceNodeId = _getSourceNodeId(trace);

    final localPos =
        (sourceNodeId != null ? _getPos(sourceNodeId) : null) ??
        _getEffectiveDistanceReference(context.read<NodesBloc>().state);

    // Debug logs
    debugPrint(
      'Polyline Debug: sourceNodeId=$sourceNodeId, localPos=$localPos, status=${trace.status}',
    );
    final targetPosDebug = _getPos(trace.targetNodeId);
    debugPrint(
      'Polyline Debug: targetNodeId=${trace.targetNodeId}, targetPos=$targetPosDebug',
    );
    if (localPos == null) {
      debugPrint('Polyline Debug: localPos is NULL');
    }

    if (localPos != null) {
      // Debug 0-hop
      if ((trace.route == null || trace.route!.isEmpty) &&
          trace.status == TraceStatus.completed) {
        debugPrint(
          'Polyline Debug: 0-hop trace detected. Source=$sourceNodeId, Target=${trace.targetNodeId}, Distance=${(localPos.$1 - (targetPosDebug?.$1 ?? 0)).abs() + (localPos.$2 - (targetPosDebug?.$2 ?? 0)).abs()}',
        );
      }

      final color = trace.status == TraceStatus.completed
          ? Colors.green.withOpacity(0.7)
          : trace.status == TraceStatus.failed
          ? Colors.red.withOpacity(0.7)
          : Colors.orange.withOpacity(0.7);

      var currentPos = localPos;

      // Draw Route (Forward)
      if (trace.route != null) {
        for (final nodeId in trace.route!) {
          final nextPos = _getPos(nodeId);
          if (nextPos != null) {
            polylines.add(
              Polyline(
                points: [
                  latlng.LatLng(currentPos.$1, currentPos.$2),
                  latlng.LatLng(nextPos.$1, nextPos.$2),
                ],
                strokeWidth: 3.0,
                color: color,
              ),
            );
            currentPos = nextPos;
          }
        }
      }

      // If completed, ensure we connect to target
      if (trace.status == TraceStatus.completed) {
        final targetPos = _getPos(trace.targetNodeId);
        if (targetPos != null) {
          // Avoid drawing zero-length line if we are already there
          if ((currentPos.$1 - targetPos.$1).abs() > 1e-7 ||
              (currentPos.$2 - targetPos.$2).abs() > 1e-7) {
            polylines.add(
              Polyline(
                points: [
                  latlng.LatLng(currentPos.$1, currentPos.$2),
                  latlng.LatLng(targetPos.$1, targetPos.$2),
                ],
                strokeWidth: 3.0,
                color: color,
              ),
            );
          }
        }
      } else if (trace.status == TraceStatus.timeout ||
          trace.status == TraceStatus.failed ||
          trace.status == TraceStatus.pending) {
        // For failed/timeout/pending traces, draw a dashed line to the target to show the attempt
        final targetPos = _getPos(trace.targetNodeId);
        if (targetPos != null) {
          final dashColor = trace.status == TraceStatus.pending
              ? Colors.orange.withOpacity(0.6)
              : Colors.red.withOpacity(0.7);

          polylines.add(
            Polyline(
              points: [
                latlng.LatLng(currentPos.$1, currentPos.$2),
                latlng.LatLng(targetPos.$1, targetPos.$2),
              ],
              strokeWidth: 2.0,
              color: dashColor,
              pattern: StrokePattern.dashed(segments: const [5.0, 5.0]),
            ),
          );
        }
      }

      // Draw dashed lines to acknowledging nodes (theoretical participants)
      debugPrint(
        'Polyline Debug: Processing ${trace.ackNodeIds.length} ACK nodes',
      );
      for (final ackNodeId in trace.ackNodeIds) {
        // We draw ACK lines even if it's the source node (though it will be a zero-length line)
        // or if it's in the route, to explicitly show the ACK relationship.
        final ackPos = _getPos(ackNodeId);
        debugPrint('Polyline Debug: ACK node $ackNodeId, pos=$ackPos');

        if (ackPos != null) {
          debugPrint(
            'Polyline Debug: Adding ACK line from $localPos to $ackPos',
          );
          polylines.add(
            Polyline(
              points: [
                latlng.LatLng(localPos.$1, localPos.$2),
                latlng.LatLng(ackPos.$1, ackPos.$2),
              ],
              strokeWidth: 2.0,
              color: Colors.green.withOpacity(
                0.6,
              ), // Green for ACKs as requested
              pattern: const StrokePattern.dotted(),
            ),
          );
        } else {
          debugPrint(
            'Polyline Debug: Skipping ACK line for $ackNodeId because position is null',
          );
        }
      }
    }

    return PolylineLayer(polylines: polylines);
  }

  (double, double)? _getEffectiveDistanceReference(NodesState state) {
    if (state.customRefLat != null && state.customRefLon != null) {
      return (state.customRefLat!, state.customRefLon!);
    }
    final localId = state.localNodeId;
    if (localId != null) {
      final node = state.nodes.firstWhereOrNull((n) => n.num == localId);
      if (node?.position?.latitudeI != null &&
          node?.position?.longitudeI != null) {
        return (
          node!.position!.latitudeI! / 1e7,
          node.position!.longitudeI! / 1e7,
        );
      }
    }
    return null;
  }
}

extension _IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class _EmptyMapState extends StatelessWidget {
  final MapController controller;
  final void Function(TapPosition, latlng.LatLng) onLongPress;
  const _EmptyMapState({required this.controller, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: const latlng.LatLng(0, 0),
        initialZoom: 2,
        onLongPress: onLongPress,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'ai.bartusiak.mesh.app',
        ),
        // Friendly empty state overlay
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  AppLocalizations.of(context).noNodesWithLocation,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        MapZoomControls(
          controller: controller,
          padding: const EdgeInsets.only(right: 16, bottom: 16),
        ),
      ],
    );
  }
}
