import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../services/nodes_service.dart';
import '../utils/text_sanitize.dart';

/// Detailed view of a single mesh node.
class NodeDetailsPage extends StatefulWidget {
  final int nodeNum; // Node id as integer
  const NodeDetailsPage({super.key, required this.nodeNum});

  @override
  State<NodeDetailsPage> createState() => _NodeDetailsPageState();
}

class _NodeDetailsPageState extends State<NodeDetailsPage> {
  final _svc = NodesService.instance;
  StreamSubscription<List<MeshNodeView>>? _sub;
  MeshNodeView? _node;

  @override
  void initState() {
    super.initState();
    // Prefill immediately from current snapshot so we don't show an indefinite
    // loader when the node is already known.
    _prefillFromSnapshot();
    _sub = _svc.listenAll().listen((list) {
      if (!mounted) return;
      final match = list.firstWhere(
        (n) => n.num == widget.nodeNum,
        orElse: () => const MeshNodeView(
          num: null,
          user: null,
          position: null,
          snr: null,
          lastHeard: null,
          deviceMetrics: null,
          hopsAway: null,
          isFavorite: null,
          isIgnored: null,
          viaMqtt: null,
          tags: <String, List<String>>{},
        ),
      );
      setState(() {
        _node = match.num == null ? null : match;
      });
    });
  }

  void _prefillFromSnapshot() {
    final list = _svc.snapshot;
    if (list.isEmpty) return;
    final match = list.firstWhere(
      (n) => n.num == widget.nodeNum,
      orElse: () => const MeshNodeView(
        num: null,
        user: null,
        position: null,
        snr: null,
        lastHeard: null,
        deviceMetrics: null,
        hopsAway: null,
        isFavorite: null,
        isIgnored: null,
        viaMqtt: null,
        tags: <String, List<String>>{},
      ),
    );
    if (match.num != null && mounted) {
      setState(() {
        _node = match;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = _node;
    return Scaffold(
      appBar: AppBar(
        title: Text(n != null ? safeText(n.displayName) : 'Node 0x${widget.nodeNum.toRadixString(16)}'),
      ),
      body: n == null
          ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(safeInitial(n.displayName))),
                    title: Text(safeText(n.displayName)),
                    subtitle: Text('ID: 0x${n.num!.toRadixString(16)}'),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      _infoTile(Icons.badge, 'Role', n.user?.role),
                      const Divider(height: 1),
                      _infoTile(Icons.alt_route, 'Hops away', n.hopsAway?.toString()),
                      const Divider(height: 1),
                      _infoTile(Icons.network_cell, 'SNR', n.snr?.toStringAsFixed(1)),
                      const Divider(height: 1),
                      _infoTile(Icons.cloud, 'via MQTT', n.viaMqtt == true ? 'yes' : (n.viaMqtt == false ? 'no' : null)),
                      const Divider(height: 1),
                      _infoTile(Icons.battery_full, 'Battery', _batteryText(n)),
                      const Divider(height: 1),
                      _infoTile(Icons.access_time, 'Last seen', n.lastHeard != null ? _formatLastHeard(n.lastHeard!) : null),
                    ],
                  ),
                ),
                _buildLocationSection(n),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.route),
                    title: const Text('Source device'),
                    subtitle: Text(_sourceDeviceLine(n)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _infoTile(IconData icon, String title, String? value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value ?? '—'),
    );
  }

  String _batteryText(MeshNodeView n) {
    final lvl = n.deviceMetrics?.batteryLevel;
    if (lvl == null) return '—';
    if (lvl == 101) return '🔌 charging';
    return '🔋${lvl}%';
  }

  // ===== Location & Map =====
  bool _hasValidPosition(MeshNodeView n) {
    final latI = n.position?.latitudeI;
    final lonI = n.position?.longitudeI;
    if (latI == null || lonI == null) return false;
    final lat = latI / 1e7;
    final lon = lonI / 1e7;
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }

  Widget _buildLocationSection(MeshNodeView n) {
    if (_hasValidPosition(n)) {
      final lat = n.position!.latitudeI! / 1e7;
      final lon = n.position!.longitudeI! / 1e7;
      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Location'),
              subtitle: null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('lat: ${lat.toStringAsFixed(6)}, lon: ${lon.toStringAsFixed(6)}'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: latlng.LatLng(lat, lon),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'ai.bartusiak.mesh.app',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: latlng.LatLng(lat, lon),
                      width: 44,
                      height: 44,
                      child: const Icon(Icons.location_pin, size: 36, color: Colors.red),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }
    // No valid position → show an info card
    return const Card(
      child: ListTile(
        leading: Icon(Icons.location_off),
        title: Text('Location'),
        subtitle: Text('Location is not available for this node'),
      ),
    );
  }

  String _sourceDeviceLine(MeshNodeView n) {
    final name = _firstOrNull(n.tags['sourceNodeName']);
    final id = _firstOrNull(n.tags['sourceDeviceId']);
    final short = id != null ? _shortId(id) : null;
    if (name != null && short != null) return 'via $name (0x$short)';
    if (name != null) return 'via $name';
    if (short != null) return 'via 0x$short';
    return '—';
  }

  String? _firstOrNull(List<String>? vs) => (vs == null || vs.isEmpty) ? null : vs.first;

  // Take last 4 hex digits if looks like hex, otherwise last 4 characters
  String _shortId(String raw) {
    final cleaned = raw.toLowerCase().replaceAll('0x', '');
    final isHex = RegExp(r'^[0-9a-f]+$').hasMatch(cleaned);
    final s = isHex ? cleaned : raw;
    return s.length <= 4 ? s : s.substring(s.length - 4);
  }

  // Same rule as list/map: show relative <2d, else full local date/time with (Xd ago)
  String _formatLastHeard(int secondsAgo) {
    const twoDays = 2 * 24 * 60 * 60;
    if (secondsAgo < twoDays) {
      if (secondsAgo < 60) return '${secondsAgo}s ago';
      final minutes = secondsAgo ~/ 60;
      if (minutes < 60) return '${minutes}m ago';
      final hours = minutes ~/ 60;
      if (hours < 24) return '${hours}h ago';
      final days = hours ~/ 24;
      return '${days}d ago';
    }
    final dt = DateTime.now().subtract(Duration(seconds: secondsAgo));
    String two(int n) => n.toString().padLeft(2, '0');
    final relDays = secondsAgo ~/ (24 * 60 * 60);
    final dateStr = '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
    return '$dateStr (${relDays}d ago)';
  }
}
