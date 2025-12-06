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

// Removed unused import: meshtastic_models.dart
import '../widgets/events_list_widget.dart';
import '../utils/text_sanitize.dart';
import '../services/device_status_store.dart';
import 'device_chat_page.dart';
import '../widgets/device_state_widget.dart';

import '../widgets/telemetry_widget.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/device/device_bloc.dart';
import '../blocs/device/device_state.dart' as bloc_state;

class DeviceDetailsPage extends StatefulWidget {
  final BluetoothDevice device;
  final ScanResult? scanResult;
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final void Function(BuildContext context)? onOpenSettings;

  const DeviceDetailsPage({
    super.key,
    required this.device,
    this.scanResult,
    this.onToggleTheme,
    this.themeMode,
    this.onOpenSettings,
  });

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  // Connection status reflected from DeviceStatusStore to preserve across rebuilds
  bool _connecting = false;
  bool _connected = false;
  int? _rssi; // live RSSI from DeviceStatusStore while connected
  // Logs are now shown via reusable LogsViewer widget; no manual buffering here.
  StreamSubscription<LogEvent>?
  _logSub; // kept for backwards-compat, but unused
  // Stable device-scoped log stream (with replay) to avoid re-subscribe on rebuilds
  Stream<LogEvent>? _deviceLogStream;
  // Device status subscription (global store)
  StreamSubscription<DeviceStatus>? _statusSub;

  String _bestName() {
    if (widget.scanResult?.advertisementData.advName.isNotEmpty == true) {
      return widget.scanResult!.advertisementData.advName;
    }
    if (widget.device.platformName.isNotEmpty) {
      return widget.device.platformName;
    }
    return widget.device.remoteId.str;
  }

  @override
  void initState() {
    super.initState();
    _initDeviceLogStream();
    _subscribeStatus();
    _checkAndRefreshConfig();
  }

  Future<void> _checkAndRefreshConfig() async {
    final id = widget.device.remoteId.str;
    final isConnected = DeviceStatusStore.instance.isConnected(id);
    // Use BLoC to check if we have state
    final hasState =
        context.read<DeviceBloc>().state.getDeviceState(id) != null;

    if (isConnected && !hasState) {
      LoggingService.instance.push(
        tags: {'deviceId': id, 'class': 'DeviceDetailsPage'},
        level: 'info',
        message: 'Connected but no state, auto-refreshing config...',
      );
      try {
        final client = await DeviceStatusStore.instance.connect(widget.device);
        await client.requestConfig();
      } catch (e) {
        LoggingService.instance.push(
          tags: {'deviceId': id, 'class': 'DeviceDetailsPage'},
          level: 'warn',
          message: 'Failed to auto-refresh config: $e',
        );
      }
    }
  }

  void _initDeviceLogStream() {
    final deviceId = widget.device.remoteId.str;
    _deviceLogStream = LoggingService.instance.listenWithReplay(
      takeLast: 200,
      allEquals: {'network': 'meshtastic', 'deviceId': deviceId},
    );
  }

