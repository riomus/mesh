import 'package:flutter/material.dart';

import '../services/device_communication_event_service.dart';
import '../widgets/meshtastic_event_tiles.dart';
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';

class EventDetailsPage extends StatelessWidget {
  final DeviceEvent event;
  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final payload = event.payload;
    final isMeshtastic = payload is MeshtasticDeviceEventPayload;

    return Scaffold(
      appBar: AppBar(title: const Text('Event details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / Hero tile if Meshtastic
            if (isMeshtastic)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: MeshtasticEventTile(
                    event: (payload as MeshtasticDeviceEventPayload).event,
                  ),
                ),
              ),
            _Section(
              emoji: '⏱️',
              title: 'Timestamp',
              child: Text(event.timestamp.toLocal().toString()),
            ),
            if (event.summary != null && event.summary!.isNotEmpty)
              _Section(
                emoji: '📝',
                title: 'Summary',
                child: Text(event.summary!),
              ),
            if (event.tags.isNotEmpty)
              _Section(
                emoji: '🏷️',
                title: 'Tags',
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: event.tags.entries
                      .map((e) => InputChip(
                            label: Text('${e.key}: ${e.value.join(', ')}'),
                            onPressed: () {},
                          ))
                      .toList(),
                ),
              ),
            if (isMeshtastic)
              _MeshtasticEventDetails(
                event: (payload as MeshtasticDeviceEventPayload).event,
              )
            else if (payload != null)
              _Section(
                emoji: '📦',
                title: 'Payload',
                child: Text(payload.runtimeType.toString()),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String emoji;
  final String title;
  final Widget child;
  const _Section({required this.emoji, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _MeshtasticEventDetails extends StatelessWidget {
  final MeshtasticEvent event;
  const _MeshtasticEventDetails({required this.event});

  @override
  Widget build(BuildContext context) {
    switch (event) {
      case MeshPacketEvent e:
        return _meshPacket(e);
      case MyInfoEvent e:
        return _Section(
          emoji: '🧩',
          title: 'MyInfo',
          child: _kvTable({
            'myNodeNum': e.myInfo.myNodeNum,
            'rebootCount': e.myInfo.rebootCount,
            'minAppVersion': e.myInfo.minAppVersion,
            'firmwareEdition': e.myInfo.firmwareEdition,
            'nodedbCount': e.myInfo.nodedbCount,
            'pioEnv': e.myInfo.pioEnv,
          }),
        );
      case NodeInfoEvent e:
        return _Section(
          emoji: '🪪',
          title: 'NodeInfo',
          child: _kvTable({
            'num': e.nodeInfo.num,
            'user.longName': e.nodeInfo.user?.longName,
            'user.shortName': e.nodeInfo.user?.shortName,
            'position.lat': e.nodeInfo.position?.latitudeI,
            'position.lon': e.nodeInfo.position?.longitudeI,
          }),
        );
      case ConfigEvent e:
        return _Section(
          emoji: '⚙️',
          title: 'Config',
          child: Text(e.config.toString()),
        );
      case ConfigCompleteEvent e:
        return _Section(
          emoji: '✅',
          title: 'Config complete',
          child: _kvTable({'id': e.configCompleteId}),
        );
      case RebootedEvent e:
        return _Section(
          emoji: '🔁',
          title: 'Rebooted',
          child: _kvTable({'rebooted': e.rebooted}),
        );
      case ModuleConfigEvent e:
        return _Section(
          emoji: '🧩',
          title: 'Module config',
          child: Text(e.moduleConfig.toString()),
        );
      case ChannelEvent e:
        return _Section(
          emoji: '📡',
          title: 'Channel',
          child: _kvTable({
            'index': e.channel.index,
          }),
        );
      case QueueStatusEvent e:
        return _Section(
          emoji: '📬',
          title: 'Queue status',
          child: _kvTable({
            'size': e.status.size,
            'maxlen': e.status.maxlen,
            'meshPacketId': e.status.meshPacketId,
          }),
        );
      case DeviceMetadataEvent e:
        return _Section(
          emoji: '🧰',
          title: 'Device metadata',
          child: _kvTable({
            'fw': e.metadata.firmwareVersion,
            'hw': e.metadata.hwModel,
            'role': e.metadata.role,
            'wifi': e.metadata.hasWifi,
            'bt': e.metadata.hasBluetooth,
            'eth': e.metadata.hasEthernet,
          }),
        );
      case MqttClientProxyEvent e:
        return _Section(
          emoji: '☁️',
          title: 'MQTT proxy',
          child: Text(e.message.toString()),
        );
      case FileInfoEvent e:
        return _Section(
          emoji: '📁',
          title: 'File info',
          child: _kvTable({
            'name': e.fileInfo.fileName,
            'sizeBytes': e.fileInfo.sizeBytes,
          }),
        );
      case ClientNotificationEvent e:
        return _Section(
          emoji: '🔔',
          title: 'Client notification',
          child: _kvTable({'message': e.notification.message}),
        );
      case DeviceUiConfigEvent e:
        return _Section(
          emoji: '🖥️',
          title: 'Device UI config',
          child: Text(e.uiConfig.toString()),
        );
      case LogRecordEvent e:
        return _Section(
          emoji: '🪵',
          title: 'Log record',
          child: _kvTable({
            'source': e.logRecord.source,
            'level': e.logRecord.level,
            'message': e.logRecord.message,
          }),
        );
    }
  }

  Widget _meshPacket(MeshPacketEvent e) {
    final p = e.packet;
    final header = _Section(
      emoji: '📦',
      title: 'Packet',
      child: _kvTable({
        'from': p.from,
        'to': p.to,
        'id': p.id,
        'channel': p.channel,
        'rxTime': p.rxTime,
        'rxRssi': p.rxRssi,
        'rxSnr': p.rxSnr,
        'hopLimit': p.hopLimit,
        'wantAck': p.wantAck,
        'priority': p.priority,
        'viaMqtt': p.viaMqtt,
        'transport': p.transportMechanism,
      }),
    );

    final decoded = e.decoded;
    if (decoded == null) return header;

    final decodedSection = switch (decoded) {
      TextPayloadDto t => _Section(
          emoji: '💬',
          title: 'Text payload',
          child: _kvTable({'text': t.text, 'emoji': t.emoji}),
        ),
      PositionPayloadDto pos => _Section(
          emoji: '📍',
          title: 'Position',
          child: _kvTable({
            'latI': pos.latitudeI,
            'lonI': pos.longitudeI,
            'alt': pos.position.altitude,
            'time': pos.position.time,
            'gpsAcc': pos.position.gpsAccuracy,
            'sats': pos.position.satsInView,
          }),
        ),
      WaypointPayloadDto w => _Section(
          emoji: '📍',
          title: 'Waypoint',
          child: _kvTable({
            'name': w.waypoint.name,
            'latI': w.waypoint.latitudeI,
            'lonI': w.waypoint.longitudeI,
            'expire': w.waypoint.expire,
          }),
        ),
      UserPayloadDto u => _Section(
          emoji: '🪪',
          title: 'User',
          child: _kvTable({
            'longName': u.user.longName,
            'shortName': u.user.shortName,
          }),
        ),
      RoutingPayloadDto r => _Section(
          emoji: '🧭',
          title: 'Routing',
          child: const Text('Routing payload'),
        ),
      AdminPayloadDto a => _Section(
          emoji: '🛠️',
          title: 'Admin',
          child: Text(a.toString()),
        ),
      RemoteHardwarePayloadDto rh => _Section(
          emoji: '🔧',
          title: 'Remote hardware',
          child: Text(rh.toString()),
        ),
      NeighborInfoPayloadDto ni => _Section(
          emoji: '🕸️',
          title: 'Neighbor info',
          child: Text(ni.toString()),
        ),
      StoreForwardPayloadDto sf => _Section(
          emoji: '🗄️',
          title: 'Store & Forward',
          child: _kvTable({'variant': sf.variant}),
        ),
      TelemetryPayloadDto t => _Section(
          emoji: '📊',
          title: 'Telemetry',
          child: Text(t.toString()),
        ),
      PaxcounterPayloadDto p => _Section(
          emoji: '👥',
          title: 'Paxcounter',
          child: _kvTable({'wifi': p.wifi, 'ble': p.ble}),
        ),
      TraceroutePayloadDto tr => _Section(
          emoji: '🔎',
          title: 'Traceroute',
          child: _kvTable({
            'routeLen': tr.route?.length,
            'hops': tr.route?.map((e) => e.toString()).join(' -> '),
            'snrTowards': tr.snrTowards?.join(', '),
            'routeBackLen': tr.routeBack?.length,
            'snrBack': tr.snrBack?.join(', '),
          }),
        ),
      KeyVerificationPayloadDto kv => _Section(
          emoji: '🔐',
          title: 'Key verification',
          child: _kvTable({'nonce': kv.nonce, 'hash1': kv.hash1?.length, 'hash2': kv.hash2?.length}),
        ),
      RawPayloadDto r => _Section(
          emoji: '📦',
          title: 'Raw payload',
          child: _kvTable({'port': '${r.portnum.name}:${r.portnum.id}', 'bytes': r.bytes.length}),
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, decodedSection],
    );
  }

  Widget _kvTable(Map<String, Object?> data) {
    final entries = data.entries.where((e) => e.value != null).toList();
    if (entries.isEmpty) return const Text('—');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries
          .map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.value.toString())),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
