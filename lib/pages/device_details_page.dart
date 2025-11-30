import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../l10n/app_localizations.dart';
import '../widgets/rssi_bar.dart';
import '../config/manufacturer_db.dart';
import '../services/meshtastic_ble_client.dart';
import '../services/logging_service.dart';
import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../widgets/logs_viewer.dart';
import '../widgets/mesh_app_bar.dart';

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
  // Capture every FromRadio packet
  final List<mesh.FromRadio> _fromRadioPackets = [];
  StreamSubscription<mesh.FromRadio>? _fromRadioSub;

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
                                    // Structured details
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                      child: FromRadioDetails(packet: item),
                                    ),
                                    // Raw bytes (hex)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Raw (hex)',
                                              style: Theme.of(context).textTheme.labelLarge),
                                          const SizedBox(height: 6),
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
      _fromRadioPackets.clear();
    });
    try {
      final client = MeshtasticBleClient(widget.result.device);
      // Logs are displayed via LogsViewer widget; no explicit subscription here.
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

  String _formatTime(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return two(dt.hour) + ':' + two(dt.minute) + ':' + two(dt.second);
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

/// Structured, formatted view of a single FromRadio packet
class FromRadioDetails extends StatelessWidget {
  final mesh.FromRadio packet;
  const FromRadioDetails({required this.packet});

  @override
  Widget build(BuildContext context) {
    final pv = packet.whichPayloadVariant();
    final children = <Widget>[];

    children.add(_SubHeader('${pv.name}'));

    switch (pv) {
      case mesh.FromRadio_PayloadVariant.packet:
        final p = packet.packet;
        // Envelope
        children.add(_SubHeader('Envelope'));
        children.addAll([
          _Kv('from', p.hasFrom() ? '${p.from}' : '—'),
          _Kv('to', p.hasTo() ? '${p.to}' : '—'),
          _Kv('channel', p.hasChannel() ? '${p.channel}' : '—'),
          _Kv('id', p.hasId() ? '${p.id}' : '—'),
          _Kv('rxTime', p.hasRxTime() ? _fmtTime(p.rxTime) : '—'),
          _Kv('rxRssi', p.hasRxRssi() ? '${p.rxRssi} dBm' : '—'),
          _Kv('rxSnr', p.hasRxSnr() ? '${p.rxSnr.toStringAsFixed(1)} dB' : '—'),
          _Kv('hopLimit', p.hasHopLimit() ? '${p.hopLimit}' : '—'),
          _Kv('hopStart', p.hasHopStart() ? '${p.hopStart}' : '—'),
          _Kv('wantAck', p.hasWantAck() ? _fmtBool(p.wantAck) : '—'),
          _Kv('priority', p.hasPriority() ? p.priority.name : '—'),
          _Kv('viaMqtt', p.hasViaMqtt() ? _fmtBool(p.viaMqtt) : '—'),
          _Kv('nextHop', p.hasNextHop() ? '${p.nextHop}' : '—'),
          _Kv('relayNode', p.hasRelayNode() ? '${p.relayNode}' : '—'),
          _Kv('txAfter', p.hasTxAfter() ? '${p.txAfter}s' : '—'),
          _Kv('transport', p.hasTransportMechanism() ? p.transportMechanism.name : '—'),
        ]);
        // Payload
        if (p.hasDecoded()) {
          final d = p.decoded;
          children.add(_SubHeader('Decoded payload'));
          children.addAll([
            _Kv('portnum', d.hasPortnum() ? d.portnum.name : '—'),
            _Kv('wantResponse', d.hasWantResponse() ? _fmtBool(d.wantResponse) : '—'),
            _Kv('source', d.hasSource() ? '${d.source}' : '—'),
            _Kv('dest', d.hasDest() ? '${d.dest}' : '—'),
            _Kv('requestId', d.hasRequestId() ? '${d.requestId}' : '—'),
            _Kv('replyId', d.hasReplyId() ? '${d.replyId}' : '—'),
            _Kv('emoji', d.hasEmoji() ? String.fromCharCode(d.emoji) : '—'),
            _Kv('bitfield', d.hasBitfield() ? '0x${d.bitfield.toRadixString(16)}' : '—'),
          ]);
          if (d.hasPayload()) {
            final hex = _hexLimited(d.payload, 256);
            final txt = _tryUtf8(d.payload);
            children.addAll([
              _Kv('payload bytes', '${d.payload.length}'),
              _MonospaceBlock('payload (hex)', hex),
              if (txt != null && txt.isNotEmpty) _MonospaceBlock('payload (utf8)', txt),
            ]);
          }
        } else if (p.hasEncrypted()) {
          children.add(_SubHeader('Encrypted payload'));
          children.addAll([
            _Kv('bytes', '${p.encrypted.length}'),
            _MonospaceBlock('ciphertext (hex)', _hexLimited(p.encrypted, 256)),
            _Kv('pkiEncrypted', p.hasPkiEncrypted() ? _fmtBool(p.pkiEncrypted) : '—'),
            if (p.hasPublicKey()) _Kv('publicKey bytes', '${p.publicKey.length}'),
          ]);
        } else {
          children.add(const Text('No payload variant in MeshPacket'));
        }
        break;
      case mesh.FromRadio_PayloadVariant.myInfo:
        final i = packet.myInfo;
        children.addAll([
          _Kv('myNodeNum', i.hasMyNodeNum() ? '${i.myNodeNum}' : '—'),
          _Kv('rebootCount', i.hasRebootCount() ? '${i.rebootCount}' : '—'),
          _Kv('minAppVersion', i.hasMinAppVersion() ? '${i.minAppVersion}' : '—'),
          _Kv('pioEnv', i.hasPioEnv() ? i.pioEnv : '—'),
          _Kv('firmwareEdition', i.hasFirmwareEdition() ? i.firmwareEdition.name : '—'),
          _Kv('nodedbCount', i.hasNodedbCount() ? '${i.nodedbCount}' : '—'),
          if (i.hasDeviceId()) _MonospaceBlock('deviceId (hex)', _hexLimited(i.deviceId, 64)),
        ]);
        break;
      case mesh.FromRadio_PayloadVariant.nodeInfo:
        final n = packet.nodeInfo;
        children.addAll([
          _Kv('num', n.hasNum() ? '${n.num}' : '—'),
          if (n.hasUser()) ...[
            _SubHeader('User'),
            _Kv('id', n.user.hasId() ? n.user.id : '—'),
            _Kv('longName', n.user.hasLongName() ? n.user.longName : '—'),
            _Kv('shortName', n.user.hasShortName() ? n.user.shortName : '—'),
            _Kv('hwModel', n.user.hasHwModel() ? n.user.hwModel.name : '—'),
            _Kv('role', n.user.hasRole() ? n.user.role.name : '—'),
            _Kv('licensed', n.user.hasIsLicensed() ? _fmtBool(n.user.isLicensed) : '—'),
          ],
          if (n.hasPosition()) ...[
            _SubHeader('Position'),
            _Kv('lat/lon', _formatLatLon(n.position)),
            _Kv('altitude', n.position.hasAltitude() ? '${n.position.altitude} m' : '—'),
            _Kv('timestamp', n.position.hasTime() ? _fmtTime(n.position.time) : '—'),
          ],
          _Kv('snr', n.hasSnr() ? '${n.snr.toStringAsFixed(1)} dB' : '—'),
          _Kv('lastHeard', n.hasLastHeard() ? _fmtTime(n.lastHeard) : '—'),
          _Kv('channel', n.hasChannel() ? '${n.channel}' : '—'),
          _Kv('viaMqtt', n.hasViaMqtt() ? _fmtBool(n.viaMqtt) : '—'),
          _Kv('hopsAway', n.hasHopsAway() ? '${n.hopsAway}' : '—'),
          _Kv('favorite', n.hasIsFavorite() ? _fmtBool(n.isFavorite) : '—'),
          _Kv('ignored', n.hasIsIgnored() ? _fmtBool(n.isIgnored) : '—'),
        ]);
        break;
      case mesh.FromRadio_PayloadVariant.config:
        children.add(const Text('Config update received'));
        break;
      case mesh.FromRadio_PayloadVariant.moduleConfig:
        children.add(const Text('ModuleConfig update received'));
        break;
      case mesh.FromRadio_PayloadVariant.channel:
        children.add(const Text('Channel update received'));
        break;
      case mesh.FromRadio_PayloadVariant.logRecord:
        final l = packet.logRecord;
        children.addAll([
          _Kv('level', l.hasLevel() ? l.level.name : '—'),
          _Kv('source', l.hasSource() ? l.source : '—'),
          _Kv('message', l.hasMessage() ? l.message : '—'),
        ]);
        break;
      case mesh.FromRadio_PayloadVariant.queueStatus:
        final q = packet.queueStatus;
        children.addAll([
          _Kv('meshPacketId', q.hasMeshPacketId() ? '${q.meshPacketId}' : '—'),
          _Kv('free', q.hasFree() ? '${q.free}' : '—'),
        ]);
        break;
      case mesh.FromRadio_PayloadVariant.xmodemPacket:
        final xm = packet.xmodemPacket;
        children.addAll([
          _Kv('buffer bytes', xm.hasBuffer() ? '${xm.buffer.length}' : '—'),
          if (xm.hasBuffer()) _MonospaceBlock('buffer (hex)', _hexLimited(xm.buffer, 256)),
        ]);
        break;
      case mesh.FromRadio_PayloadVariant.metadata:
        final m = packet.metadata;
        children.addAll([
          _Kv('hwModel', m.hasHwModel() ? m.hwModel.name : '—'),
          _Kv('firmwareVersion', m.hasFirmwareVersion() ? m.firmwareVersion : '—'),
          // Only show fields that exist in current proto
        ]);
        break;
      case mesh.FromRadio_PayloadVariant.mqttClientProxyMessage:
        final mp = packet.mqttClientProxyMessage;
        children.addAll([
          _Kv('topic', mp.hasTopic() ? mp.topic : '—'),
          _Kv('retained', mp.hasRetained() ? _fmtBool(mp.retained) : '—'),
        ]);
        final which = mp.whichPayloadVariant();
        if (which == mesh.MqttClientProxyMessage_PayloadVariant.text && mp.hasText()) {
          children.add(_MonospaceBlock('text', mp.text));
        } else if (which == mesh.MqttClientProxyMessage_PayloadVariant.data && mp.hasData()) {
          children.addAll([
            _Kv('data bytes', '${mp.data.length}'),
            _MonospaceBlock('data (hex)', _hexLimited(mp.data, 256)),
          ]);
        }
        break;
      case mesh.FromRadio_PayloadVariant.fileInfo:
        final f = packet.fileInfo;
        children.addAll([
          _Kv('fileName', f.hasFileName() ? f.fileName : '—'),
          _Kv('sizeBytes', f.hasSizeBytes() ? '${f.sizeBytes}' : '—'),
          // fileId might not exist in current proto
        ]);
        break;
      case mesh.FromRadio_PayloadVariant.clientNotification:
        final cn = packet.clientNotification;
        children.addAll([
          _Kv('message', cn.hasMessage() ? cn.message : '—'),
          // severity might not exist in current proto
        ]);
        break;
      case mesh.FromRadio_PayloadVariant.deviceuiConfig:
        children.add(const Text('Device UI config update'));
        break;
      case mesh.FromRadio_PayloadVariant.configCompleteId:
        children.add(_Kv('configCompleteId', '${packet.configCompleteId}'));
        break;
      case mesh.FromRadio_PayloadVariant.rebooted:
        children.add(_Kv('rebooted', _fmtBool(packet.rebooted)));
        break;
      case mesh.FromRadio_PayloadVariant.notSet:
        children.add(const Text('No payload set'));
        break;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  static String _fmtTime(int epochSeconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000, isUtc: true).toLocal();
    return dt.toIso8601String();
  }

  static String _fmtBool(bool v) => v ? 'Yes' : 'No';

  static String _hexLimited(List<int> bytes, int max) {
    if (bytes.isEmpty) return '—';
    final slice = bytes.length > max ? bytes.sublist(0, max) : bytes;
    final hex = _hexLocal(slice);
    if (slice.length < bytes.length) {
      return '$hex … (+${bytes.length - slice.length} bytes)';
    }
    return hex;
  }

  static String? _tryUtf8(List<int> bytes) {
    try {
      final s = utf8.decode(bytes, allowMalformed: true);
      // show only printable subset
      if (s.trim().isEmpty) return null;
      return s;
    } catch (_) {
      return null;
    }
  }

  static String _hexLocal(List<int> bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
      sb.write(' ');
    }
    return sb.toString().trim().toUpperCase();
  }

  static String _formatLatLon(mesh.Position p) {
    final hasLat = p.hasLatitudeI();
    final hasLon = p.hasLongitudeI();
    if (!hasLat || !hasLon) return '—';
    // latitudeI/longitudeI are scaled by 1e-7 in Meshtastic
    final lat = p.latitudeI / 1e7;
    final lon = p.longitudeI / 1e7;
    return '${lat.toStringAsFixed(7)}, ${lon.toStringAsFixed(7)}';
  }
}

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
