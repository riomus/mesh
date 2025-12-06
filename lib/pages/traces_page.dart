import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/nodes/nodes_bloc.dart';

import '../models/trace_models.dart';
import '../services/traceroute_service.dart';
import '../models/mesh_node_view.dart';
import '../services/device_status_store.dart';
import '../l10n/app_localizations.dart';
import '../utils/text_sanitize.dart';
import 'nodes_page.dart';

/// Page to display all traceroute history and initiate new traces.
class TracesPage extends StatefulWidget {
  const TracesPage({super.key});

  @override
  State<TracesPage> createState() => _TracesPageState();
}

class _TracesPageState extends State<TracesPage> {
  final _tracerouteService = TracerouteService.instance;
  StreamSubscription<List<TraceResult>>? _traceSub;
  List<TraceResult> _traces = [];

  @override
  void initState() {
    super.initState();
    // Load initial traces
    _traces = _tracerouteService.getAllTraces();
    // Subscribe to updates
    _traceSub = _tracerouteService.listenAllTraces().listen((traces) {
      if (!mounted) return;
      setState(() {
        _traces = traces;
      });
    });
  }

  @override
  void dispose() {
    _traceSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).traces),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context).refresh,
            onPressed: () {
              setState(() {
                _traces = _tracerouteService.getAllTraces();
              });
            },
          ),
        ],
      ),
      body: _traces.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _traces.length,
              itemBuilder: (context, index) {
                return _TraceCard(trace: _traces[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'traces_fab',
        onPressed: () => _showNodePicker(context),
        icon: const Icon(Icons.route),
        label: Text(AppLocalizations.of(context).startTrace),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.explore_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).traceNoHistory,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showNodePicker(context),
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context).startTrace),
          ),
        ],
      ),
    );
  }

  Future<void> _showNodePicker(BuildContext context) async {
    // First, get all connected devices
    final store = DeviceStatusStore.instance;
    final connectedDeviceIds = store.connectedDeviceIds;

    if (!mounted) return;

    if (connectedDeviceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noDeviceConnected),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // If multiple devices, let user select device first
    String? selectedDeviceId;
    if (connectedDeviceIds.length > 1) {
      selectedDeviceId = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).selectDevice),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: connectedDeviceIds.length,
                itemBuilder: (context, index) {
                  final deviceId = connectedDeviceIds[index];
                  final deviceName = store.getDeviceName(deviceId) ?? deviceId;
                  return ListTile(
                    leading: Icon(
                      deviceId.startsWith('IP:')
                          ? Icons.wifi
                          : deviceId.startsWith('USB:')
                          ? Icons.usb
                          : Icons.bluetooth,
                    ),
                    title: Text(safeText(deviceName)),
                    subtitle: Text(deviceId),
                    onTap: () => Navigator.of(context).pop(deviceId),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).cancel),
              ),
            ],
          );
        },
      );
    } else {
      // Only one device connected, use it
      selectedDeviceId = connectedDeviceIds.first;
    }

    if (selectedDeviceId == null) return;
    if (!mounted) return;

    // Now get nodes for this device using NodesBloc
    final nodes = context.read<NodesBloc>().state.nodes;

    if (!mounted) return;

    if (nodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).noNodesAvailable)),
      );
      return;
    }

    // Show dialog to select target node
    final selectedNode = await showDialog<MeshNodeView>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).traceSelectNode),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: nodes.length,
              itemBuilder: (context, index) {
                final node = nodes[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      node.displayName.isNotEmpty
                          ? node.displayName[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(safeText(node.displayName)),
                  subtitle: Text('ID: ${node.num}'),
                  onTap: () => Navigator.of(context).pop(node),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).cancel),
            ),
          ],
        );
      },
    );

    if (selectedNode == null || selectedNode.num == null) return;

    if (!mounted) return;

    // Send trace request with selected device and node
    try {
      await _tracerouteService.sendTraceRequest(
        selectedDeviceId,
        selectedNode.num!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).traceSent)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

/// Card widget to display a single trace result
class _TraceCard extends StatefulWidget {
  final TraceResult trace;

  const _TraceCard({required this.trace});

  @override
  State<_TraceCard> createState() => _TraceCardState();
}

