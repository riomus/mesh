import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../services/nodes_service.dart';
import '../utils/text_sanitize.dart';
import '../pages/node_details_page.dart';
import '../l10n/app_localizations.dart';

class NodesMapWidget extends StatefulWidget {
  const NodesMapWidget({super.key});

  @override
  State<NodesMapWidget> createState() => _NodesMapWidgetState();
}

class _NodesMapWidgetState extends State<NodesMapWidget>
    with AutomaticKeepAliveClientMixin {
  final _svc = NodesService.instance;
  late final MapController _controller = MapController();

  List<MeshNodeView> _nodes = const <MeshNodeView>[];
  StreamSubscription<List<MeshNodeView>>? _sub;
  bool _didAutoFit = false;

  @override
  void initState() {
    super.initState();
    // Prefill from current snapshot so we don't flash an empty map when
    // nodes are already known (e.g., coming from the List tab)
    final snap = _svc.snapshot;
    if (snap.isNotEmpty) {
      _nodes = snap;
      // If we already have points from the snapshot, schedule an initial fit
      // to make the view immediately useful.
      if (_nodePoints.isNotEmpty) {
        _didAutoFit = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _fitBounds();
        });
      }
    }
    _sub = _svc.listenAll().listen((value) {
      // Guard against setState after dispose if an event lands late
      if (!mounted) return;
      setState(() {
        _nodes = value;
      });
      // One-time auto-fit when first non-empty set of nodes with location arrives
      if (!_didAutoFit) {
        final hasAny = _nodePoints.isNotEmpty;
        if (hasAny) {
          _didAutoFit = true;
          // Schedule after this frame so controller is ready
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _fitBounds();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Iterable<(MeshNodeView node, double lat, double lon)> get _nodePoints sync* {
    for (final n in _nodes) {
      final p = n.position;
      if (p?.latitudeI != null && p?.longitudeI != null) {
        final lat = p!.latitudeI! / 1e7;
        final lon = p.longitudeI! / 1e7;
        // Defensive filtering: ignore impossible coordinates
        if (lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180) {
          yield (n, lat, lon);
        }
      }
    }
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
      double minLat = pts.first.$2, maxLat = pts.first.$2, minLon = pts.first.$3, maxLon = pts.first.$3;
      for (final p in pts) {
        minLat = p.$2 < minLat ? p.$2 : minLat;
        maxLat = p.$2 > maxLat ? p.$2 : maxLat;
        minLon = p.$3 < minLon ? p.$3 : minLon;
        maxLon = p.$3 > maxLon ? p.$3 : maxLon;
      }
      final center = latlng.LatLng((minLat + maxLat) / 2, (minLon + maxLon) / 2);
      _controller.move(center, 10);
    }
  }

  void _onLongPress(TapPosition tapPosition, latlng.LatLng point) {
    _svc.setCustomDistanceReference(lat: point.latitude, lon: point.longitude);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).customRefSet(point.latitude.toStringAsFixed(5), point.longitude.toStringAsFixed(5))))
    );
  }

  String _formatLastHeard(BuildContext context, int secondsAgo) {
    const twoDays = 2 * 24 * 60 * 60; // 172800
    if (secondsAgo < twoDays) {
      if (secondsAgo < 60) return AppLocalizations.of(context).agoSeconds(secondsAgo);
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
    final dateStr = '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
    return '$dateStr (${AppLocalizations.of(context).agoDays(relDays)})';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final points = _nodePoints.toList(growable: false);

    // Deterministic color per node for clarity
    final palette = <Color>[
      Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.pink, Colors.teal, Colors.cyan, Colors.indigo, Colors.lime,
      Colors.amber, Colors.brown, Colors.deepPurple, Colors.deepOrange,
    ];
    Color colorFor(MeshNodeView n) {
      final key = (n.num ?? n.displayName.hashCode) & 0x7fffffff;
      return palette[key % palette.length];
    }

    void showNodeSheet(MeshNodeView n, double lat, double lon) {
      showModalBottomSheet(
        context: context,
        useSafeArea: true,
        builder: (ctx) {
          final parts = <Widget>[];
          parts.add(Row(
            children: [
              Icon(Icons.location_pin, color: colorFor(n)),
              const SizedBox(width: 8),
              Expanded(child: Text(safeText(n.displayName), style: Theme.of(ctx).textTheme.titleMedium)),
            ],
          ));
          parts.add(const SizedBox(height: 8));
          final hex = n.num?.toRadixString(16);
          if (hex != null) parts.add(Text('ID: 0x$hex'));
          if (n.user?.role != null) parts.add(Text(safeText('${AppLocalizations.of(ctx).role}: ${n.user!.role!}')));
          if (n.hopsAway != null) parts.add(Text('${AppLocalizations.of(ctx).hops}: ${n.hopsAway}'));
          if (n.deviceMetrics?.batteryLevel != null) {
            final lvl = n.deviceMetrics!.batteryLevel!;
            if (lvl == 101) {
              parts.add(Text('${AppLocalizations.of(ctx).battery}: 🔌 ${AppLocalizations.of(ctx).charging}'));
            } else {
              parts.add(Text('${AppLocalizations.of(ctx).battery}: ${lvl}%'));
            }
          }
          if (n.lastHeard != null) parts.add(Text('${AppLocalizations.of(ctx).lastSeen}: ${_formatLastHeard(ctx, n.lastHeard!)}'));
          parts.add(Text('${AppLocalizations.of(ctx).coordinates}: ${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}'));

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...parts,
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
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
                      _svc.setCustomDistanceReference(lat: lat, lon: lon);
                      Navigator.of(ctx).maybePop();
                    },
                    icon: const Icon(Icons.my_location),
                    label: Text(AppLocalizations.of(ctx).useAsRef),
                  ),
                  FilledButton.icon(
                    onPressed: n.num == null
                        ? null
                        : () {
                            // Close the bottom sheet first, then open details
                            Navigator.of(ctx).maybePop();
                            Future.microtask(() {
                              if (!mounted) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => NodeDetailsPage(nodeNum: n.num!),
                                ),
                              );
                            });
                          },
                      icon: const Icon(Icons.open_in_new),
                      label: Text(AppLocalizations.of(ctx).details),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: '$lat,$lon'));
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(ctx).coordsCopied)),
                        );
                      },
                      icon: const Icon(Icons.copy_all),
                      label: Text(AppLocalizations.of(ctx).copyCoords),
                    ),
                  ]),
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
            message: safeText(p.$1.displayName),
            child: InkWell(
              onTap: () => showNodeSheet(p.$1, p.$2, p.$3),
              child: Icon(Icons.location_pin, size: 36, color: colorFor(p.$1)),
            ),
          ),
        ),
    ];

    final eff = _svc.effectiveDistanceReference;

    return Column(
      children: [
        Row(
          children: [
            if (eff != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(children: [
                  const Icon(Icons.my_location, size: 16),
                  const SizedBox(width: 4),
                  Text('${AppLocalizations.of(context).mapRefPrefix}: ${eff.$1.toStringAsFixed(5)}, ${eff.$2.toStringAsFixed(5)}'),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _svc.setCustomDistanceReference(lat: null, lon: null),
                    icon: const Icon(Icons.clear),
                    label: Text(AppLocalizations.of(context).clearRef),
                  ),
                ]),
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
          child: points.isEmpty
              ? _EmptyMapState(onLongPress: _onLongPress)
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
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ai.bartusiak.mesh.app',
              ),
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
            ],
          ),
        ),
      ],
      );
  }

  @override
  bool get wantKeepAlive => true;
}

class _EmptyMapState extends StatelessWidget {
  final void Function(TapPosition, latlng.LatLng) onLongPress;
  const _EmptyMapState({required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
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
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(AppLocalizations.of(context).noNodesWithLocation, textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


