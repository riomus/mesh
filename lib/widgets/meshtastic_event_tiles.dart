import 'package:flutter/material.dart';

import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';
import 'rssi_bar.dart';

/// Reusable tiles to visualize MeshtasticEvent items with emojis and colors.
class MeshtasticEventTile extends StatelessWidget {
  final MeshtasticEvent event;
  const MeshtasticEventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    switch (event) {
      case MeshPacketEvent e:
        return _PacketTile(e: e);
      case MyInfoEvent e:
        return _SimpleTile(
          emoji: '🧩',
          title: 'MyInfo',
          subtitle: e.myInfo.myNodeNum != null ? 'myNodeNum=${e.myInfo.myNodeNum}' : null,
          color: Colors.indigo,
        );
      case NodeInfoEvent e:
        return _SimpleTile(
          emoji: '🪪',
          title: _nodeTitle(e.nodeInfo),
          subtitle: e.nodeInfo.num != null ? 'num=${e.nodeInfo.num}' : null,
          color: Colors.deepPurple,
        );
      case ConfigEvent _:
        return _SimpleTile(
          emoji: '⚙️',
          title: 'Config update',
          subtitle: null,
          color: Colors.teal,
        );
      case ConfigCompleteEvent e:
        return _PlainTile(
          emoji: '✅',
          title: 'Config stream complete',
          subtitle: 'id=${e.configCompleteId}',
          color: Colors.teal,
        );
      case RebootedEvent e:
        return _PlainTile(
          emoji: e.rebooted ? '🔁' : 'ℹ️',
          title: 'Rebooted',
          subtitle: e.rebooted ? 'Device reported reboot' : 'No reboot',
          color: Colors.orange,
        );
      case ModuleConfigEvent _:
        return _SimpleTile(
          emoji: '🧩',
          title: 'Module config',
          subtitle: null,
          color: Colors.blueGrey,
        );
      case ChannelEvent e:
        return _SimpleTile(
          emoji: '📡',
          title: 'Channel update',
          subtitle: e.channel.index != null ? 'index=${e.channel.index}' : null,
          color: Colors.blue,
        );
      case QueueStatusEvent e:
        return _SimpleTile(
          emoji: '📬',
          title: 'Queue status',
          subtitle: _queuePreview(e.status),
          color: Colors.cyan,
        );
      case DeviceMetadataEvent e:
        return _SimpleTile(
          emoji: '🧰',
          title: 'Device metadata',
          subtitle: _deviceMetadataPreview(e.metadata),
          color: Colors.brown,
        );
      case MqttClientProxyEvent _:
        return _SimpleTile(
          emoji: '☁️',
          title: 'MQTT proxy',
          subtitle: null,
          color: Colors.lightBlue,
        );
      case FileInfoEvent e:
        return _SimpleTile(
          emoji: '📁',
          title: 'File info',
          subtitle: _fileInfoPreview(e.fileInfo),
          color: Colors.amber,
        );
      case ClientNotificationEvent e:
        return _SimpleTile(
          emoji: '🔔',
          title: 'Client notification',
          subtitle: e.notification.message,
          color: Colors.pink,
        );
      case DeviceUiConfigEvent _:
        return _SimpleTile(
          emoji: '🖥️',
          title: 'Device UI config',
          subtitle: null,
          color: Colors.green,
        );
      case LogRecordEvent e:
        return _LogTile(log: e.logRecord);
    }
  }

  static String _nodeTitle(NodeInfoDto dto) {
    final name = dto.user?.longName ?? dto.user?.shortName ?? '';
    final num = dto.num;
    return name.isNotEmpty
        ? 'Node $name${num != null ? ' ($num)' : ''}'
        : (num != null ? 'Node ($num)' : 'NodeInfo');
  }
}

String? _deviceMetadataPreview(DeviceMetadataDto dm) {
  final parts = <String>[];
  if (dm.firmwareVersion != null) parts.add('fw=${dm.firmwareVersion}');
  if (dm.hwModel != null) parts.add('hw=${dm.hwModel}');
  if (dm.role != null) parts.add('role=${dm.role}');
  if (dm.hasWifi == true) parts.add('wifi');
  if (dm.hasBluetooth == true) parts.add('bt');
  if (dm.hasEthernet == true) parts.add('eth');
  if (parts.isEmpty) return null;
  return parts.join(' · ');
}