class _TraceCardState extends State<_TraceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final trace = widget.trace;
    final statusColor = _getStatusColor(trace.status);
    final statusText = _getStatusText(context, trace.status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(_getStatusIcon(trace.status), color: statusColor),
            title: Text(
              '${AppLocalizations.of(context).traceTarget}: ${trace.targetNodeId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusText),
                Text(
                  _formatTimestamp(trace.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (trace.hasRoute)
                  Text(
                    AppLocalizations.of(
                      context,
                    ).traceHopCount(trace.hopCount ?? 0),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded) _buildExpandedContent(context, trace),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, TraceResult trace) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trace.hasRoute) ...[
            Text(
              AppLocalizations.of(context).traceForwardRoute,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            _buildRouteDisplay(trace.route!, trace.snrTowards),
            const SizedBox(height: 12),
          ],
          if (trace.hasRouteBack) ...[
            Text(
              AppLocalizations.of(context).traceReturnRoute,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            _buildRouteDisplay(trace.routeBack!, trace.snrBack),
            const SizedBox(height: 12),
          ],
          Text(
            AppLocalizations.of(context).traceEvents,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          ...trace.events.map((event) => _buildEventTile(context, event)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Nodes page, map tab, with this trace highlighted
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NodesPage(
                    highlightedTrace: trace,
                    initialTabIndex: 1, // Start on map tab
                  ),
                ),
              );
            },
            icon: const Icon(Icons.map),
            label: Text(AppLocalizations.of(context).traceShowOnMap),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDisplay(List<int> route, List<int>? snrValues) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(route.length, (index) {
        final nodeId = route[index];
        final snr = snrValues != null && index < snrValues.length
            ? (snrValues[index] / 4.0).toStringAsFixed(1)
            : null;

        return Chip(
          label: Text(
            snr != null ? '$nodeId (${snr}dB)' : '$nodeId',
            style: const TextStyle(fontSize: 12),
          ),
          avatar: index < route.length - 1
              ? const Icon(Icons.arrow_forward, size: 16)
              : null,
        );
      }),
    );
  }

  Widget _buildEventTile(BuildContext context, TraceEvent event) {
    final hasData = event.data != null && event.data!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getEventIcon(event.type),
                size: 16,
                color: _getEventColor(event.type),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _formatTime(event.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasData)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 4),
              child: _buildEventData(context, event.data!),
            ),
        ],
      ),
    );
  }

  Widget _buildEventData(BuildContext context, Map<String, dynamic> data) {
    final entries = data.entries.where((e) {
      // Filter out complex objects we don't want to show in the simple list
      // or that are already shown elsewhere (like route/routeBack)
      return !['route', 'routeBack', 'snrTowards', 'snrBack'].contains(e.key);
    }).toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries.map((e) {
          String valueStr = e.value.toString();
          if (e.key == 'rxRssi' || e.key == 'rxSnr') {
            // Add units if missing
            if (e.key == 'rxRssi') valueStr += ' dBm';
            if (e.key == 'rxSnr') valueStr += ' dB';
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                Text(
                  '${e.key}: ',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Text(
                    valueStr,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(TraceStatus status) {
    switch (status) {
      case TraceStatus.pending:
        return Colors.orange;
      case TraceStatus.completed:
        return Colors.green;
      case TraceStatus.failed:
        return Colors.red;
      case TraceStatus.timeout:
        return Colors.grey;
    }
  }

  String _getStatusText(BuildContext context, TraceStatus status) {
    switch (status) {
      case TraceStatus.pending:
        return AppLocalizations.of(context).tracePending;
      case TraceStatus.completed:
        return AppLocalizations.of(context).traceCompleted;
      case TraceStatus.failed:
        return AppLocalizations.of(context).traceFailed;
      case TraceStatus.timeout:
        return AppLocalizations.of(context).traceTimeout;
    }
  }

  IconData _getStatusIcon(TraceStatus status) {
    switch (status) {
      case TraceStatus.pending:
        return Icons.pending;
      case TraceStatus.completed:
        return Icons.check_circle;
      case TraceStatus.failed:
        return Icons.error;
      case TraceStatus.timeout:
        return Icons.timer_off;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'sent':
        return Icons.send;
      case 'ack':
        return Icons.done;
      case 'route_update':
        return Icons.update;
      case 'route_reply':
        return Icons.reply;
      case 'completed':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'timeout':
        return Icons.timer_off;
      default:
        return Icons.info;
    }
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'sent':
        return Colors.blue;
      case 'ack':
        return Colors.green;
      case 'route_update':
        return Colors.orange;
      case 'route_reply':
        return Colors.lightGreen;
      case 'completed':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'timeout':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}';
    }
  }

  String _formatTime(DateTime dt) {
    return '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
