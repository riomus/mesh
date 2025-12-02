import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

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
          title: AppLocalizations.of(context).myInfo,
          subtitle: e.myInfo.myNodeNum != null
              ? 'myNodeNum=${e.myInfo.myNodeNum}'
              : null,
          color: Colors.indigo,
        );
      case NodeInfoEvent e:
        return _SimpleTile(
          emoji: '🪪',
          title: _nodeTitle(context, e.nodeInfo),
          subtitle: e.nodeInfo.num != null ? 'num=${e.nodeInfo.num}' : null,
          color: Colors.deepPurple,
        );
      case ConfigEvent _:
        return _SimpleTile(
          emoji: '⚙️',
          title: AppLocalizations.of(context).configUpdate,
          subtitle: null,
          color: Colors.teal,
        );
      case ConfigCompleteEvent e:
        return _PlainTile(
          emoji: '✅',
          title: AppLocalizations.of(context).configStreamComplete,
          subtitle: 'id=${e.configCompleteId}',
          color: Colors.teal,
        );
      case RebootedEvent e:
        return _PlainTile(
          emoji: e.rebooted ? '🔁' : 'ℹ️',
          title: AppLocalizations.of(context).rebooted,
          subtitle: e.rebooted
              ? AppLocalizations.of(context).deviceReportedReboot
              : AppLocalizations.of(context).noReboot,
          color: Colors.orange,
        );
      case ModuleConfigEvent _:
        return _SimpleTile(
          emoji: '🧩',
          title: AppLocalizations.of(context).moduleConfig,
          subtitle: null,
          color: Colors.blueGrey,
        );
      case ChannelEvent e:
        return _SimpleTile(
          emoji: '📡',
          title: AppLocalizations.of(context).channelUpdate,
          subtitle: e.channel.index != null ? 'index=${e.channel.index}' : null,
          color: Colors.blue,
        );
      case QueueStatusEvent e:
        return _SimpleTile(
          emoji: '📬',
          title: AppLocalizations.of(context).queueStatus,
          subtitle: _queuePreview(e.status),
          color: Colors.cyan,
        );
      case DeviceMetadataEvent e:
        return _SimpleTile(
          emoji: '🧰',
          title: AppLocalizations.of(context).deviceMetadata,
          subtitle: _deviceMetadataPreview(e.metadata),
          color: Colors.brown,
        );
      case MqttClientProxyEvent _:
        return _SimpleTile(
          emoji: '☁️',
          title: AppLocalizations.of(context).mqttProxy,
          subtitle: null,
          color: Colors.lightBlue,
        );
      case FileInfoEvent e:
        return _SimpleTile(
          emoji: '📁',
          title: AppLocalizations.of(context).fileInfo,
          subtitle: _fileInfoPreview(e.fileInfo),
          color: Colors.amber,
        );
      case ClientNotificationEvent e:
        return _SimpleTile(
          emoji: '🔔',
          title: AppLocalizations.of(context).clientNotification,
          subtitle: e.notification.message,
          color: Colors.pink,
        );
      case DeviceUiConfigEvent _:
        return _SimpleTile(
          emoji: '🖥️',
          title: AppLocalizations.of(context).deviceUiConfig,
          subtitle: null,
          color: Colors.green,
        );
      case LogRecordEvent e:
        return _LogTile(log: e.logRecord);
      case XModemEvent e:
        return _SimpleTile(
          emoji: '💾',
          title: 'XModem',
          subtitle: 'seq=${e.xmodem.seq} control=${e.xmodem.control}',
          color: Colors.blueGrey,
        );
    }
  }

  static String _nodeTitle(BuildContext context, NodeInfoDto dto) {
    final name = dto.user?.longName ?? dto.user?.shortName ?? '';
    final num = dto.num;
    return name.isNotEmpty
        ? '${AppLocalizations.of(context).nodeTitle(name)}${num != null ? ' ($num)' : ''}'
        : (num != null
              ? AppLocalizations.of(context).nodeTitleId(num)
              : AppLocalizations.of(context).nodeInfo);
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
      PositionPayloadDto pos => _posTitle(context, pos),
      WaypointPayloadDto w => _waypointTitle(context, w),
      UserPayloadDto u => _userTitle(context, u),
      RoutingPayloadDto _ => AppLocalizations.of(context).routingMessage,
      AdminPayloadDto _ => AppLocalizations.of(context).adminMessage,
      RemoteHardwarePayloadDto rh => _remoteHardwareTitle(context, rh),
      NeighborInfoPayloadDto ni => _neighborInfoTitle(context, ni),
      StoreForwardPayloadDto sf => _storeForwardTitle(context, sf),
      TelemetryPayloadDto t => _telemetryTitle(context, t),
      PaxcounterPayloadDto p => _paxcounterTitle(context, p),
      TraceroutePayloadDto _ => AppLocalizations.of(context).traceroute,
      KeyVerificationPayloadDto kv => _keyVerificationTitle(context, kv),
      RawPayloadDto r => AppLocalizations.of(
        context,
      ).rawPayloadDetails(r.portnum.name, r.portnum.id, r.bytes.length),
      null => AppLocalizations.of(context).encryptedUnknownPayload,
    };

    final sub = _packetSubtitle(p);

    Widget trailing;
    if (p.rxRssi != null) {
      trailing = RssiBar(rssi: p.rxRssi!);
    } else if (p.rxSnr != null) {
      final snr = p.rxSnr!;
      trailing = Text(
        AppLocalizations.of(context).snrDb(snr.toStringAsFixed(1)),
        style: Theme.of(context).textTheme.bodySmall,
      );
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
    final emoji = t.emoji != null && t.emoji != 0
        ? String.fromCharCode(t.emoji!)
        : '📨';
    return '$emoji ${t.text}';
  }

  String _posTitle(BuildContext context, PositionPayloadDto pos) {
    final latI = pos.latitudeI;
    final lonI = pos.longitudeI;
    if (latI != null && lonI != null) {
      final lat = latI / 1e7;
      final lon = lonI / 1e7;
      return '📍 ${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
    }
    return '📍 ${AppLocalizations.of(context).positionUpdate}';
  }

  String _waypointTitle(BuildContext context, WaypointPayloadDto w) {
    final wp = w.waypoint;
    if ((wp.name ?? '').isNotEmpty) {
      return '📍 ${AppLocalizations.of(context).waypoint}: ${wp.name}';
    }
    final latI = wp.latitudeI;
    final lonI = wp.longitudeI;
    if (latI != null && lonI != null) {
      return '📍 ${AppLocalizations.of(context).waypoint} ${(latI / 1e7).toStringAsFixed(5)}, ${(lonI / 1e7).toStringAsFixed(5)}';
    }
    return '📍 ${AppLocalizations.of(context).waypoint}';
  }

  String _userTitle(BuildContext context, UserPayloadDto u) {
    final longName = u.user.longName ?? u.user.shortName ?? '';
    return longName.isNotEmpty
        ? '🪪 $longName'
        : '🪪 ${AppLocalizations.of(context).userInfo}';
  }

  String _packetSubtitle(MeshPacketDto p) {
    final parts = <String>[];
    if (p.from != null) parts.add('from=${p.from}');
    if (p.to != null) parts.add('to=${p.to}');
    if (p.channel != null) parts.add('ch=${p.channel}');
    if (p.id != null) parts.add('id=${p.id}');
    return parts.join('  ');
  }

  String _remoteHardwareTitle(
    BuildContext context,
    RemoteHardwarePayloadDto rh,
  ) {
    final type = rh.type ?? AppLocalizations.of(context).unknown;
    return AppLocalizations.of(
      context,
    ).remoteHw(type, rh.gpioMask ?? 0, rh.gpioValue ?? 0);
  }

  String _neighborInfoTitle(BuildContext context, NeighborInfoPayloadDto ni) {
    final n = ni.neighbors?.length ?? 0;
    final id = ni.nodeId != null ? 'node=${ni.nodeId} · ' : '';
    return '🕸️ ${AppLocalizations.of(context).neighborInfo} · ${id}edges=$n';
  }

  String _storeForwardTitle(BuildContext context, StoreForwardPayloadDto sf) {
    final v = sf.variant ?? AppLocalizations.of(context).unknown;
    return AppLocalizations.of(context).storeForwardVariant(v);
  }

  String _telemetryTitle(BuildContext context, TelemetryPayloadDto t) {
    final v = t.variant ?? AppLocalizations.of(context).unknown;
    return AppLocalizations.of(context).telemetryVariant(v);
  }

  String _paxcounterTitle(BuildContext context, PaxcounterPayloadDto p) {
    final w = p.wifi != null ? 'wifi=${p.wifi}' : null;
    final b = p.ble != null ? 'ble=${p.ble}' : null;
    final parts = [w, b].whereType<String>().toList();
    final rest = parts.isNotEmpty ? ' · ${parts.join(' ')}' : '';
    return '👥 ${AppLocalizations.of(context).paxcounter}$rest';
  }

  String _keyVerificationTitle(
    BuildContext context,
    KeyVerificationPayloadDto kv,
  ) {
    final n = kv.nonce != null ? 'nonce=${kv.nonce}' : null;
    final parts = [n].whereType<String>().toList();
    final rest = parts.isNotEmpty ? ' (${parts.join(' · ')})' : '';
    return '🔐 ${AppLocalizations.of(context).keyVerification}$rest';
  }
}

class _SimpleTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final Color color;
  const _SimpleTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
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
        title: Text(
          src.isNotEmpty ? src : AppLocalizations.of(context).logRecord,
        ),
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