class _PacketTile extends StatelessWidget {
  final MeshPacketEvent e;
  const _PacketTile({required this.e});

  @override
  Widget build(BuildContext context) {
    final p = e.packet;
    final decoded = e.decoded;
    final emoji = switch (decoded) {
      TextPayloadDto() => '💬',
      PositionPayloadDto() => '📍',
      WaypointPayloadDto() => '📍',
      UserPayloadDto() => '🪪',
      RoutingPayloadDto() => '🧭',
      AdminPayloadDto() => '🛠️',
      RemoteHardwarePayloadDto() => '🔧',
      NeighborInfoPayloadDto() => '🕸️',
      StoreForwardPayloadDto() => '🗄️',
      TelemetryPayloadDto() => '📊',
      PaxcounterPayloadDto() => '👥',
      TraceroutePayloadDto() => '🔎',
      KeyVerificationPayloadDto() => '🔐',
      RawPayloadDto() => '📦',
      null => '📦',
    };

    final color = switch (decoded) {
      TextPayloadDto() => Colors.green,
      PositionPayloadDto() => Colors.blue,
      WaypointPayloadDto() => Colors.lightBlue,
      UserPayloadDto() => Colors.purple,
      RoutingPayloadDto() => Colors.orange,
      AdminPayloadDto() => Colors.teal,
      RemoteHardwarePayloadDto() => Colors.indigo,
      NeighborInfoPayloadDto() => Colors.deepPurple,
      StoreForwardPayloadDto() => Colors.brown,
      TelemetryPayloadDto() => Colors.cyan,
      PaxcounterPayloadDto() => Colors.deepOrange,
      TraceroutePayloadDto() => Colors.amber,
      KeyVerificationPayloadDto() => Colors.lime,
      RawPayloadDto() => Colors.grey,
      null => Colors.grey,
    };

    final title = switch (decoded) {
      TextPayloadDto t => _textTitle(t),
      PositionPayloadDto pos => _posTitle(pos),
      WaypointPayloadDto w => _waypointTitle(w),
      UserPayloadDto u => _userTitle(u),
      RoutingPayloadDto _ => 'Routing message',
      AdminPayloadDto _ => 'Admin message',
      RemoteHardwarePayloadDto rh => _remoteHardwareTitle(rh),
      NeighborInfoPayloadDto ni => _neighborInfoTitle(ni),
      StoreForwardPayloadDto sf => _storeForwardTitle(sf),
      TelemetryPayloadDto t => _telemetryTitle(t),
      PaxcounterPayloadDto p => _paxcounterTitle(p),
      TraceroutePayloadDto _ => 'Traceroute',
      KeyVerificationPayloadDto kv => _keyVerificationTitle(kv),
      RawPayloadDto r => 'Raw payload (${r.portnum.name}:${r.portnum.id}, ${r.bytes.length} bytes)',
      null => 'Encrypted/unknown payload',
    };

    final sub = _packetSubtitle(p);

    Widget trailing;
    if (p.rxRssi != null) {
      trailing = RssiBar(rssi: p.rxRssi!);
    } else if (p.rxSnr != null) {
      final snr = p.rxSnr!;
      trailing = Text('SNR ${snr.toStringAsFixed(1)} dB',
          style: Theme.of(context).textTheme.bodySmall);
    } else {
      trailing = const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 20)),
        title: Text(title),
        subtitle: sub.isNotEmpty ? Text(sub) : null,
        trailing: trailing,
        dense: true,
      ),
    );
  }

  String _textTitle(TextPayloadDto t) {
    final emoji = t.emoji != null && t.emoji != 0 ? String.fromCharCode(t.emoji!) : '📨';
    return '$emoji ${t.text}';
  }

  String _posTitle(PositionPayloadDto pos) {
    final latI = pos.latitudeI;
    final lonI = pos.longitudeI;
    if (latI != null && lonI != null) {
      final lat = latI / 1e7;
      final lon = lonI / 1e7;
      return '📍 ${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
    }
    return '📍 Position update';
  }

  String _waypointTitle(WaypointPayloadDto w) {
    final wp = w.waypoint;
    if ((wp.name ?? '').isNotEmpty) {
      return '📍 Waypoint: ${wp.name}';
    }
    final latI = wp.latitudeI;
    final lonI = wp.longitudeI;
    if (latI != null && lonI != null) {
      return '📍 Waypoint ${ (latI / 1e7).toStringAsFixed(5) }, ${ (lonI / 1e7).toStringAsFixed(5) }';
    }
    return '📍 Waypoint';
  }

  String _userTitle(UserPayloadDto u) {
    final longName = u.user.longName ?? u.user.shortName ?? '';
    return longName.isNotEmpty ? '🪪 $longName' : '🪪 User info';
  }

  String _packetSubtitle(MeshPacketDto p) {
    final parts = <String>[];
    if (p.from != null) parts.add('from=${p.from}');
    if (p.to != null) parts.add('to=${p.to}');
    if (p.channel != null) parts.add('ch=${p.channel}');
    if (p.id != null) parts.add('id=${p.id}');
    return parts.join('  ');
  }

  String _remoteHardwareTitle(RemoteHardwarePayloadDto rh) {
    final type = rh.type ?? 'unknown';
    return '🔧 Remote HW: $type mask=${rh.gpioMask ?? 0} value=${rh.gpioValue ?? 0}';
  }

  String _neighborInfoTitle(NeighborInfoPayloadDto ni) {
    final n = ni.neighbors?.length ?? 0;
    final id = ni.nodeId != null ? 'node=${ni.nodeId} · ' : '';
    return '🕸️ Neighbor info · ${id}edges=$n';
  }

  String _storeForwardTitle(StoreForwardPayloadDto sf) {
    final v = sf.variant ?? 'unknown';
    return '🗄️ Store & Forward ($v)';
    }

  String _telemetryTitle(TelemetryPayloadDto t) {
    final v = t.variant ?? 'unknown';
    return '📊 Telemetry ($v)';
  }

  String _paxcounterTitle(PaxcounterPayloadDto p) {
    final w = p.wifi != null ? 'wifi=${p.wifi}' : null;
    final b = p.ble != null ? 'ble=${p.ble}' : null;
    final parts = [w, b].whereType<String>().toList();
    final rest = parts.isNotEmpty ? ' · ${parts.join(' ')}' : '';
    return '👥 Paxcounter$rest';
  }

  String _keyVerificationTitle(KeyVerificationPayloadDto kv) {
    final n = kv.nonce != null ? 'nonce=${kv.nonce}' : null;
    final parts = [n].whereType<String>().toList();
    final rest = parts.isNotEmpty ? ' (${parts.join(' · ')})' : '';
    return '🔐 Key verification$rest';
  }
}

