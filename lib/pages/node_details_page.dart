import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/nodes/nodes_bloc.dart';
import '../blocs/nodes/nodes_state.dart';
import '../models/mesh_node_view.dart';
import '../utils/text_sanitize.dart';

import '../services/device_status_store.dart';
import 'device_chat_page.dart';
import '../l10n/app_localizations.dart';
import '../widgets/map_zoom_controls.dart';
import '../widgets/telemetry_widget.dart';

/// Detailed view of a single mesh node.
class NodeDetailsPage extends StatefulWidget {
  final int nodeNum; // Node id as integer
  const NodeDetailsPage({super.key, required this.nodeNum});

  @override
  State<NodeDetailsPage> createState() => _NodeDetailsPageState();
}

class _NodeDetailsPageState extends State<NodeDetailsPage> {
  late final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NodesBloc, NodesState>(
      builder: (context, state) {
        final n = state.nodes.firstWhereOrNull((n) => n.num == widget.nodeNum);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              n != null
                  ? safeText(n.displayName)
                  : AppLocalizations.of(
                      context,
                    ).nodeTitleHex(widget.nodeNum.toRadixString(16)),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat),
                tooltip: AppLocalizations.of(context).chat,
                onPressed: () {
                  final device = DeviceStatusStore.instance.connectedDevice;
                  if (device != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DeviceChatPage(
                          deviceId: device.remoteId.str,
                          toNodeId: widget.nodeNum,
                          chatTitle:
                              n?.displayName ??
                              AppLocalizations.of(
                                context,
                              ).nodeTitleHex(widget.nodeNum.toRadixString(16)),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context).meshtasticConnectFailed,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: n == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(safeInitial(n.displayName)),
                            ),
                            title: Text(safeText(n.displayName)),
                            subtitle: Text(
                              AppLocalizations.of(
                                context,
                              ).nodeIdHex(n.num!.toRadixString(16)),
                            ),
                          ),
                        ),
                        Card(
                          child: Column(
                            children: [
                              _infoTile(
                                Icons.badge,
                                AppLocalizations.of(context).role,
                                n.user?.role,
                              ),
                              const Divider(height: 1),
                              _infoTile(
                                Icons.alt_route,
                                AppLocalizations.of(context).hopsAway,
                                n.hopsAway?.toString(),
                              ),
                              const Divider(height: 1),
                              _infoTile(
                                Icons.network_cell,
                                AppLocalizations.of(context).snrLabel,
                                n.snr?.toStringAsFixed(1),
                              ),
                              const Divider(height: 1),
                              _infoTile(
                                Icons.cloud,
                                AppLocalizations.of(context).viaMqtt,
                                n.viaMqtt == true
                                    ? AppLocalizations.of(context).yes
                                    : (n.viaMqtt == false
                                          ? AppLocalizations.of(context).no
                                          : null),
                              ),
                              const Divider(height: 1),
                              _infoTile(
                                Icons.battery_full,
                                AppLocalizations.of(context).battery,
                                _batteryText(n),
                              ),
                              const Divider(height: 1),
                              _infoTile(
                                Icons.access_time,
                                AppLocalizations.of(context).lastSeenLabel,
                                n.lastHeard != null
                                    ? _formatLastHeard(n.lastHeard!)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        _buildLocationSection(n),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.route),
                            title: Text(
                              AppLocalizations.of(context).sourceDevice,
                            ),
                            subtitle: Text(safeText(_sourceDeviceLine(n))),
                          ),
                        ),
                        TelemetryWidget(nodeId: widget.nodeNum),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _infoTile(IconData icon, String title, String? value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(safeText(value ?? '—')),
    );
  }

  String _batteryText(MeshNodeView n) {
    final lvl = n.deviceMetrics?.batteryLevel;
    if (lvl == null) return '—';
    if (lvl == 101) return '🔌 ${AppLocalizations.of(context).charging}';
    return AppLocalizations.of(context).batteryLevel(lvl);
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
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text(AppLocalizations.of(context).location),
              subtitle: null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'lat: ${lat.toStringAsFixed(6)}, lon: ${lon.toStringAsFixed(6)}',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: latlng.LatLng(lat, lon),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'ai.bartusiak.mesh.app',
                  ),

                  MarkerLayer(
                    markers: [
                      Marker(
                        point: latlng.LatLng(lat, lon),
                        width: 44,
                        height: 44,
                        child: const Icon(
                          Icons.location_pin,
                          size: 36,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  MapZoomControls(
                    controller: _mapController,
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    zoomStep: 1.0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }
    // No valid position → show an info card
    return Card(
      child: ListTile(
        leading: Icon(Icons.location_off),
        title: Text(AppLocalizations.of(context).location),
        subtitle: Text(AppLocalizations.of(context).locationUnavailable),
      ),
    );
  }

  String _sourceDeviceLine(MeshNodeView n) {
    final name = _firstOrNull(n.tags['sourceNodeName']);
    final id = _firstOrNull(n.tags['sourceDeviceId']);
    final short = id != null ? _shortId(id) : null;
    if (name != null && short != null)
      return AppLocalizations.of(context).viaNameId(name, short);
    if (name != null) return AppLocalizations.of(context).viaName(name);
    if (short != null) return AppLocalizations.of(context).viaId(short);
    return '—';
  }

  String? _firstOrNull(List<String>? vs) =>
      (vs == null || vs.isEmpty) ? null : vs.first;

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
}

extension _IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
