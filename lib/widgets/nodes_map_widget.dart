import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../services/nodes_service.dart';

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

  @override
  void initState() {
    super.initState();
    _sub = _svc.listenAll().listen((value) {
      setState(() {
        _nodes = value;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Iterable<(double lat, double lon, String label)> get _nodePoints sync* {
    for (final n in _nodes) {
      final p = n.position;
      if (p?.latitudeI != null && p?.longitudeI != null) {
        yield (p!.latitudeI! / 1e7, p.longitudeI! / 1e7, n.displayName);
      }
    }
  }

  void _fitBounds() {
    final pts = _nodePoints.toList(growable: false);
    if (pts.isEmpty) return;
    double minLat = pts.first.$1, maxLat = pts.first.$1, minLon = pts.first.$2, maxLon = pts.first.$2;
    for (final p in pts) {
      minLat = p.$1 < minLat ? p.$1 : minLat;
      maxLat = p.$1 > maxLat ? p.$1 : maxLat;
      minLon = p.$2 < minLon ? p.$2 : minLon;
      maxLon = p.$2 > maxLon ? p.$2 : maxLon;
    }
    final center = latlng.LatLng((minLat + maxLat) / 2, (minLon + maxLon) / 2);
    _controller.move(center, 10);
  }

  void _onLongPress(TapPosition tapPosition, latlng.LatLng point) {
    _svc.setCustomDistanceReference(lat: point.latitude, lon: point.longitude);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Custom distance reference set to ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final points = _nodePoints.toList(growable: false);
    final markers = points
        .map((p) => Marker(
              point: latlng.LatLng(p.$1, p.$2),
              width: 40,
              height: 40,
              child: Tooltip(
                message: p.$3,
                child: Icon(Icons.location_pin, size: 32, color: theme.colorScheme.primary),
              ),
            ))
        .toList(growable: false);

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
                  Text('Ref: ${eff.$1.toStringAsFixed(5)}, ${eff.$2.toStringAsFixed(5)}'),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => setState(() => _svc.setCustomDistanceReference(lat: null, lon: null)),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear ref'),
                  ),
                ]),
              ),
            const Spacer(),
            TextButton.icon(
              onPressed: _fitBounds,
              icon: const Icon(Icons.fit_screen),
              label: const Text('Fit bounds'),
            ),
          ],
        ),
        Expanded(
          child: FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: points.isNotEmpty
                  ? latlng.LatLng(points.first.$1, points.first.$2)
                  : const latlng.LatLng(0, 0),
              initialZoom: 3,
              onLongPress: _onLongPress,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ai.bartusiak.mesh.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
