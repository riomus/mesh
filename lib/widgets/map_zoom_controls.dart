import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapZoomControls extends StatelessWidget {
  final MapController controller;
  final double minZoom;
  final double maxZoom;
  final double zoomStep;
  final Alignment alignment;
  final EdgeInsets padding;

  const MapZoomControls({
    super.key,
    required this.controller,
    this.minZoom = 2,
    this.maxZoom = 19,
    this.zoomStep = 1.0,
    this.alignment = Alignment.bottomRight,
    this.padding = const EdgeInsets.only(right: 12, bottom: 24),
  });

  void _zoomBy(double delta) {
    final camera = controller.camera;
    final newZoom = (camera.zoom + delta).clamp(minZoom, maxZoom).toDouble();
    controller.move(camera.center, newZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ZoomButton(icon: Icons.add, onPressed: () => _zoomBy(zoomStep)),
            const SizedBox(height: 6),
            _ZoomButton(
              icon: Icons.remove,
              onPressed: () => _zoomBy(-zoomStep),
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

  const _ZoomButton({required this.icon, required this.onPressed});

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
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
