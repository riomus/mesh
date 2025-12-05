import 'dart:async';

import 'package:flutter/material.dart';

import '../models/trace_models.dart';
import '../services/traceroute_service.dart';
import '../services/nodes_service.dart';
import '../l10n/app_localizations.dart';

/// Page to display all traceroute history and initiate new traces.
class TracesPage extends StatefulWidget {
  const TracesPage({super.key});

  @override
  State<TracesPage> createState() => _TracesPageState();
}

class _TracesPageState extends State<TracesPage> {
  final _tracerouteService = TracerouteService.instance;
  final _nodesService = NodesService.instance;
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
    // Get all available nodes
    final nodes = await _nodesService.listenAll().first;

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
                  title: Text(node.displayName),
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

    // Send trace request (assuming we have a connected device)
    // TODO: Get actual device ID from connected device
    try {
      // For now, use a placeholder device ID
      // In real implementation, get from DeviceStatusStore
      await _tracerouteService.sendTraceRequest(
        'device_placeholder',
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
          if (trace.hasRoute) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to map and show this trace
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).traceShowOnMap),
                  ),
                );
              },
              icon: const Icon(Icons.map),
              label: Text(AppLocalizations.of(context).traceShowOnMap),
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
