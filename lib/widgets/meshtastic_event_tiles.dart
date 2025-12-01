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
          subtitle: e.metadata.myNodeNum != null ? 'myNodeNum=${e.metadata.myNodeNum}' : null,
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

class _PacketTile extends StatelessWidget {
  final MeshPacketEvent e;
  const _PacketTile({required this.e});

  @override
  Widget build(BuildContext context) {
    final p = e.packet;
    final decoded = e.decoded;
    final emoji = switch (decoded) {
      TextPayloadDto _ => '💬',
      PositionPayloadDto _ => '📍',
      UserPayloadDto _ => '🪪',
      RoutingPayloadDto _ => '🧭',
      AdminPayloadDto _ => '🛠️',
      RawPayloadDto _ => '📦',
      null => '📦',
    };

    final color = switch (decoded) {
      TextPayloadDto _ => Colors.green,
      PositionPayloadDto _ => Colors.blue,
      UserPayloadDto _ => Colors.purple,
      RoutingPayloadDto _ => Colors.orange,
      AdminPayloadDto _ => Colors.teal,
      RawPayloadDto _ => Colors.grey,
      null => Colors.grey,
    };

    final title = switch (decoded) {
      TextPayloadDto t => _textTitle(t),
      PositionPayloadDto pos => _posTitle(pos),
      UserPayloadDto u => _userTitle(u),
      RoutingPayloadDto _ => 'Routing message',
      AdminPayloadDto _ => 'Admin message',
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
  if (s.size != null) parts.add('size=${s.size}');
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