class _SimpleTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final Color color;
  const _SimpleTile({required this.emoji, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 20)),
        title: Text(title),
        subtitle: (subtitle != null && subtitle!.isNotEmpty) ? Text(subtitle!) : null,
        dense: true,
      ),
    );
  }
}

class _PlainTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final Color color;

  const _PlainTile({
    required this.emoji,
    required this.title,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 20)),
        title: Text(title),
        subtitle: (subtitle != null && subtitle!.isNotEmpty)
            ? Text(subtitle!)
            : null,
        dense: true,
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final LogRecordDto log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final level = (log.level ?? '').toUpperCase();
    final emoji = switch (level) {
      'ERROR' => '⛔',
      'WARN' => '⚠️',
      'INFO' => 'ℹ️',
      'DEBUG' => '🐞',
      _ => '📝',
    };
    final color = switch (level) {
      'ERROR' => Colors.red,
      'WARN' => Colors.orange,
      'INFO' => Colors.blue,
      'DEBUG' => Colors.grey,
      _ => Colors.grey,
    };
    final msg = (log.message ?? '');
    final src = (log.source ?? '');
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 20)),
        title: Text(src.isNotEmpty ? src : 'Log'),
        subtitle: Text(msg),
        dense: true,
      ),
    );
  }
}

String? _queuePreview(QueueStatusDto s) {
  final parts = <String>[];
  if (s.free != null) parts.add('free=${s.free}');
  if (s.maxlen != null) parts.add('max=${s.maxlen}');
  if (s.meshPacketId != null) parts.add('id=${s.meshPacketId}');
  return parts.isEmpty ? null : parts.join('  ');
}

String? _fileInfoPreview(FileInfoDto f) {
  final parts = <String>[];
  if (f.fileName != null && f.fileName!.isNotEmpty) parts.add(f.fileName!);
  if (f.sizeBytes != null) parts.add('${f.sizeBytes} bytes');
  return parts.isEmpty ? null : parts.join('  ');
}
