import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../l10n/app_localizations.dart';
import '../widgets/rssi_bar.dart';
import '../config/manufacturer_db.dart';
import '../services/meshtastic_ble_client.dart';
import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;

class DeviceDetailsPage extends StatefulWidget {
  final ScanResult result;
  const DeviceDetailsPage({super.key, required this.result});

  @override
  State<DeviceDetailsPage> createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  MeshtasticBleClient? _client;
  bool _connecting = false;
  bool _connected = false;
  final List<String> _logs = [];
  StreamSubscription<String>? _logSub;
  // Capture every FromRadio packet
  final List<mesh.FromRadio> _fromRadioPackets = [];
  StreamSubscription<mesh.FromRadio>? _fromRadioSub;

  String _bestName(ScanResult r) {
    if (r.advertisementData.advName.isNotEmpty) return r.advertisementData.advName;
    if (r.device.platformName.isNotEmpty) return r.device.platformName;
    return r.device.remoteId.str;
  }

  @override
  void dispose() {
    _logSub?.cancel();
    _fromRadioSub?.cancel();
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
      appBar: AppBar(
        title: Text(_bestName(result)),
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
              // Simple log console
              if (_logs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    constraints: const BoxConstraints(maxHeight: 160),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _logs.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(_logs[i]),
                      ),
                    ),
                  ),
                ),
              // FromRadio packets viewer
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.inbox),
                        const SizedBox(width: 8),
                        Text('FromRadio packets (${_fromRadioPackets.length})',
                            style: Theme.of(context).textTheme.titleSmall),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Clear',
                          onPressed: _fromRadioPackets.isEmpty
                              ? null
                              : () {
                                  setState(() => _fromRadioPackets.clear());
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
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: _fromRadioPackets.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('No packets received yet'),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _fromRadioPackets.length,
                              itemBuilder: (context, index) {
                                final item = _fromRadioPackets[index];
                                final summary = _fromRadioSummary(item);
                                final rawHex = _hex(item.writeToBuffer());
                                return ExpansionTile(
                                  dense: true,
                                  leading: const Icon(Icons.markunread_mailbox_outlined),
                                  title: Text(summary, overflow: TextOverflow.ellipsis),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SelectableText(
                                            rawHex,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(fontFamily: 'monospace'),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                );
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
      _logs.clear();
      _fromRadioPackets.clear();
    });
    try {
      final client = MeshtasticBleClient(widget.result.device);
      _logSub = client.logStream.listen((e) {
        setState(() {
          _logs.add(e);
          if (_logs.length > 200) _logs.removeRange(0, _logs.length - 200);
        });
      });
      // subscribe to incoming packets
      _fromRadioSub?.cancel();
      _fromRadioSub = client.fromRadioStream.listen((pkt) {
        setState(() {
          _fromRadioPackets.add(pkt);
          if (_fromRadioPackets.length > 200) {
            _fromRadioPackets.removeRange(0, _fromRadioPackets.length - 200);
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
      await _fromRadioSub?.cancel();
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
      await _fromRadioSub?.cancel();
      _fromRadioSub = null;
      await _client?.dispose();
    } catch (_) {} finally {
      if (mounted) {
        setState(() {
          _client = null;
          _connected = false;
          _connecting = false;
          _fromRadioPackets.clear();
        });
      }
    }
  }

  String _fromRadioSummary(mesh.FromRadio fr) {
    final kind = fr.whichPayloadVariant();
    switch (kind) {
      case mesh.FromRadio_PayloadVariant.packet:
        final p = fr.packet;
        if (p.hasDecoded()) {
          final d = p.decoded;
          // many fields exist; show basic routing and portnum if present
          final from = p.hasFrom() ? p.from : null;
          final to = p.hasTo() ? p.to : null;
          final ch = p.hasChannel() ? p.channel : null;
          final port = d.hasPortnum() ? d.portnum.name : 'decoded';
          return 'packet decoded from=${from ?? '?'} to=${to ?? '?'} ch=${ch ?? '?'} port=$port rssi=${p.hasRxRssi() ? p.rxRssi : '?'}';
        } else if (p.hasEncrypted()) {
          final from = p.hasFrom() ? p.from : null;
          final to = p.hasTo() ? p.to : null;
          final ch = p.hasChannel() ? p.channel : null;
          return 'packet encrypted from=${from ?? '?'} to=${to ?? '?'} ch=${ch ?? '?'} bytes=${p.encrypted.length}';
        } else {
          return 'packet (no payload variant)';
        }
      case mesh.FromRadio_PayloadVariant.myInfo:
        return 'myInfo: node=${fr.myInfo.myNodeNum} rebot_count=${fr.myInfo.rebootCount} minAppVersion=${fr.myInfo.minAppVersion}';
      case mesh.FromRadio_PayloadVariant.nodeInfo:
        return 'nodeInfo: ${fr.nodeInfo.user.longName} (${fr.nodeInfo.num})';
      case mesh.FromRadio_PayloadVariant.config:
        return 'config update';
      case mesh.FromRadio_PayloadVariant.logRecord:
        return 'log: ${fr.logRecord.level.name} ${fr.logRecord.source}: ${fr.logRecord.message}';
      case mesh.FromRadio_PayloadVariant.configCompleteId:
        return 'configCompleteId=${fr.configCompleteId}';
      case mesh.FromRadio_PayloadVariant.rebooted:
        return 'rebooted=${fr.rebooted}';
      case mesh.FromRadio_PayloadVariant.moduleConfig:
        return 'moduleConfig update';
      case mesh.FromRadio_PayloadVariant.channel:
        return 'channel update';
      case mesh.FromRadio_PayloadVariant.queueStatus:
        return 'queueStatus: wantAck=${fr.queueStatus.meshPacketId} free=${fr.queueStatus.free}';
      case mesh.FromRadio_PayloadVariant.xmodemPacket:
        return 'xmodemPacket size=${fr.xmodemPacket.buffer.length}';
      case mesh.FromRadio_PayloadVariant.metadata:
        return 'metadata updated';
      case mesh.FromRadio_PayloadVariant.mqttClientProxyMessage:
        return 'mqtt proxy message';
      case mesh.FromRadio_PayloadVariant.fileInfo:
        return 'fileInfo: ${fr.fileInfo.fileName} (${fr.fileInfo.sizeBytes} bytes)';
      case mesh.FromRadio_PayloadVariant.clientNotification:
        return 'clientNotification: ${fr.clientNotification.message}';
      case mesh.FromRadio_PayloadVariant.deviceuiConfig:
        return 'deviceuiConfig update';
      case mesh.FromRadio_PayloadVariant.notSet:
        return 'unknown FromRadio payload';
    }
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
