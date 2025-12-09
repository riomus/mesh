import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import '../services/device_communication_event_service.dart';
import '../widgets/meshtastic_event_tiles.dart';
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../widgets/map_section.dart';

class EventDetailsPage extends StatelessWidget {
  final DeviceEvent event;
  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final payload = event.payload;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).eventDetails)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header / Hero tile if Meshtastic
                if (payload case MeshtasticDeviceEventPayload m)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: MeshtasticEventTile(event: m.event),
                    ),
                  ),
                if (payload case MeshtasticDeviceEventPayload m)
                  _Section(
                    emoji: '🆔',
                    title: AppLocalizations.of(context).idTitle,
                    child: Text(
                      m.event.id?.toString() ??
                          AppLocalizations.of(context).emptyState,
                    ),
                  ),
                _Section(
                  emoji: '⏱️',
                  title: AppLocalizations.of(context).timestamp,
                  child: Text(event.timestamp.toLocal().toString()),
                ),
                if (event.summary != null && event.summary!.isNotEmpty)
                  _Section(
                    emoji: '📝',
                    title: AppLocalizations.of(context).summary,
                    child: Text(event.summary!),
                  ),
                if (event.tags.isNotEmpty)
                  _Section(
                    emoji: '🏷️',
                    title: AppLocalizations.of(context).tags,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: event.tags.entries
                          .map(
                            (e) => InputChip(
                              label: Text('${e.key}: ${e.value.join(', ')}'),
                              onPressed: () {},
                            ),
                          )
                          .toList(),
                    ),
                  ),
                if (payload case MeshtasticDeviceEventPayload m)
                  _MeshtasticEventDetails(event: m.event)
                else if (payload != null)
                  _Section(
                    emoji: '📦',
                    title: AppLocalizations.of(context).payload,
                    child: Text(payload.runtimeType.toString()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String emoji;
  final String title;
  final Widget child;
  const _Section({
    required this.emoji,
    required this.title,
    required this.child,
  });

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
        return _meshPacket(context, e);
      case MyInfoEvent e:
        return _Section(
          emoji: '🧩',
          title: AppLocalizations.of(context).myInfo,
          child: _kvTable(context, {
            'myNodeNum': e.myInfo.myNodeNum,
            'rebootCount': e.myInfo.rebootCount,
            'minAppVersion': e.myInfo.minAppVersion,
            'firmwareEdition': e.myInfo.firmwareEdition,
            'nodedbCount': e.myInfo.nodedbCount,
            'pioEnv': e.myInfo.pioEnv,
            'deviceId': e.myInfo.deviceId?.length,
          }),
        );
      case NodeInfoEvent e:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasValidCoords(
              e.nodeInfo.position?.latitudeI,
              e.nodeInfo.position?.longitudeI,
            ))
              MapSection(
                latitude: latFromI(e.nodeInfo.position?.latitudeI)!,
                longitude: lonFromI(e.nodeInfo.position?.longitudeI)!,
                label: e.nodeInfo.user?.shortName ?? e.nodeInfo.user?.longName,
              ),
            _Section(
              emoji: '🪪',
              title: AppLocalizations.of(context).nodeInfo,
              child: _kvTable(context, {
                'num': e.nodeInfo.num,
                'user.longName': e.nodeInfo.user?.longName,
                'user.shortName': e.nodeInfo.user?.shortName,
                'position.lat': e.nodeInfo.position?.latitudeI,
                'position.lon': e.nodeInfo.position?.longitudeI,
                'snr': e.nodeInfo.snr,
                'lastHeard': e.nodeInfo.lastHeard,
                'channel': e.nodeInfo.channel,
                'viaMqtt': e.nodeInfo.viaMqtt,
                'hopsAway': e.nodeInfo.hopsAway,
                'isFavorite': e.nodeInfo.isFavorite,
                'isIgnored': e.nodeInfo.isIgnored,
                'isKeyManuallyVerified': e.nodeInfo.isKeyManuallyVerified,
                'batt': e.nodeInfo.deviceMetrics?.batteryLevel,
                'volt': e.nodeInfo.deviceMetrics?.voltage,
                'chUtil': e.nodeInfo.deviceMetrics?.channelUtilization,
                'airUtil': e.nodeInfo.deviceMetrics?.airUtilTx,
                'uptime': e.nodeInfo.deviceMetrics?.uptimeSeconds,
              }),
            ),
          ],
        );
      case ConfigEvent e:
        return _Section(
          emoji: '⚙️',
          title: AppLocalizations.of(context).config,
          child: _configDetails(context, e.config),
        );
      case ConfigCompleteEvent e:
        return _Section(
          emoji: '✅',
          title: AppLocalizations.of(context).configComplete,
          child: _kvTable(context, {'id': e.configCompleteId}),
        );
      case RebootedEvent e:
        return _Section(
          emoji: '🔁',
          title: AppLocalizations.of(context).rebooted,
          child: _kvTable(context, {'rebooted': e.rebooted}),
        );
      case ModuleConfigEvent e:
        return _Section(
          emoji: '🧩',
          title: AppLocalizations.of(context).moduleConfig,
          child: _moduleConfigDetails(context, e.moduleConfig),
        );
      case ChannelEvent e:
        return _Section(
          emoji: '📡',
          title: AppLocalizations.of(context).channel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kvTable(context, {
                'index': e.channel.index,
                'role': e.channel.role,
              }),
              if (e.channel.settings != null) ...[
                const SizedBox(height: 8),
                _Subheader(AppLocalizations.of(context).settingsButtonLabel),
                _channelSettingsDetails(context, e.channel.settings!),
              ],
            ],
          ),
        );
      case QueueStatusEvent e:
        return _Section(
          emoji: '📬',
          title: AppLocalizations.of(context).queueStatus,
          child: _kvTable(context, {
            'res': e.status.res,
            'size': e.status.free,
            'maxlen': e.status.maxlen,
            'meshPacketId': e.status.meshPacketId,
          }),
        );
      case DeviceMetadataEvent e:
        return _Section(
          emoji: '🧰',
          title: AppLocalizations.of(context).deviceMetadata,
          child: _kvTable(context, {
            'fw': e.metadata.firmwareVersion,
            'hw': e.metadata.hwModel,
            'role': e.metadata.role,
            'wifi': e.metadata.hasWifi,
            'bt': e.metadata.hasBluetooth,
            'eth': e.metadata.hasEthernet,
            'stateVer': e.metadata.deviceStateVersion,
            'canShutdown': e.metadata.canShutdown,
            'posFlags': e.metadata.positionFlags,
            'hasRemoteHw': e.metadata.hasRemoteHardware,
            'hasPKC': e.metadata.hasPKC,
            'excluded': e.metadata.excludedModules,
            'hasFwPlus': e.metadata.hasFwPlus,
            'hasNodemod': e.metadata.hasNodemod,
          }),
        );
      case MqttClientProxyEvent e:
        return _Section(
          emoji: '☁️',
          title: AppLocalizations.of(context).mqttProxy,
          child: _kvTable(context, {
            'topic': e.message.topic,
            'retained': e.message.retained,
            'text': e.message.text,
            'dataLen': e.message.data?.length,
          }),
        );
      case FileInfoEvent e:
        return _Section(
          emoji: '📁',
          title: AppLocalizations.of(context).fileInfo,
          child: _kvTable(context, {
            'name': e.fileInfo.fileName,
            'sizeBytes': e.fileInfo.sizeBytes,
          }),
        );
      case ClientNotificationEvent e:
        return _Section(
          emoji: '🔔',
          title: AppLocalizations.of(context).clientNotification,
          child: _kvTable(context, {
            'message': e.notification.message,
            'replyId': e.notification.replyId,
            'time': e.notification.time,
            'level': e.notification.level,
            'payloadVariant': e.notification.payloadVariant,
          }),
        );
      case DeviceUiConfigEvent e:
        return _Section(
          emoji: '🖥️',
          title: AppLocalizations.of(context).deviceUiConfig,
          child: _deviceUiConfigDetails(context, e.uiConfig),
        );
      case LogRecordEvent e:
        return _Section(
          emoji: '🪵',
          title: AppLocalizations.of(context).logRecord,
          child: _kvTable(context, {
            'source': e.logRecord.source,
            'message': e.logRecord.message,
          }),
        );
      case XModemEvent e:
        return _Section(
          emoji: '💾',
          title: AppLocalizations.of(context).xmodemTitle,
          child: _kvTable(context, {
            'control': e.xmodem.control,
            'seq': e.xmodem.seq,
            'crc16': e.xmodem.crc16,
            'buffer': e.xmodem.buffer?.length,
          }),
        );
    }
  }

  Widget _meshPacket(BuildContext context, MeshPacketEvent e) {
    final p = e.packet;
    final header = _Section(
      emoji: '📦',
      title: AppLocalizations.of(context).packet,
      child: _kvTable(context, {
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
        'hopStart': p.hopStart,
        'encrypted': p.encrypted?.length,
        'publicKey': p.publicKey?.length,
        'pkiEncrypted': p.pkiEncrypted,
        'nextHop': p.nextHop,
        'relayNode': p.relayNode,
        'txAfter': p.txAfter,
      }),
    );

    final decoded = e.decoded;
    if (decoded == null) return header;

    final decodedSection = switch (decoded) {
      TextPayloadDto t => _Section(
        emoji: '💬',
        title: AppLocalizations.of(context).textPayload,
        child: _kvTable(context, {'text': t.text, 'emoji': t.emoji}),
      ),
      PositionPayloadDto pos => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasValidCoords(pos.latitudeI, pos.longitudeI))
            MapSection(
              latitude: latFromI(pos.latitudeI)!,
              longitude: lonFromI(pos.longitudeI)!,
              label: AppLocalizations.of(context).position,
            ),
          _Section(
            emoji: '📍',
            title: AppLocalizations.of(context).position,
            child: _kvTable(context, {
              'latI': pos.latitudeI,
              'lonI': pos.longitudeI,
              'alt': pos.position.altitude,
              'time': pos.position.time,
              'gpsAcc': pos.position.gpsAccuracy,
              'sats': pos.position.satsInView,
              'locSource': pos.position.locationSource,
              'altSource': pos.position.altitudeSource,
              'ts': pos.position.timestamp,
              'tsMillisAdj': pos.position.timestampMillisAdjust,
              'altHae': pos.position.altitudeHae,
              'altGeoSep': pos.position.altitudeGeoidalSeparation,
              'pDOP': pos.position.pDOP,
              'hDOP': pos.position.hDOP,
              'vDOP': pos.position.vDOP,
              'groundSpeed': pos.position.groundSpeed,
              'groundTrack': pos.position.groundTrack,
              'fixQuality': pos.position.fixQuality,
              'fixType': pos.position.fixType,
              'sensorId': pos.position.sensorId,
              'nextUpdate': pos.position.nextUpdate,
              'seqNumber': pos.position.seqNumber,
              'precisionBits': pos.position.precisionBits,
            }),
          ),
        ],
      ),
      WaypointPayloadDto w => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasValidCoords(w.waypoint.latitudeI, w.waypoint.longitudeI))
            MapSection(
              latitude: latFromI(w.waypoint.latitudeI)!,
              longitude: lonFromI(w.waypoint.longitudeI)!,
              label: w.waypoint.name,
            ),
          _Section(
            emoji: '📍',
            title: AppLocalizations.of(context).waypoint,
            child: _kvTable(context, {
              'name': w.waypoint.name,
              'id': w.waypoint.id,
              'latI': w.waypoint.latitudeI,
              'lonI': w.waypoint.longitudeI,
              'expire': w.waypoint.expire,
              'lockedTo': w.waypoint.lockedTo,
              'desc': w.waypoint.description,
              'icon': w.waypoint.icon,
            }),
          ),
        ],
      ),
      UserPayloadDto u => _Section(
        emoji: '🪪',
        title: AppLocalizations.of(context).user,
        child: _kvTable(context, {
          'id': u.user.id,
          'longName': u.user.longName,
          'shortName': u.user.shortName,
          'mac': u.user.macaddr?.length,
          'hwModel': u.user.hwModel,
          'isLicensed': u.user.isLicensed,
          'role': u.user.role,
          'pubKey': u.user.publicKey?.length,
          'isUnmessagable': u.user.isUnmessagable,
        }),
      ),
      RoutingPayloadDto r => _Section(
        emoji: '🧭',
        title: AppLocalizations.of(context).routing,
        child: _kvTable(context, {
          'variant': r.variant,
          'errorReason': r.errorReason,
          'requestId': r.requestId,
        }),
      ),
      AdminPayloadDto a => _Section(
        emoji: '🛠️',
        title: AppLocalizations.of(context).admin,
        child: _kvTable(context, {'variant': a.variant}),
      ),
      RemoteHardwarePayloadDto rh => _Section(
        emoji: '🔧',
        title: AppLocalizations.of(context).remoteHardware,
        child: _kvTable(context, {
          'type': rh.type,
          'gpioMask': rh.gpioMask,
          'gpioValue': rh.gpioValue,
        }),
      ),
      NeighborInfoPayloadDto ni => _Section(
        emoji: '🕸️',
        title: AppLocalizations.of(context).neighborInfo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kvTable(context, {
              'nodeId': ni.nodeId,
              'lastSentById': ni.lastSentById,
              'nodeBroadcastIntervalSecs': ni.nodeBroadcastIntervalSecs,
            }),
            if (ni.neighbors != null && ni.neighbors!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).neighbors,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Column(
                children: ni.neighbors!
                    .map(
                      (n) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: _kvTable(context, {
                          'nodeId': n.nodeId,
                          'snr': n.snr,
                          'lastRxTime': n.lastRxTime,
                          'broadcastIntSecs': n.nodeBroadcastIntervalSecs,
                        }),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
      StoreForwardPayloadDto sf => _Section(
        emoji: '🗄️',
        title: AppLocalizations.of(context).storeForward,
        child: _kvTable(context, {'variant': sf.variant}),
      ),
      TelemetryPayloadDto t => _Section(
        emoji: '📊',
        title: AppLocalizations.of(context).telemetry,
        child: _telemetryDetails(context, t),
      ),
      PaxcounterPayloadDto p => _Section(
        emoji: '👥',
        title: AppLocalizations.of(context).paxcounter,
        child: _kvTable(context, {
          'wifi': p.wifi,
          'ble': p.ble,
          'uptime': p.uptime,
        }),
      ),
      TraceroutePayloadDto tr => _Section(
        emoji: '🔎',
        title: AppLocalizations.of(context).traceroute,
        child: _kvTable(context, {
          'routeLen': tr.route?.length,
          'hops': tr.route?.map((e) => e.toString()).join(' -> '),
          'snrTowards': tr.snrTowards?.join(', '),
          'routeBackLen': tr.routeBack?.length,
          'snrBack': tr.snrBack?.join(', '),
        }),
      ),
      KeyVerificationPayloadDto kv => _Section(
        emoji: '🔐',
        title: AppLocalizations.of(context).keyVerification,
        child: _kvTable(context, {
          'nonce': kv.nonce,
          'hash1': kv.hash1?.length,
          'hash2': kv.hash2?.length,
        }),
      ),
      RawPayloadDto r => _Section(
        emoji: '📦',
        title: AppLocalizations.of(context).rawPayload,
        child: _kvTable(context, {
          'port': '${r.portnum.name}:${r.portnum.id}',
          'bytes': r.bytes.length,
        }),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, decodedSection],
    );
  }

  Widget _telemetryDetails(BuildContext context, TelemetryPayloadDto t) {
    final children = <Widget>[
      _kvTable(context, {'variant': t.variant, 'time': t.time}),
    ];

    if (t.deviceMetrics != null) {
      children.add(_Subheader(AppLocalizations.of(context).deviceMetricsTitle));
      children.add(
        _kvTable(context, {
          'batteryLevel': t.deviceMetrics!.batteryLevel,
          'voltage': t.deviceMetrics!.voltage,
          'channelUtilization': t.deviceMetrics!.channelUtilization,
          'airUtilTx': t.deviceMetrics!.airUtilTx,
          'uptimeSeconds': t.deviceMetrics!.uptimeSeconds,
        }),
      );
    }

    if (t.environmentMetrics != null) {
      children.add(
        _Subheader(AppLocalizations.of(context).environmentMetricsTitle),
      );
      children.add(
        _kvTable(context, {
          'temperature': t.environmentMetrics!.temperature,
          'relativeHumidity': t.environmentMetrics!.relativeHumidity,
          'barometricPressure': t.environmentMetrics!.barometricPressure,
          'gasResistance': t.environmentMetrics!.gasResistance,
          'voltage': t.environmentMetrics!.voltage,
          'current': t.environmentMetrics!.current,
          'iaq': t.environmentMetrics!.iaq,
          'distance': t.environmentMetrics!.distance,
          'lux': t.environmentMetrics!.lux,
          'whiteLux': t.environmentMetrics!.whiteLux,
          'irLux': t.environmentMetrics!.irLux,
          'uvLux': t.environmentMetrics!.uvLux,
          'windDirection': t.environmentMetrics!.windDirection,
          'windSpeed': t.environmentMetrics!.windSpeed,
          'weight': t.environmentMetrics!.weight,
          'windGust': t.environmentMetrics!.windGust,
          'windLull': t.environmentMetrics!.windLull,
        }),
      );
    }

    if (t.airQualityMetrics != null) {
      children.add(
        _Subheader(AppLocalizations.of(context).airQualityMetricsTitle),
      );
      children.add(
        _kvTable(context, {
          'pm10Standard': t.airQualityMetrics!.pm10Standard,
          'pm25Standard': t.airQualityMetrics!.pm25Standard,
          'pm100Standard': t.airQualityMetrics!.pm100Standard,
          'pm10Environmental': t.airQualityMetrics!.pm10Environmental,
          'pm25Environmental': t.airQualityMetrics!.pm25Environmental,
          'pm100Environmental': t.airQualityMetrics!.pm100Environmental,
          'particles03um': t.airQualityMetrics!.particles03um,
          'particles05um': t.airQualityMetrics!.particles05um,
          'particles10um': t.airQualityMetrics!.particles10um,
          'particles25um': t.airQualityMetrics!.particles25um,
          'particles50um': t.airQualityMetrics!.particles50um,
          'particles100um': t.airQualityMetrics!.particles100um,
          'co2': t.airQualityMetrics!.co2,
          'co2Temperature': t.airQualityMetrics!.co2Temperature,
          'co2Humidity': t.airQualityMetrics!.co2Humidity,
          'formFormaldehyde': t.airQualityMetrics!.formFormaldehyde,
          'formHumidity': t.airQualityMetrics!.formHumidity,
          'formTemperature': t.airQualityMetrics!.formTemperature,
          'pm40Standard': t.airQualityMetrics!.pm40Standard,
        }),
      );
    }

    if (t.powerMetrics != null) {
      children.add(_Subheader(AppLocalizations.of(context).powerMetricsTitle));
      children.add(
        _kvTable(context, {
          'ch1Voltage': t.powerMetrics!.ch1Voltage,
          'ch1Current': t.powerMetrics!.ch1Current,
          'ch2Voltage': t.powerMetrics!.ch2Voltage,
          'ch2Current': t.powerMetrics!.ch2Current,
          'ch3Voltage': t.powerMetrics!.ch3Voltage,
          'ch3Current': t.powerMetrics!.ch3Current,
        }),
      );
    }

    if (t.localStats != null) {
      children.add(_Subheader(AppLocalizations.of(context).localStatsTitle));
      children.add(
        _kvTable(context, {
          'uptimeSeconds': t.localStats!.uptimeSeconds,
          'channelUtilization': t.localStats!.channelUtilization,
          'airUtilTx': t.localStats!.airUtilTx,
          'numPacketsTx': t.localStats!.numPacketsTx,
          'numPacketsRx': t.localStats!.numPacketsRx,
          'numPacketsRxBad': t.localStats!.numPacketsRxBad,
          'numOnlineNodes': t.localStats!.numOnlineNodes,
        }),
      );
    }

    if (t.healthMetrics != null) {
      children.add(_Subheader(AppLocalizations.of(context).healthMetricsTitle));
      children.add(
        _kvTable(context, {
          'heartBpm': t.healthMetrics!.heartBpm,
          'spO2': t.healthMetrics!.spO2,
          'temperature': t.healthMetrics!.temperature,
        }),
      );
    }

    if (t.hostMetrics != null) {
      children.add(_Subheader(AppLocalizations.of(context).hostMetricsTitle));
      children.add(
        _kvTable(context, {
          'uptimeSeconds': t.hostMetrics!.uptimeSeconds,
          'freememBytes': t.hostMetrics!.freememBytes,
          'diskfree1Bytes': t.hostMetrics!.diskfree1Bytes,
          'diskfree2Bytes': t.hostMetrics!.diskfree2Bytes,
          'diskfree3Bytes': t.hostMetrics!.diskfree3Bytes,
          'load1': t.hostMetrics!.load1,
          'load5': t.hostMetrics!.load5,
          'load15': t.hostMetrics!.load15,
          'userString': t.hostMetrics!.userString,
        }),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _kvTable(BuildContext context, Map<String, Object?> data) {
    final entries = data.entries.where((e) => e.value != null).toList();
    if (entries.isEmpty) return Text(AppLocalizations.of(context).emptyState);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      e.key,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.value.toString())),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // --- Structured renderers for nested DTOs ---

  Widget _configDetails(BuildContext context, ConfigDto cfg) {
    final children = <Widget>[];
    if (cfg.device != null) {
      final d = cfg.device!;
      children.add(_Subheader(AppLocalizations.of(context).device));
      children.add(
        _kvTable(context, {
          'role': d.role,
          'serialEnabled': d.serialEnabled,
          'buttonGpio': d.buttonGpio,
          'buzzerGpio': d.buzzerGpio,
          'rebroadcastMode': d.rebroadcastMode,
          'nodeInfoBroadcastSecs': d.nodeInfoBroadcastSecs,
          'doubleTapAsButtonPress': d.doubleTapAsButtonPress,
          'isManaged': d.isManaged,
          'disableTripleClick': d.disableTripleClick,
          'tzdef': d.tzdef,
          'ledHeartbeatDisabled': d.ledHeartbeatDisabled,
          'buzzerMode': d.buzzerMode,
        }),
      );
    }
    if (cfg.position != null) {
      final p = cfg.position!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).position));
      children.add(
        _kvTable(context, {
          'positionBroadcastSecs': p.positionBroadcastSecs,
          'positionBroadcastSmartEnabled': p.positionBroadcastSmartEnabled,
          'fixedPosition': p.fixedPosition,
          'gpsEnabled': p.gpsEnabled,
          'gpsUpdateInterval': p.gpsUpdateInterval,
          'gpsAttemptTime': p.gpsAttemptTime,
          'positionFlags': p.positionFlags,
          'rxGpio': p.rxGpio,
          'txGpio': p.txGpio,
          'broadcastSmartMinimumDistance': p.broadcastSmartMinimumDistance,
          'broadcastSmartMinimumIntervalSecs':
              p.broadcastSmartMinimumIntervalSecs,
          'gpsEnGpio': p.gpsEnGpio,
          'gpsMode': p.gpsMode,
        }),
      );
    }
    if (cfg.power != null) {
      final p = cfg.power!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).power));
      children.add(
        _kvTable(context, {
          'isPowerSaving': p.isPowerSaving,
          'onBatteryShutdownAfterSecs': p.onBatteryShutdownAfterSecs,
          'adcMultiplierOverride': p.adcMultiplierOverride,
          'waitBluetoothSecs': p.waitBluetoothSecs,
          'sdsSecs': p.sdsSecs,
          'lsSecs': p.lsSecs,
          'minWakeSecs': p.minWakeSecs,
          'deviceBatteryInaAddress': p.deviceBatteryInaAddress,
          'powermonEnables': p.powermonEnables,
        }),
      );
    }
    if (cfg.network != null) {
      final n = cfg.network!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).network));
      children.add(
        _kvTable(context, {
          'wifiEnabled': n.wifiEnabled,
          'wifiSsid': n.wifiSsid,
          'wifiPsk': n.wifiPsk != null ? '••••' : null,
          'ntpServer': n.ntpServer,
          'ethEnabled': n.ethEnabled,
          'addressMode': n.addressMode,
          'rsyslogServer': n.rsyslogServer,
          'enabledProtocols': n.enabledProtocols,
          'ipv6Enabled': n.ipv6Enabled,
        }),
      );
      if (n.ipv4Config != null) {
        final i = n.ipv4Config!;
        children.add(
          _Indent(
            child: _kvTable(context, {
              'ip': i.ip,
              'gateway': i.gateway,
              'subnet': i.subnet,
              'dns': i.dns,
            }),
          ),
        );
      }
    }
    if (cfg.display != null) {
      final d = cfg.display!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).display));
      children.add(
        _kvTable(context, {
          'screenOnSecs': d.screenOnSecs,
          'autoScreenCarouselSecs': d.autoScreenCarouselSecs,
          'compassNorthTop': d.compassNorthTop,
          'flipScreen': d.flipScreen,
          'units': d.units,
          'oled': d.oled,
          'displaymode': d.displaymode,
          'headingBold': d.headingBold,
          'wakeOnTapOrMotion': d.wakeOnTapOrMotion,
          'compassOrientation': d.compassOrientation,
          'use12hClock': d.use12hClock,
          'useLongNodeName': d.useLongNodeName,
        }),
      );
    }
    if (cfg.lora != null) {
      final l = cfg.lora!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).lora));
      children.add(
        _kvTable(context, {
          'usePreset': l.usePreset,
          'modemPreset': l.modemPreset,
          'bandwidth': l.bandwidth,
          'spreadFactor': l.spreadFactor,
          'codingRate': l.codingRate,
          'frequencyOffset': l.frequencyOffset,
          'region': l.region,
          'hopLimit': l.hopLimit,
          'txEnabled': l.txEnabled,
          'txPower': l.txPower,
          'channelNum': l.channelNum,
          'overrideDutyCycle': l.overrideDutyCycle,
          'sx126xRxBoostedGain': l.sx126xRxBoostedGain,
          'overrideFrequency': l.overrideFrequency,
          'paFanDisabled': l.paFanDisabled,
          'ignoreIncoming': l.ignoreIncoming?.join(', '),
          'ignoreMqtt': l.ignoreMqtt,
          'configOkToMqtt': l.configOkToMqtt,
        }),
      );
    }
    if (cfg.bluetooth != null) {
      final b = cfg.bluetooth!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).bluetooth));
      children.add(
        _kvTable(context, {
          'enabled': b.enabled,
          'mode': b.mode,
          'fixedPin': b.fixedPin,
        }),
      );
    }
    if (cfg.security != null) {
      final s = cfg.security!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).security));
      children.add(
        _kvTable(context, {
          'publicKey': s.publicKey?.length,
          'privateKey': s.privateKey != null ? '••••' : null,
          'adminKeyCount': s.adminKey?.length,
          'isManaged': s.isManaged,
          'serialEnabled': s.serialEnabled,
          'debugLogApiEnabled': s.debugLogApiEnabled,
          'adminChannelEnabled': s.adminChannelEnabled,
        }),
      );
    }
    if (cfg.sessionkey != null) {
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).sessionKey));
      children.add(Text(AppLocalizations.of(context).sessionKeyRequested));
    }
    if (children.isEmpty) return Text(AppLocalizations.of(context).emptyState);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _moduleConfigDetails(BuildContext context, ModuleConfigDto m) {
    final children = <Widget>[];
    if (m.mqtt != null) {
      final x = m.mqtt!;
      children.add(
        _Subheader(AppLocalizations.of(context).mqttProxy),
      ); // Reuse mqttProxy key or add mqtt
      children.add(
        _kvTable(context, {
          'enabled': x.enabled,
          'address': x.address,
          'username': x.username,
          'password': x.password != null ? '••••' : null,
          'encryptionEnabled': x.encryptionEnabled,
          'jsonEnabled': x.jsonEnabled,
          'tlsEnabled': x.tlsEnabled,
          'root': x.root,
          'proxyToClientEnabled': x.proxyToClientEnabled,
          'mapReportingEnabled': x.mapReportingEnabled,
        }),
      );
      if (x.mapReportSettings != null) {
        final s = x.mapReportSettings!;
        children.add(
          _Indent(
            child: _kvTable(context, {
              'publishIntervalSecs': s.publishIntervalSecs,
              'positionPrecision': s.positionPrecision,
              'shouldReportLocation': s.shouldReportLocation,
            }),
          ),
        );
      }
    }
    if (m.telemetry != null) {
      final x = m.telemetry!;
      children.add(_Subheader(AppLocalizations.of(context).telemetry));
      children.add(
        _kvTable(context, {
          'deviceUpdateInterval': x.deviceUpdateInterval,
          'environmentUpdateInterval': x.environmentUpdateInterval,
          'environmentMeasurementEnabled': x.environmentMeasurementEnabled,
          'environmentScreenEnabled': x.environmentScreenEnabled,
          'environmentDisplayFahrenheit': x.environmentDisplayFahrenheit,
          'airQualityEnabled': x.airQualityEnabled,
          'airQualityInterval': x.airQualityInterval,
          'powerMeasurementEnabled': x.powerMeasurementEnabled,
          'powerUpdateInterval': x.powerUpdateInterval,
          'powerScreenEnabled': x.powerScreenEnabled,
          'healthMeasurementEnabled': x.healthMeasurementEnabled,
          'healthUpdateInterval': x.healthUpdateInterval,
          'healthScreenEnabled': x.healthScreenEnabled,
          'deviceTelemetryEnabled': x.deviceTelemetryEnabled,
        }),
      );
    }
    if (m.serial != null) {
      final x = m.serial!;
      children.add(_Subheader(AppLocalizations.of(context).serial));
      children.add(
        _kvTable(context, {
          'enabled': x.enabled,
          'echo': x.echo,
          'rxd': x.rxd,
          'txd': x.txd,
          'baud': x.baud,
          'timeout': x.timeout,
          'mode': x.mode,
          'overrideConsoleSerialPort': x.overrideConsoleSerialPort,
        }),
      );
    }
    if (m.storeForward != null) {
      final x = m.storeForward!;
      children.add(_Subheader(AppLocalizations.of(context).storeForward));
      children.add(
        _kvTable(context, {
          'enabled': x.enabled,
          'heartbeat': x.heartbeat,
          'records': x.records,
          'historyReturnMax': x.historyReturnMax,
          'historyReturnWindow': x.historyReturnWindow,
          'isServer': x.isServer,
          'emitControlSignals': x.emitControlSignals,
        }),
      );
    }
    if (m.rangeTest != null) {
      final x = m.rangeTest!;
      children.add(_Subheader(AppLocalizations.of(context).rangeTest));
      children.add(
        _kvTable(context, {
          'enabled': x.enabled,
          'sender': x.sender,
          'save': x.save,
          'clearOnReboot': x.clearOnReboot,
        }),
      );
    }
    if (m.externalNotification != null) {
      final x = m.externalNotification!;
      children.add(
        _Subheader(AppLocalizations.of(context).externalNotification),
      );
      children.add(
        _kvTable(context, {
          'enabled': x.enabled,
          'outputMs': x.outputMs,
          'output': x.output,
          'active': x.active,
          'alertMessage': x.alertMessage,
          'alertBell': x.alertBell,
          'usePwm': x.usePwm,
          'outputVibra': x.outputVibra,
          'outputBuzzer': x.outputBuzzer,
          'alertMessageVibra': x.alertMessageVibra,
          'alertMessageBuzzer': x.alertMessageBuzzer,
          'alertBellVibra': x.alertBellVibra,
          'alertBellBuzzer': x.alertBellBuzzer,
          'nagTimeout': x.nagTimeout,
          'useI2sAsBuzzer': x.useI2sAsBuzzer,
        }),
      );
    }
    if (m.audio != null) {
      final x = m.audio!;
      children.add(_Subheader(AppLocalizations.of(context).audio));
      children.add(
        _kvTable(context, {
          'codec2Enabled': x.codec2Enabled,
          'pttPin': x.pttPin,
          'bitrate': x.bitrate,
          'i2sWs': x.i2sWs,
          'i2sSd': x.i2sSd,
          'i2sDin': x.i2sDin,
          'i2sSck': x.i2sSck,
        }),
      );
    }
    if (m.neighborInfo != null) {
      final x = m.neighborInfo!;
      children.add(_Subheader(AppLocalizations.of(context).neighborInfo));
      children.add(
        _kvTable(context, {
          'enabled': x.enabled,
          'updateInterval': x.updateInterval,
          'transmitOverLora': x.transmitOverLora,
        }),
      );
    }
    if (m.remoteHardware != null) {
      final x = m.remoteHardware!;
      children.add(_Subheader(AppLocalizations.of(context).remoteHardware));
      children.add(
        _kvTable(context, {
          'enabled': x.enabled,
          'allowUndefinedPinAccess': x.allowUndefinedPinAccess,
          'availablePinsCount': x.availablePins?.length,
        }),
      );
      if (x.availablePins != null && x.availablePins!.isNotEmpty) {
        children.add(
          _Indent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: x.availablePins!
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: _kvTable(context, {
                        'gpioPin': p.gpioPin,
                        'name': p.name,
                        'type': p.type,
                      }),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      }
    }
    if (m.paxcounter != null) {
      final x = m.paxcounter!;
      children.add(_Subheader(AppLocalizations.of(context).paxcounter));
      children.add(
        _kvTable(context, {
          'enabled': x.enabled,
          'paxcounterUpdateInterval': x.paxcounterUpdateInterval,
          'wifiThreshold': x.wifiThreshold,
          'bleThreshold': x.bleThreshold,
        }),
      );
    }
    if (m.cannedMessage != null) {
      final x = m.cannedMessage!;
      children.add(_Subheader(AppLocalizations.of(context).cannedMessage));
      children.add(
        _kvTable(context, {
          'rotary1Enabled': x.rotary1Enabled,
          'inputbrokerPinA': x.inputbrokerPinA,
          'inputbrokerPinB': x.inputbrokerPinB,
          'inputbrokerPinPress': x.inputbrokerPinPress,
          'inputbrokerEventCw': x.inputbrokerEventCw,
          'inputbrokerEventCcw': x.inputbrokerEventCcw,
          'inputbrokerEventPress': x.inputbrokerEventPress,
          'updown1Enabled': x.updown1Enabled,
          'enabled(deprecated)': x.enabled,
          'allowInputSource': x.allowInputSource,
          'sendBell': x.sendBell,
        }),
      );
    }
    if (m.ambientLighting != null) {
      final x = m.ambientLighting!;
      children.add(_Subheader(AppLocalizations.of(context).ambientLighting));
      children.add(
        _kvTable(context, {
          'ledState': x.ledState,
          'current': x.current,
          'red': x.red,
          'green': x.green,
          'blue': x.blue,
        }),
      );
    }
    if (m.detectionSensor != null) {
      final x = m.detectionSensor!;
      children.add(_Subheader(AppLocalizations.of(context).detectionSensor));
      children.add(
        _kvTable(context, {
          'enabled': x.enabled,
          'minimumBroadcastSecs': x.minimumBroadcastSecs,
          'stateBroadcastSecs': x.stateBroadcastSecs,
          'sendBell': x.sendBell,
          'name': x.name,
          'monitorPin': x.monitorPin,
          'detectionTriggerType': x.detectionTriggerType,
          'usePullup': x.usePullup,
        }),
      );
    }
    if (m.dtnOverlay != null) {
      final x = m.dtnOverlay!;
      children.add(_Subheader(AppLocalizations.of(context).dtnOverlay));
      children.add(
        _kvTable(context, {
          'enabled': x.enabled,
          'ttlMinutes': x.ttlMinutes,
          'initialDelayBaseMs': x.initialDelayBaseMs,
          'retryBackoffMs': x.retryBackoffMs,
          'maxTries': x.maxTries,
          'lateFallbackEnabled': x.lateFallbackEnabled,
          'fallbackTailPercent': x.fallbackTailPercent,
          'milestonesEnabled': x.milestonesEnabled,
          'perDestMinSpacingMs': x.perDestMinSpacingMs,
          'maxActiveDm': x.maxActiveDm,
          'probeFwplusNearDeadline': x.probeFwplusNearDeadline,
        }),
      );
    }
    if (m.broadcastAssist != null) {
      final x = m.broadcastAssist!;
      children.add(_Subheader(AppLocalizations.of(context).broadcastAssist));
      children.add(
        _kvTable(context, {
          'enabled': x.enabled,
          'degreeThreshold': x.degreeThreshold,
          'dupThreshold': x.dupThreshold,
          'windowMs': x.windowMs,
          'maxExtraHops': x.maxExtraHops,
          'jitterMs': x.jitterMs,
          'airtimeGuard': x.airtimeGuard,
          'allowedPorts': x.allowedPorts?.join(', '),
        }),
      );
    }
    if (m.nodeMod != null) {
      final x = m.nodeMod!;
      children.add(_Subheader(AppLocalizations.of(context).nodeMod));
      children.add(
        _kvTable(context, {'textStatus': x.textStatus, 'emoji': x.emoji}),
      );
    }
    if (m.nodeModAdmin != null) {
      final x = m.nodeModAdmin!;
      children.add(_Subheader(AppLocalizations.of(context).nodeModAdmin));
      children.add(
        _kvTable(context, {
          'snifferEnabled': x.snifferEnabled,
          'doNotSendPrvOverMqtt': x.doNotSendPrvOverMqtt,
          'localStatsOverMeshEnabled': x.localStatsOverMeshEnabled,
          'localStatsExtendedOverMeshEnabled':
              x.localStatsExtendedOverMeshEnabled,
          'idlegameEnabled': x.idlegameEnabled,
          'additionalChutil': x.additionalChutil,
          'additionalTxutil': x.additionalTxutil,
          'additionalPoliteChannelPercent': x.additionalPoliteChannelPercent,
          'additionalPoliteDutyCyclePercent':
              x.additionalPoliteDutyCyclePercent,
          'currentTxUtilLimit': x.currentTxUtilLimit,
          'currentMaxChannelUtilPercent': x.currentMaxChannelUtilPercent,
          'currentPoliteChannelUtilPercent': x.currentPoliteChannelUtilPercent,
          'currentPoliteDutyCyclePercent': x.currentPoliteDutyCyclePercent,
          'autoResponderEnabled': x.autoResponderEnabled,
          'autoResponderText': x.autoResponderText,
          'autoRedirectMessages': x.autoRedirectMessages,
          'autoRedirectTargetNodeId': x.autoRedirectTargetNodeId,
          'telemetryLimiterEnabled': x.telemetryLimiterEnabled,
          'telemetryLimiterPacketsPerMinute':
              x.telemetryLimiterPacketsPerMinute,
          'telemetryLimiterAutoChanutilEnabled':
              x.telemetryLimiterAutoChanutilEnabled,
          'telemetryLimiterAutoChanutilThreshold':
              x.telemetryLimiterAutoChanutilThreshold,
          'positionLimiterEnabled': x.positionLimiterEnabled,
          'positionLimiterTimeMinutesThreshold':
              x.positionLimiterTimeMinutesThreshold,
          'opportunisticFloodingEnabled': x.opportunisticFloodingEnabled,
          'opportunisticBaseDelayMs': x.opportunisticBaseDelayMs,
          'opportunisticHopDelayMs': x.opportunisticHopDelayMs,
          'opportunisticSnrGainMs': x.opportunisticSnrGainMs,
          'opportunisticJitterMs': x.opportunisticJitterMs,
          'opportunisticCancelOnFirstHear': x.opportunisticCancelOnFirstHear,
          'opportunisticAuto': x.opportunisticAuto,
        }),
      );
    }
    if (m.idleGame != null) {
      final x = m.idleGame!;
      children.add(_Subheader(AppLocalizations.of(context).idleGame));
      children.add(_kvTable(context, {'variant': x.variant}));
    }
    if (children.isEmpty) return Text(AppLocalizations.of(context).emptyState);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _deviceUiConfigDetails(BuildContext context, DeviceUiConfigDto u) {
    final children = <Widget>[];
    children.add(
      _kvTable(context, {
        'version': u.version,
        'screenBrightness': u.screenBrightness,
        'screenTimeout': u.screenTimeout,
        'screenLock': u.screenLock,
        'settingsLock': u.settingsLock,
        'pinCode': u.pinCode,
        'theme': u.theme,
        'alertEnabled': u.alertEnabled,
        'bannerEnabled': u.bannerEnabled,
        'ringToneId': u.ringToneId,
        'language': u.language,
        'compassMode': u.compassMode,
        'screenRgbColor': u.screenRgbColor,
        'isClockfaceAnalog': u.isClockfaceAnalog,
        'gpsFormat': u.gpsFormat,
        'calibrationDataLen': u.calibrationData?.length,
      }),
    );
    if (u.nodeFilter != null) {
      final f = u.nodeFilter!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).nodeFilter));
      children.add(
        _kvTable(context, {
          'filterEnabled': f.filterEnabled,
          'minSnr': f.minSnr,
          'hideIgnoredNodes': f.hideIgnoredNodes,
        }),
      );
    }
    if (u.nodeHighlight != null) {
      final h = u.nodeHighlight!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).nodeHighlight));
      children.add(
        _kvTable(context, {
          'highlightEnabled': h.highlightEnabled,
          'minSnr': h.minSnr,
        }),
      );
    }
    if (u.mapData != null) {
      final m = u.mapData!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).map));
      children.add(
        _kvTable(context, {
          'zoom': m.zoom,
          'centerLatI': m.centerLatI,
          'centerLonI': m.centerLonI,
          'followMe': m.followMe,
        }),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _channelSettingsDetails(BuildContext context, ChannelSettingsDto s) {
    final children = <Widget>[];
    children.add(
      _kvTable(context, {
        'name': s.name,
        'psk': s.psk != null && s.psk!.isNotEmpty ? '****' : null,
        'id': s.id,
        'uplinkEnabled': s.uplinkEnabled,
        'downlinkEnabled': s.downlinkEnabled,
        'channelNum': s.channelNum,
      }),
    );

    if (s.moduleSettings != null) {
      children.add(
        _Indent(
          child: _kvTable(context, {
            'positionPrecision': s.moduleSettings!.positionPrecision,
          }),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

bool _hasValidCoords(int? latI, int? lonI) {
  final lat = latFromI(latI);
  final lon = lonFromI(lonI);
  if (lat == null || lon == null) return false;
  return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
}

class _Subheader extends StatelessWidget {
  final String text;
  const _Subheader(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}

class _Indent extends StatelessWidget {
  final Widget child;
  const _Indent({required this.child});
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(left: 12.0), child: child);
}
