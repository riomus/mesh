import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../l10n/app_localizations.dart';
import '../widgets/rssi_bar.dart';
import '../config/manufacturer_db.dart';
import '../services/meshtastic_ble_client.dart';
import '../services/logging_service.dart';
import '../widgets/logs_viewer.dart';
import '../widgets/mesh_app_bar.dart';
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../widgets/meshtastic_event_tiles.dart';

class DeviceDetailsPage extends StatefulWidget {
  final ScanResult result;
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(BuildContext context)? onOpenSettings;
  const DeviceDetailsPage({super.key, required this.result, this.onToggleTheme, this.themeMode, this.onOpenSettings});

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  MeshtasticBleClient? _client;
  bool _connecting = false;
  bool _connected = false;
  // Logs are now shown via reusable LogsViewer widget; no manual buffering here.
  StreamSubscription<LogEvent>? _logSub; // kept for backwards-compat, but unused
  // Stable device-scoped log stream (with replay) to avoid re-subscribe on rebuilds
  Stream<LogEvent>? _deviceLogStream;
  // Capture high-level Meshtastic events for UI
  final List<MeshtasticEvent> _events = [];
  StreamSubscription<MeshtasticEvent>? _eventsSub;

  String _bestName(ScanResult r) {
    if (r.advertisementData.advName.isNotEmpty) return r.advertisementData.advName;
    if (r.device.platformName.isNotEmpty) return r.device.platformName;
    return r.device.remoteId.str;
  }

  @override
  void initState() {
    super.initState();
    _initDeviceLogStream();
  }

  void _initDeviceLogStream() {
    final deviceId = widget.result.device.remoteId.str;
    _deviceLogStream = LoggingService.instance.listenWithReplay(
      takeLast: 200,
      allEquals: {
        'network': 'meshtastic',
        'deviceId': deviceId,
      },
    );
  }