  @override
  void didUpdateWidget(covariant DeviceDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldId = oldWidget.device.remoteId.str;
    final newId = widget.device.remoteId.str;
    if (oldId != newId) {
      _initDeviceLogStream();
      _statusSub?.cancel();
      _subscribeStatus();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _logSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.scanResult?.advertisementData;
    final device = widget.device;

    final hasMeshtasticService =
        ad?.serviceUuids.any(
          (g) => g.str.toLowerCase() == MeshtasticBleClient.serviceUuid,
        ) ??
        false;

    return Scaffold(
      appBar: MeshAppBar(
        title: Text(safeText(_bestName())),
        onToggleTheme: widget.onToggleTheme,
        themeMode: widget.themeMode,
        onOpenSettings: widget.onOpenSettings,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              // General section
              _Section(
                title: AppLocalizations.of(context).general,
                children: [
                  ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(AppLocalizations.of(context).identifier),
                    subtitle: Text(device.remoteId.str),
                  ),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: Text(AppLocalizations.of(context).platformName),
                    subtitle: Text(
                      device.platformName.isNotEmpty
                          ? device.platformName
                          : AppLocalizations.of(context).emptyState,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.network_cell),
                    title: Text(AppLocalizations.of(context).signalRssi),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: RssiBar(
                        rssi: (_rssi ?? widget.scanResult?.rssi ?? 0),
                      ),
                    ),
                    trailing: Text(
                      '${_rssi ?? widget.scanResult?.rssi ?? '-'} dBm',
                    ),
                  ),
                ],
              ),
              // Meshtastic section
              _Section(
                title: AppLocalizations.of(context).meshtasticLabel,
                children: [
                  ListTile(
                    leading: const Icon(Icons.memory),
                    title: Text(AppLocalizations.of(context).serviceAvailable),
                    subtitle: Text(
                      hasMeshtasticService
                          ? AppLocalizations.of(context).yes
                          : AppLocalizations.of(context).no,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(_connected ? Icons.link_off : Icons.link),
                          label: Text(
                            _connected
                                ? AppLocalizations.of(context).disconnect
                                : AppLocalizations.of(context).connect,
                          ),
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
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.chat),
                          tooltip: AppLocalizations.of(context).chat,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DeviceChatPage(
                                  deviceId: widget.device.remoteId.str,
                                  channelIndex: 0, // Default to primary channel
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        if (_connecting)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _connected
                                ? AppLocalizations.of(context).statusConnected
                                : _connecting
                                ? AppLocalizations.of(context).statusConnecting
                                : AppLocalizations.of(
                                    context,
                                  ).statusDisconnected,
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
                            Text(
                              AppLocalizations.of(context).logs,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: LogsViewer(
                            key: ValueKey('deviceLogs-${device.remoteId.str}'),
                            maxHeight: 160,
                            stream: _deviceLogStream,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Live Meshtastic events viewer (reusable EventsListWidget)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context).satelliteEmoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).liveEvents,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          height: 260,
                          child: EventsListWidget(
                            deviceId: device.remoteId.str,
                            network: 'meshtastic',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Channels Section
              BlocBuilder<DeviceBloc, bloc_state.DevicesState>(
                builder: (context, state) {
                  final deviceState = state.getDeviceState(
                    widget.device.remoteId.str,
                  );
                  if (deviceState == null || deviceState.channels.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final channels = deviceState.channels
                      .where((c) => c.role != null && c.role != 'DISABLED')
                      .toList();

                  if (channels.isEmpty) return const SizedBox.shrink();

                  return _Section(
                    title: AppLocalizations.of(context).channels,
                    children: channels.map((c) {
                      // Use channel name if available, otherwise show "Default" for index 0 or "Channel [index]"
                      String channelTitle = c.settings?.name ?? '';
                      if (channelTitle.isEmpty) {
                        if (c.index == 0) {
                          channelTitle = 'Default';
                        } else {
                          channelTitle =
                              '${AppLocalizations.of(context).channel} ${c.index}';
                        }
                      }

                      return ListTile(
                        leading: const Icon(Icons.tag),
                        title: Text(channelTitle),
                        subtitle: Text(
                          '${AppLocalizations.of(context).channel} ${c.index}',
                        ),
                        trailing: IconButton.filledTonal(
                          icon: const Icon(Icons.chat),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DeviceChatPage(
                                  deviceId: widget.device.remoteId.str,
                                  channelIndex: c.index,
                                  chatTitle:
                                      '$channelTitle (${widget.device.platformName})',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              // Device State Section
              BlocBuilder<DeviceBloc, bloc_state.DevicesState>(
                builder: (context, state) {
                  final deviceState = state.getDeviceState(
                    widget.device.remoteId.str,
                  );

                  if (deviceState == null && _connected) {
                    // Connected but no state? Try to request it if we haven't recently.
                    // Or just show a manual refresh button.
                    // Auto-refresh if we haven't tried recently (simple debounce could be added here,
                    // but for now relying on user interaction or simple one-shot).
                    // Actually, let's just show the button but also trigger a fetch if it's been a while?
                    // For now, just the button is safer to avoid loops.
                    return _Section(
                      title: AppLocalizations.of(context).deviceState,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.warning_amber),
                          title: Text(
                            AppLocalizations.of(context).stateMissing,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context).connectToViewState,
                          ),
                          trailing: IconButton.filledTonal(
                            icon: const Icon(Icons.refresh),
                            onPressed: () async {
                              final client = await DeviceStatusStore.instance
                                  .connect(widget.device);
                              await client.requestConfig();
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (deviceState == null) {
                    return _Section(
                      title: AppLocalizations.of(context).deviceState,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: Text(
                            AppLocalizations.of(context).noDeviceState,
                          ),
                          subtitle: Text(
                            AppLocalizations.of(context).connectToViewState,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      DeviceStateWidget(state: deviceState),
                      if (deviceState.myNodeInfo?.myNodeNum != null)
                        TelemetryWidget(
                          nodeId: deviceState.myNodeInfo!.myNodeNum!,
                        ),
                    ],
                  );
                },
              ),
              // Advertisement section
              _Section(
                title: AppLocalizations.of(context).advertisement,
                children: ad == null
                    ? [
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context).noneAdvertised,
                          ),
                        ),
                      ]
                    : [
                        ListTile(
                          leading: const Icon(Icons.label),
                          title: Text(
                            AppLocalizations.of(context).advertisedName,
                          ),
                          subtitle: Text(
                            ad.advName.isNotEmpty
                                ? ad.advName
                                : AppLocalizations.of(context).emptyState,
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.link),
                          title: Text(AppLocalizations.of(context).connectable),
                          subtitle: Text(
                            ad.connectable
                                ? AppLocalizations.of(context).yes
                                : AppLocalizations.of(context).no,
                          ),
                        ),
                        // Service UUIDs
                        if (ad.serviceUuids.isNotEmpty)
                          _ExpandableMap<List<Guid>>(
                            icon: Icons.widgets,
                            title: AppLocalizations.of(
                              context,
                            ).serviceUuidsWithCount(ad.serviceUuids.length),
                            items: {
                              for (var i = 0; i < ad.serviceUuids.length; i++)
                                '${AppLocalizations.of(context).service} ${i + 1}':
                                    [ad.serviceUuids[i]],
                            },
                            valueBuilder: (gList) =>
                                gList.map((g) => g.str).join(', '),
                          )
                        else
                          ListTile(
                            leading: const Icon(Icons.widgets),
                            title: Text(
                              AppLocalizations.of(context).serviceUuids,
                            ),
                            subtitle: Text(
                              AppLocalizations.of(context).noneAdvertised,
                            ),
                          ),
                        // Manufacturer Data
                        if (ad.manufacturerData.isNotEmpty)
                          _ExpandableMap<List<int>>(
                            icon: Icons.factory,
                            title: AppLocalizations.of(context)
                                .manufacturerDataWithCount(
                                  ad.manufacturerData.length,
                                ),
                            items: ad.manufacturerData.map(
                              (k, v) => MapEntry(_manufacturerKey(k), v),
                            ),
                            valueBuilder: (bytes) => _hex(bytes),
                          )
                        else
                          ListTile(
                            leading: const Icon(Icons.factory),
                            title: Text(
                              AppLocalizations.of(context).manufacturerData,
                            ),
                            subtitle: Text(
                              AppLocalizations.of(context).noneAdvertised,
                            ),
                          ),
                        // Service Data
                        if (ad.serviceData.isNotEmpty)
                          _ExpandableMap<List<int>>(
                            icon: Icons.storage,
                            title: AppLocalizations.of(
                              context,
                            ).serviceDataWithCount(ad.serviceData.length),
                            items: ad.serviceData.map(
                              (k, v) => MapEntry(k.str, v),
                            ),
                            valueBuilder: (bytes) => _hex(bytes),
                          )
                        else
                          ListTile(
                            leading: const Icon(Icons.storage),
                            title: Text(
                              AppLocalizations.of(context).serviceData,
                            ),
                            subtitle: Text(
                              AppLocalizations.of(context).noneAdvertised,
                            ),
                          ),
                      ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
    setState(() => _connecting = true);
    try {
      await DeviceStatusStore.instance.connect(widget.device);
      // status stream will flip _connected/_connecting accordingly
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).meshtasticConnectFailed}: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _disconnectMeshtastic() async {
    setState(() => _connecting = true);
    try {
      await _logSub?.cancel();
      _logSub = null;
      await DeviceStatusStore.instance.disconnect(widget.device.remoteId.str);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  void _subscribeStatus() {
    final id = widget.device.remoteId.str;
    _statusSub = DeviceStatusStore.instance.statusStream(id).listen((s) {
      if (!mounted) return;
      setState(() {
        _connecting = s.state == DeviceConnectionState.connecting;
        _connected = s.state == DeviceConnectionState.connected;
        _rssi = s.rssi ?? _rssi; // keep last known if null
        if (_connected) {
          // If we just connected (or are connected), check if we need to refresh state
          // We delay slightly to let the service process any pending events
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _checkAndRefreshConfig();
          });
        }
      });
      if (s.state == DeviceConnectionState.error && s.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).deviceError}: ${s.error}',
            ),
          ),
        );
      }
    });
  }
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
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
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
