import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/text_sanitize.dart';

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
              ? AppLocalizations.of(
                  context,
                ).myNodeNumLabel(e.myInfo.myNodeNum.toString())
              : null,
          color: Colors.indigo,
        );
      case NodeInfoEvent e:
        return _SimpleTile(
          emoji: '🪪',
          title: _nodeTitle(context, e.nodeInfo),
          subtitle: e.nodeInfo.num != null
              ? AppLocalizations.of(
                  context,
                ).nodeNumLabel(e.nodeInfo.num.toString())
              : null,
          color: Colors.deepPurple,
        );
      case ConfigEvent e:
        return _SimpleTile(
          emoji: '⚙️',
          title: AppLocalizations.of(context).configUpdate,
          subtitle: _configSubtitle(context, e.config),
          color: Colors.teal,
        );
      case ConfigCompleteEvent e:
        return _PlainTile(
          emoji: '✅',
          title: AppLocalizations.of(context).configStreamComplete,
          subtitle: AppLocalizations.of(
            context,
          ).idLabel(e.configCompleteId.toString()),
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
      case ModuleConfigEvent e:
        return _SimpleTile(
          emoji: '🧩',
          title: AppLocalizations.of(context).moduleConfig,
          subtitle: _moduleConfigSubtitle(context, e.moduleConfig),
          color: Colors.blueGrey,
        );
      case ChannelEvent e:
        return _SimpleTile(
          emoji: '📡',
          title: AppLocalizations.of(context).channelUpdate,
          subtitle: e.channel.index != null
              ? AppLocalizations.of(
                  context,
                ).channelIndexLabel(e.channel.index.toString())
              : null,
          color: Colors.blue,
        );
      case QueueStatusEvent e:
        return _SimpleTile(
          emoji: '📬',
          title: AppLocalizations.of(context).queueStatus,
          subtitle: _queuePreview(context, e.status),
          color: Colors.cyan,
        );
      case DeviceMetadataEvent e:
        return _SimpleTile(
          emoji: '🧰',
          title: AppLocalizations.of(context).deviceMetadata,
          subtitle: _deviceMetadataPreview(context, e.metadata),
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
          subtitle: _fileInfoPreview(context, e.fileInfo),
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
          title: AppLocalizations.of(context).xmodem,
          subtitle: AppLocalizations.of(
            context,
          ).xmodemStatus(e.xmodem.seq.toString(), e.xmodem.control.toString()),
          color: Colors.blueGrey,
        );
      case MeshCoreCommandResponseEvent e:
        return _SimpleTile(
          emoji: '📟',
          title: 'Command Response',
          subtitle: e.responseDescription,
          color: e.responseCode == 0 ? Colors.green : Colors.red,
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

  String? _configSubtitle(BuildContext context, ConfigDto config) {
    final parts = <String>[];
    if (config.device != null) {
      parts.add('Device');
    }
    if (config.position != null) {
      parts.add('Position');
    }
    if (config.power != null) {
      parts.add('Power');
    }
    if (config.network != null) {
      parts.add('Network');
    }
    if (config.display != null) {
      parts.add('Display');
    }
    if (config.lora != null) {
      parts.add('LoRa');
    }
    if (config.bluetooth != null) {
      parts.add('Bluetooth');
    }
    if (config.security != null) {
      parts.add('Security');
    }
    if (config.sessionkey != null) {
      parts.add('Session Key');
    }

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  String? _moduleConfigSubtitle(BuildContext context, ModuleConfigDto config) {
    final parts = <String>[];
    if (config.mqtt != null) {
      parts.add('MQTT');
    }
    if (config.telemetry != null) {
      parts.add('Telemetry');
    }
    if (config.serial != null) {
      parts.add('Serial');
    }
    if (config.storeForward != null) {
      parts.add('Store & Forward');
    }
    if (config.rangeTest != null) {
      parts.add('Range Test');
    }
    if (config.externalNotification != null) {
      parts.add('External Notification');
    }
    if (config.audio != null) {
      parts.add('Audio');
    }
    if (config.neighborInfo != null) {
      parts.add('Neighbor Info');
    }
    if (config.remoteHardware != null) {
      parts.add('Remote Hardware');
    }
    if (config.paxcounter != null) {
      parts.add('Paxcounter');
    }
    if (config.cannedMessage != null) {
      parts.add('Canned Message');
    }
    if (config.ambientLighting != null) {
      parts.add('Ambient Lighting');
    }
    if (config.detectionSensor != null) {
      parts.add('Detection Sensor');
    }
    if (config.dtnOverlay != null) {
      parts.add('DTN Overlay');
    }
    if (config.broadcastAssist != null) {
      parts.add('Broadcast Assist');
    }
    if (config.nodeMod != null) {
      parts.add('Node Mod');
    }
    if (config.nodeModAdmin != null) {
      parts.add('Node Mod Admin');
    }
    if (config.idleGame != null) {
      parts.add('Idle Game');
    }

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }
}

String? _deviceMetadataPreview(BuildContext context, DeviceMetadataDto dm) {
  final parts = <String>[];
  if (dm.firmwareVersion != null) {
    parts.add(AppLocalizations.of(context).fwLabel(dm.firmwareVersion!));
  }
  if (dm.hwModel != null) {
    parts.add(AppLocalizations.of(context).hwLabel(dm.hwModel.toString()));
  }
  if (dm.role != null) {
    parts.add(AppLocalizations.of(context).roleKey(dm.role.toString()));
  }
  if (dm.hasWifi == true) {
    parts.add(AppLocalizations.of(context).wifiLabel);
  }
  if (dm.hasBluetooth == true) {
    parts.add(AppLocalizations.of(context).btLabel);
  }
  if (dm.hasEthernet == true) {
    parts.add(AppLocalizations.of(context).ethLabel);
  }
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

    final sub = _packetSubtitle(context, p);

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
        title: Text(safeText(title)),
        subtitle: sub.isNotEmpty ? Text(safeText(sub)) : null,
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

  String _packetSubtitle(BuildContext context, MeshPacketDto p) {
    final parts = <String>[];
    if (p.from != null) {
      parts.add(AppLocalizations.of(context).fromLabel(p.from.toString()));
    }
    if (p.to != null) {
      parts.add(AppLocalizations.of(context).toLabel(p.to.toString()));
    }
    if (p.channel != null) {
      parts.add(AppLocalizations.of(context).chLabel(p.channel.toString()));
    }
    if (p.id != null) {
      parts.add(AppLocalizations.of(context).idLabel(p.id.toString()));
    }
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
    final w = p.wifi != null
        ? '${AppLocalizations.of(context).wifiLabel}=${p.wifi}'
        : null;
    final b = p.ble != null
        ? '${AppLocalizations.of(context).btLabel}=${p.ble}'
        : null;
    final parts = [w, b].whereType<String>().toList();
    final rest = parts.isNotEmpty ? ' · ${parts.join(' ')}' : '';
    return '👥 ${AppLocalizations.of(context).paxcounter}$rest';
  }

  String _keyVerificationTitle(
    BuildContext context,
    KeyVerificationPayloadDto kv,
  ) {
    final n = kv.nonce != null
        ? AppLocalizations.of(context).nonceLabel(kv.nonce.toString())
        : null;
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
        title: Text(safeText(title)),
        subtitle: (subtitle != null && subtitle!.isNotEmpty)
            ? Text(safeText(subtitle!))
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
          safeText(
            src.isNotEmpty ? src : AppLocalizations.of(context).logRecord,
          ),
        ),
        subtitle: Text(safeText(msg)),
        dense: true,
      ),
    );
  }
}

String? _queuePreview(BuildContext context, QueueStatusDto s) {
  final parts = <String>[];
  if (s.free != null) {
    parts.add(AppLocalizations.of(context).freeLabel(s.free.toString()));
  }
  if (s.maxlen != null) {
    parts.add(AppLocalizations.of(context).maxLabel(s.maxlen.toString()));
  }
  if (s.meshPacketId != null) {
    parts.add(AppLocalizations.of(context).idLabel(s.meshPacketId.toString()));
  }
  return parts.isEmpty ? null : parts.join('  ');
}

String? _fileInfoPreview(BuildContext context, FileInfoDto f) {
  final parts = <String>[];
  if (f.fileName != null && f.fileName!.isNotEmpty) {
    parts.add(f.fileName!);
  }
  if (f.sizeBytes != null) {
    parts.add(AppLocalizations.of(context).bytesLabel(f.sizeBytes.toString()));
  }
  return parts.isEmpty ? null : parts.join('  ');
}