  @override
  void didUpdateWidget(covariant DeviceDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldId = oldWidget.result.device.remoteId.str;
    final newId = widget.result.device.remoteId.str;
    if (oldId != newId) {
      _initDeviceLogStream();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _logSub?.cancel();
    _eventsSub?.cancel();
    _client?.dispose();
    super.dispose();
  }

  ScanResult get result => widget.result;

  @override
  Widget build(BuildContext context) {
    final ad = result.advertisementData;
    final device = result.device;

    final hasMeshtasticService = ad.serviceUuids
        .any((g) => g.str.toLowerCase() == MeshtasticBleClient.serviceUuid);

    return Scaffold(
      appBar: MeshAppBar(
        title: Text(_bestName(result)),
        onToggleTheme: widget.onToggleTheme,
        themeMode: widget.themeMode,
        onOpenSettings: widget.onOpenSettings,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          // General section
          _Section(
            title: AppLocalizations.of(context)!.general,
            children: [
              ListTile(
                leading: const Icon(Icons.bluetooth),
                title: Text(AppLocalizations.of(context)!.identifier),
                subtitle: Text(device.remoteId.str),
              ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: Text(AppLocalizations.of(context)!.platformName),
                subtitle: Text(device.platformName.isNotEmpty ? device.platformName : '—'),
              ),
              ListTile(
                leading: const Icon(Icons.network_cell),
                title: Text(AppLocalizations.of(context)!.signalRssi),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: RssiBar(rssi: result.rssi),
                ),
                trailing: Text('${result.rssi} dBm'),
              ),
            ],
          ),
          // Meshtastic section
          _Section(
            title: 'Meshtastic',
            children: [
              ListTile(
                leading: const Icon(Icons.memory),
                title: const Text('Service available'),
                subtitle: Text(hasMeshtasticService ? 'Yes' : 'No'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(_connected ? Icons.link_off : Icons.link),
                      label: Text(_connected
                          ? AppLocalizations.of(context)!.disconnect
                          : AppLocalizations.of(context)!.connect),
                      // Allow connect even if Meshtastic service is not advertised.
                      // We will attempt to connect and fail gracefully with an error message if
                      // the required service/characteristics are not discovered.
                      onPressed: () async {
                        if (_connected || _connecting) {
                          await _disconnectMeshtastic();
                        } else {
                          await _connectMeshtastic();
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    if (_connecting) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _connected
                            ? 'Connected'
                            : _connecting
                                ? 'Connecting...'
                                : 'Disconnected',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Logs (scoped to this device) using shared LogsViewer
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.list_alt),
                        const SizedBox(width: 8),
                        Text('Logs', style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: LogsViewer(
                        key: ValueKey('deviceLogs-' + result.device.remoteId.str),
                        maxHeight: 160,
                        stream: _deviceLogStream,
                      ),
                    ),
                  ],
                ),
              ),
              // Live Meshtastic events viewer
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text('Live events (${_events.length})',
                            style: Theme.of(context).textTheme.titleSmall),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Clear',
                          onPressed: _events.isEmpty
                              ? null
                              : () {
                                      setState(() => _events.clear());
                                    },
                          icon: const Icon(Icons.clear_all),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      height: 220, // Give inner ListView a bounded height to avoid layout exceptions
                      child: _events.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('No events received yet'),
                              ),
                            )
                          : ListView.builder(
                              // Nested scrollable inside parent ListView
                              // must be non-primary and have its own physics
                              primary: false,
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _events.length,
                              itemBuilder: (context, index) {
                                final ev = _events[index];
                                return MeshtasticEventTile(event: ev);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Advertisement section
          _Section(
            title: AppLocalizations.of(context)!.advertisement,
            children: [
              ListTile(
                leading: const Icon(Icons.label),
                title: Text(AppLocalizations.of(context)!.advertisedName),
                subtitle: Text(ad.advName.isNotEmpty ? ad.advName : '—'),
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: Text(AppLocalizations.of(context)!.connectable),
                subtitle: Text(ad.connectable
                    ? AppLocalizations.of(context)!.yes
                    : AppLocalizations.of(context)!.no),
              ),
              // Service UUIDs
              if (ad.serviceUuids.isNotEmpty)
                _ExpandableMap<List<Guid>>(
                  icon: Icons.widgets,
                  title: AppLocalizations.of(context)!
                      .serviceUuidsWithCount(ad.serviceUuids.length),
                  items: {
                    for (var i = 0; i < ad.serviceUuids.length; i++)
                      '${AppLocalizations.of(context)!.service} ${i + 1}': [ad.serviceUuids[i]]
                  },
                  valueBuilder: (gList) => gList.map((g) => g.str).join(', '),
                )
              else
                ListTile(
                  leading: const Icon(Icons.widgets),
                  title: Text(AppLocalizations.of(context)!.serviceUuids),
                  subtitle: Text(AppLocalizations.of(context)!.noneAdvertised),
                ),
              // Manufacturer Data
              if (ad.manufacturerData.isNotEmpty)
                _ExpandableMap<List<int>>(
                  icon: Icons.factory,
                  title: AppLocalizations.of(context)!
                      .manufacturerDataWithCount(ad.manufacturerData.length),
                  items: ad.manufacturerData.map((k, v) => MapEntry(_manufacturerKey(k), v)),
                  valueBuilder: (bytes) => _hex(bytes),
                )
              else
                ListTile(
                  leading: const Icon(Icons.factory),
                  title: Text(AppLocalizations.of(context)!.manufacturerData),
                  subtitle: Text(AppLocalizations.of(context)!.noneAdvertised),
                ),
              // Service Data
              if (ad.serviceData.isNotEmpty)
                _ExpandableMap<List<int>>(
                  icon: Icons.storage,
                  title:
                      AppLocalizations.of(context)!.serviceDataWithCount(ad.serviceData.length),
                  items: ad.serviceData.map((k, v) => MapEntry(k.str, v)),
                  valueBuilder: (bytes) => _hex(bytes),
                )
              else
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: Text(AppLocalizations.of(context)!.serviceData),
                  subtitle: Text(AppLocalizations.of(context)!.noneAdvertised),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static String _hex(List<int> bytes) {
    if (bytes.isEmpty) return '—';
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
      sb.write(' ');
    }
    return sb.toString().trim().toUpperCase();
  }

  static String _manufacturerKey(int id) {
    final name = ManufacturerDb.nameNow(id);
    final idHex = '0x${id.toRadixString(16).padLeft(4, '0').toUpperCase()}';
    return name != null ? '$name ($idHex)' : idHex;
  }

  Future<void> _connectMeshtastic() async {
    setState(() {
      _connecting = true;
      _events.clear();
    });
    try {
      final client = MeshtasticBleClient(widget.result.device);
      // Logs are displayed via LogsViewer widget; no explicit subscription here.
      // subscribe to incoming packets
      _eventsSub?.cancel();
      _eventsSub = client.events.listen((e) {
        setState(() {
          _events.add(e);
          if (_events.length > 200) {
            _events.removeRange(0, _events.length - 200);
          }
        });
      });
      await client.connect();
      setState(() {
        _client = client;
        _connected = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meshtastic connect failed: $e')),
        );
      }
      await _client?.dispose();
      await _logSub?.cancel();
      await _eventsSub?.cancel();
      setState(() {
        _client = null;
        _connected = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _connecting = false;
        });
      }
    }
  }

  Future<void> _disconnectMeshtastic() async {
    setState(() {
      _connecting = true;
    });
    try {
      await _logSub?.cancel();
      _logSub = null;
      await _eventsSub?.cancel();
      _eventsSub = null;
      await _client?.dispose();
    } catch (_) {} finally {
      if (mounted) {
        setState(() {
          _client = null;
          _connected = false;
          _connecting = false;
          _events.clear();
        });
      }
    }
  }

  String _formatTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return two(dt.hour) + ':' + two(dt.minute) + ':' + two(dt.second);
  }

  // Legacy summary removed; events are rendered by MeshtasticEventTile
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _ExpandableMap<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final Map<String, T> items;
  final String Function(T value) valueBuilder;
  const _ExpandableMap({
    required this.icon,
    required this.title,
    required this.items,
    required this.valueBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      children: items.entries
          .map(
            (e) => ListTile(
              dense: true,
              title: Text(e.key),
              subtitle: Text(valueBuilder(e.value)),
            ),
          )
          .toList(),
    );
  }
}

// Removed legacy FromRadioDetails widget that exposed protobufs. Events are now
// rendered using MeshtasticEventTile with internal DTOs only.

class _SubHeader extends StatelessWidget {
  final String text;
  const _SubHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _Kv extends StatelessWidget {
  final String keyText;
  final String valueText;
  const _Kv(this.keyText, this.valueText);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(keyText, style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(width: 8),
          Expanded(child: Text(valueText, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _MonospaceBlock extends StatelessWidget {
  final String title;
  final String content;
  const _MonospaceBlock(this.title, this.content);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          SelectableText(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
