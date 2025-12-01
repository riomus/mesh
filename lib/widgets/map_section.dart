import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

/// Simple reusable map section using flutter_map (OpenStreetMap tiles).
///
/// Expects WGS84 latitude/longitude in degrees.
class MapSection extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? label;
  final double? zoom;
  final double height;
  final bool showScalebar;
  final bool showZoomControls;
  final double minZoom;
  final double maxZoom;
  final double zoomStep;

  const MapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    this.label,
    this.zoom,
    this.height = 220,
    this.showScalebar = true,
    this.showZoomControls = true,
    this.minZoom = 2,
    this.maxZoom = 19,
    this.zoomStep = 1.0,
  });

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  late final MapController _controller = MapController();

  void _zoomBy(double delta) {
    final camera = _controller.camera;
    final newZoom = (camera.zoom + delta)
        .clamp(widget.minZoom, widget.maxZoom)
        .toDouble();
    _controller.move(camera.center, newZoom);
  }

  @override
  Widget build(BuildContext context) {
    final point = latlng.LatLng(widget.latitude, widget.longitude);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: widget.height,
        child: FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: point,
            initialZoom: widget.zoom ?? 13.0,
            minZoom: widget.minZoom,
            maxZoom: widget.maxZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'ai.bartusiak.mesh.app',
            ),
            MarkerLayer(markers: [
              Marker(
                point: point,
                // Give the marker a slightly bigger box and ensure
                // the child always fits without causing RenderFlex overflow.
                width: 48,
                height: 48,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_pin, color: theme.colorScheme.primary, size: 36),
                      if (widget.label != null)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(
                              widget.label!,
                              style: theme.textTheme.labelSmall,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ]),
            if (widget.showScalebar)
              const Scalebar(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.all(8),
              ),
            // Attribution
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.white.withValues(alpha: 0.8),
                child: const Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 10)),
              ),
            ),
            if (widget.showZoomControls)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6, bottom: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ZoomButton(
                        icon: Icons.add,
                        onPressed: () => _zoomBy(widget.zoomStep),
                      ),
                      const SizedBox(height: 6),
                      _ZoomButton(
                        icon: Icons.remove,
                        onPressed: () => _zoomBy(-widget.zoomStep),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ZoomButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

/// Helper to convert Meshtastic fixed-point (1e-7) ints to double degrees.
double? latFromI(int? latitudeI) => latitudeI != null ? latitudeI / 1e7 : null;
double? lonFromI(int? longitudeI) => longitudeI != null ? longitudeI / 1e7 : null;
