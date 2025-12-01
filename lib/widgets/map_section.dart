import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

/// Simple reusable map section using flutter_map (OpenStreetMap tiles).
///
/// Expects WGS84 latitude/longitude in degrees.
class MapSection extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? label;
  final double? zoom;
  final double height;

  const MapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    this.label,
    this.zoom,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final point = latlng.LatLng(latitude, longitude);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: zoom ?? 13.0,
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
                width: 40,
                height: 40,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_pin, color: theme.colorScheme.primary, size: 36),
                    if (label != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          label!,
                          style: theme.textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ]),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.white.withOpacity(0.8),
                child: const Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper to convert Meshtastic fixed-point (1e-7) ints to double degrees.
double? latFromI(int? latitudeI) => latitudeI != null ? latitudeI / 1e7 : null;
double? lonFromI(int? longitudeI) => longitudeI != null ? longitudeI / 1e7 : null;
