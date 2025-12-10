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
            AppLocalizations.of(context).myNodeNum: e.myInfo.myNodeNum,
            AppLocalizations.of(context).rebootCount: e.myInfo.rebootCount,
            AppLocalizations.of(context).minAppVersion: e.myInfo.minAppVersion,
            AppLocalizations.of(context).firmwareEdition:
                e.myInfo.firmwareEdition,
            AppLocalizations.of(context).nodedbCount: e.myInfo.nodedbCount,
            AppLocalizations.of(context).pioEnv: e.myInfo.pioEnv,
            AppLocalizations.of(context).deviceId: e.myInfo.deviceId?.length,
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
                AppLocalizations.of(context).nodeNum: e.nodeInfo.num,
                AppLocalizations.of(context).userLongName:
                    e.nodeInfo.user?.longName,
                AppLocalizations.of(context).userShortName:
                    e.nodeInfo.user?.shortName,
                AppLocalizations.of(context).positionLat:
                    e.nodeInfo.position?.latitudeI,
                AppLocalizations.of(context).positionLon:
                    e.nodeInfo.position?.longitudeI,
                AppLocalizations.of(context).snr: e.nodeInfo.snr,
                AppLocalizations.of(context).lastHeard: e.nodeInfo.lastHeard,
                AppLocalizations.of(context).channel: e.nodeInfo.channel,
                AppLocalizations.of(context).viaMqtt: e.nodeInfo.viaMqtt,
                AppLocalizations.of(context).hopsAway: e.nodeInfo.hopsAway,
                AppLocalizations.of(context).isFavorite: e.nodeInfo.isFavorite,
                AppLocalizations.of(context).isIgnored: e.nodeInfo.isIgnored,
                AppLocalizations.of(context).isKeyManuallyVerified:
                    e.nodeInfo.isKeyManuallyVerified,
                AppLocalizations.of(context).battery:
                    e.nodeInfo.deviceMetrics?.batteryLevel,
                AppLocalizations.of(context).volt:
                    e.nodeInfo.deviceMetrics?.voltage,
                AppLocalizations.of(context).chUtil:
                    e.nodeInfo.deviceMetrics?.channelUtilization,
                AppLocalizations.of(context).airUtil:
                    e.nodeInfo.deviceMetrics?.airUtilTx,
                AppLocalizations.of(context).uptime:
                    e.nodeInfo.deviceMetrics?.uptimeSeconds,
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
                AppLocalizations.of(
                  context,
                ).channelIndexLabel(e.channel.index.toString()): null,
                AppLocalizations.of(context).role: e.channel.role,
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
            AppLocalizations.of(context).res: e.status.res,
            AppLocalizations.of(context).size: e.status.free,
            AppLocalizations.of(context).maxlen: e.status.maxlen,
            AppLocalizations.of(context).meshPacketId: e.status.meshPacketId,
          }),
        );
      case DeviceMetadataEvent e:
        return _Section(
          emoji: '🧰',
          title: AppLocalizations.of(context).deviceMetadata,
          child: _kvTable(context, {
            AppLocalizations.of(context).firmware: e.metadata.firmwareVersion,
            AppLocalizations.of(context).hardware: e.metadata.hwModel,
            AppLocalizations.of(context).role: e.metadata.role,
            AppLocalizations.of(context).wifi: e.metadata.hasWifi,
            AppLocalizations.of(context).bluetooth: e.metadata.hasBluetooth,
            AppLocalizations.of(context).ethernet: e.metadata.hasEthernet,
            AppLocalizations.of(context).stateVersion:
                e.metadata.deviceStateVersion,
            AppLocalizations.of(context).canShutdown: e.metadata.canShutdown,
            AppLocalizations.of(context).positionFlags:
                e.metadata.positionFlags,
            AppLocalizations.of(context).hasRemoteHw:
                e.metadata.hasRemoteHardware,
            AppLocalizations.of(context).hasPKC: e.metadata.hasPKC,
            AppLocalizations.of(context).excluded: e.metadata.excludedModules,
            AppLocalizations.of(context).hasFwPlus: e.metadata.hasFwPlus,
            AppLocalizations.of(context).hasNodemod: e.metadata.hasNodemod,
          }),
        );
      case MqttClientProxyEvent e:
        return _Section(
          emoji: '☁️',
          title: AppLocalizations.of(context).mqttProxy,
          child: _kvTable(context, {
            AppLocalizations.of(context).topic: e.message.topic,
            AppLocalizations.of(context).retained: e.message.retained,
            AppLocalizations.of(context).text: e.message.text,
            AppLocalizations.of(context).dataLength: e.message.data?.length,
          }),
        );
      case FileInfoEvent e:
        return _Section(
          emoji: '📁',
          title: AppLocalizations.of(context).fileInfo,
          child: _kvTable(context, {
            AppLocalizations.of(context).fileName: e.fileInfo.fileName,
            AppLocalizations.of(context).sizeBytes: e.fileInfo.sizeBytes,
          }),
        );
      case ClientNotificationEvent e:
        return _Section(
          emoji: '🔔',
          title: AppLocalizations.of(context).clientNotification,
          child: _kvTable(context, {
            AppLocalizations.of(context).message: e.notification.message,
            AppLocalizations.of(context).replyId: e.notification.replyId,
            AppLocalizations.of(context).time: e.notification.time,
            AppLocalizations.of(context).level: e.notification.level,
            AppLocalizations.of(context).payloadVariant:
                e.notification.payloadVariant,
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
            AppLocalizations.of(context).source: e.logRecord.source,
            AppLocalizations.of(context).message: e.logRecord.message,
          }),
        );
      case XModemEvent e:
        return _Section(
          emoji: '💾',
          title: AppLocalizations.of(context).xmodemTitle,
          child: _kvTable(context, {
            AppLocalizations.of(context).control: e.xmodem.control,
            AppLocalizations.of(context).seq: e.xmodem.seq,
            AppLocalizations.of(context).crc16: e.xmodem.crc16,
            AppLocalizations.of(context).buffer: e.xmodem.buffer?.length,
          }),
        );
      case MeshCoreCommandResponseEvent e:
        return _Section(
          emoji: '📟',
          title: 'MeshCore Command Response',
          child: _kvTable(context, {
            'Response Code':
                '0x${e.responseCode.toRadixString(16).padLeft(2, '0')}',
            'Description': e.responseDescription,
            'Additional Data': e.additionalData
                ?.map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join(' '),
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
        AppLocalizations.of(context).from: p.from,
        AppLocalizations.of(context).to: p.to,
        AppLocalizations.of(context).idTitle: p.id,
        AppLocalizations.of(context).channel: p.channel,
        AppLocalizations.of(context).rxTime: p.rxTime,
        AppLocalizations.of(context).rxRssi: p.rxRssi,
        AppLocalizations.of(context).rxSnr: p.rxSnr,
        AppLocalizations.of(context).hopLimit: p.hopLimit,
        AppLocalizations.of(context).wantAck: p.wantAck,
        AppLocalizations.of(context).priority: p.priority,
        AppLocalizations.of(context).viaMqtt: p.viaMqtt,
        AppLocalizations.of(context).transport: p.transportMechanism,
        AppLocalizations.of(context).hopStart: p.hopStart,
        AppLocalizations.of(context).encrypted: p.encrypted?.length,
        AppLocalizations.of(context).publicKey: p.publicKey?.length,
        AppLocalizations.of(context).pkiEncrypted: p.pkiEncrypted,
        AppLocalizations.of(context).nextHop: p.nextHop,
        AppLocalizations.of(context).relayNode: p.relayNode,
        AppLocalizations.of(context).txAfter: p.txAfter,
      }),
    );

    final decoded = e.decoded;
    if (decoded == null) return header;

    final decodedSection = switch (decoded) {
      TextPayloadDto t => _Section(
        emoji: '💬',
        title: AppLocalizations.of(context).textPayload,
        child: _kvTable(context, {
          AppLocalizations.of(context).text: t.text,
          AppLocalizations.of(context).emoji: t.emoji,
        }),
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
              AppLocalizations.of(context).latI: pos.latitudeI,
              AppLocalizations.of(context).lonI: pos.longitudeI,
              AppLocalizations.of(context).altitude: pos.position.altitude,
              AppLocalizations.of(context).time: pos.position.time,
              AppLocalizations.of(context).gpsAccuracy:
                  pos.position.gpsAccuracy,
              AppLocalizations.of(context).sats: pos.position.satsInView,
              AppLocalizations.of(context).locationSource:
                  pos.position.locationSource,
              AppLocalizations.of(context).altitudeSource:
                  pos.position.altitudeSource,
              AppLocalizations.of(context).timestamp: pos.position.timestamp,
              AppLocalizations.of(context).tsMillisAdj:
                  pos.position.timestampMillisAdjust,
              AppLocalizations.of(context).altHae: pos.position.altitudeHae,
              AppLocalizations.of(context).altGeoSep:
                  pos.position.altitudeGeoidalSeparation,
              AppLocalizations.of(context).pDOP: pos.position.pDOP,
              AppLocalizations.of(context).hDOP: pos.position.hDOP,
              AppLocalizations.of(context).vDOP: pos.position.vDOP,
              AppLocalizations.of(context).groundSpeed:
                  pos.position.groundSpeed,
              AppLocalizations.of(context).groundTrack:
                  pos.position.groundTrack,
              AppLocalizations.of(context).fixQuality: pos.position.fixQuality,
              AppLocalizations.of(context).fixType: pos.position.fixType,
              AppLocalizations.of(context).sensorId: pos.position.sensorId,
              AppLocalizations.of(context).nextUpdate: pos.position.nextUpdate,
              AppLocalizations.of(context).seqNumber: pos.position.seqNumber,
              AppLocalizations.of(context).precisionBits:
                  pos.position.precisionBits,
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
              AppLocalizations.of(context).name: w.waypoint.name,
              AppLocalizations.of(context).idTitle: w.waypoint.id,
              AppLocalizations.of(context).latI: w.waypoint.latitudeI,
              AppLocalizations.of(context).lonI: w.waypoint.longitudeI,
              AppLocalizations.of(context).expire: w.waypoint.expire,
              AppLocalizations.of(context).lockedTo: w.waypoint.lockedTo,
              AppLocalizations.of(context).description: w.waypoint.description,
              AppLocalizations.of(context).icon: w.waypoint.icon,
            }),
          ),
        ],
      ),
      UserPayloadDto u => _Section(
        emoji: '🪪',
        title: AppLocalizations.of(context).user,
        child: _kvTable(context, {
          AppLocalizations.of(context).idTitle: u.user.id,
          AppLocalizations.of(context).userLongName: u.user.longName,
          AppLocalizations.of(context).userShortName: u.user.shortName,
          AppLocalizations.of(context).mac: u.user.macaddr?.length,
          AppLocalizations.of(context).hardware: u.user.hwModel,
          AppLocalizations.of(context).isLicensed: u.user.isLicensed,
          AppLocalizations.of(context).role: u.user.role,
          AppLocalizations.of(context).publicKey: u.user.publicKey?.length,
          AppLocalizations.of(context).isUnmessagable: u.user.isUnmessagable,
        }),
      ),
      RoutingPayloadDto r => _Section(
        emoji: '🧭',
        title: AppLocalizations.of(context).routing,
        child: _kvTable(context, {
          AppLocalizations.of(context).variant: r.variant,
          AppLocalizations.of(context).errorReason: r.errorReason,
          AppLocalizations.of(context).requestId: r.requestId,
        }),
      ),
      AdminPayloadDto a => _Section(
        emoji: '🛠️',
        title: AppLocalizations.of(context).admin,
        child: _kvTable(context, {
          AppLocalizations.of(context).variant: a.variant,
        }),
      ),
      RemoteHardwarePayloadDto rh => _Section(
        emoji: '🔧',
        title: AppLocalizations.of(context).remoteHardware,
        child: _kvTable(context, {
          AppLocalizations.of(context).type: rh.type,
          AppLocalizations.of(context).gpioMask: rh.gpioMask,
          AppLocalizations.of(context).gpioValue: rh.gpioValue,
        }),
      ),
      NeighborInfoPayloadDto ni => _Section(
        emoji: '🕸️',
        title: AppLocalizations.of(context).neighborInfo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kvTable(context, {
              AppLocalizations.of(context).nodeId: ni.nodeId,
              AppLocalizations.of(context).lastSentById: ni.lastSentById,
              AppLocalizations.of(context).nodeBroadcastIntervalSecs:
                  ni.nodeBroadcastIntervalSecs,
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
                          AppLocalizations.of(context).nodeId: n.nodeId,
                          AppLocalizations.of(context).snr: n.snr,
                          AppLocalizations.of(context).lastRxTime: n.lastRxTime,
                          AppLocalizations.of(context).broadcastIntSecs:
                              n.nodeBroadcastIntervalSecs,
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
        child: _kvTable(context, {
          AppLocalizations.of(context).variant: sf.variant,
        }),
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
          AppLocalizations.of(context).wifi: p.wifi,
          AppLocalizations.of(context).btLabel: p.ble,
          AppLocalizations.of(context).uptime: p.uptime,
        }),
      ),
      TraceroutePayloadDto tr => _Section(
        emoji: '🔎',
        title: AppLocalizations.of(context).traceroute,
        child: _kvTable(context, {
          AppLocalizations.of(context).routeLen: tr.route?.length,
          AppLocalizations.of(context).hops: tr.route
              ?.map((e) => e.toString())
              .join(' -> '),
          AppLocalizations.of(context).snrTowards: tr.snrTowards?.join(', '),
          AppLocalizations.of(context).routeBackLen: tr.routeBack?.length,
          AppLocalizations.of(context).snrBack: tr.snrBack?.join(', '),
        }),
      ),
      KeyVerificationPayloadDto kv => _Section(
        emoji: '🔐',
        title: AppLocalizations.of(context).keyVerification,
        child: _kvTable(context, {
          AppLocalizations.of(context).nonce: kv.nonce,
          AppLocalizations.of(context).hash1: kv.hash1?.length,
          AppLocalizations.of(context).hash2: kv.hash2?.length,
        }),
      ),
      RawPayloadDto r => _Section(
        emoji: '📦',
        title: AppLocalizations.of(context).rawPayload,
        child: _kvTable(context, {
          AppLocalizations.of(context).port:
              '${r.portnum.name}:${r.portnum.id}',
          AppLocalizations.of(context).bytes: r.bytes.length,
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
      _kvTable(context, {
        AppLocalizations.of(context).variant: t.variant,
        AppLocalizations.of(context).time: t.time,
      }),
    ];

    if (t.deviceMetrics != null) {
      children.add(_Subheader(AppLocalizations.of(context).deviceMetricsTitle));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).telemetryBattery:
              t.deviceMetrics!.batteryLevel,
          AppLocalizations.of(context).telemetryVoltage:
              t.deviceMetrics!.voltage,
          AppLocalizations.of(context).telemetryChannelUtil:
              t.deviceMetrics!.channelUtilization,
          AppLocalizations.of(context).telemetryAirUtilTx:
              t.deviceMetrics!.airUtilTx,
          AppLocalizations.of(context).uptime: t.deviceMetrics!.uptimeSeconds,
        }),
      );
    }

    if (t.environmentMetrics != null) {
      children.add(
        _Subheader(AppLocalizations.of(context).environmentMetricsTitle),
      );
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).telemetryTemperature:
              t.environmentMetrics!.temperature,
          AppLocalizations.of(context).relativeHumidity:
              t.environmentMetrics!.relativeHumidity,
          AppLocalizations.of(context).barometricPressure:
              t.environmentMetrics!.barometricPressure,
          AppLocalizations.of(context).gasResistance:
              t.environmentMetrics!.gasResistance,
          AppLocalizations.of(context).telemetryVoltage:
              t.environmentMetrics!.voltage,
          AppLocalizations.of(context).current: t.environmentMetrics!.current,
          AppLocalizations.of(context).iaq: t.environmentMetrics!.iaq,
          AppLocalizations.of(context).distance: t.environmentMetrics!.distance,
          AppLocalizations.of(context).lux: t.environmentMetrics!.lux,
          AppLocalizations.of(context).whiteLux: t.environmentMetrics!.whiteLux,
          AppLocalizations.of(context).irLux: t.environmentMetrics!.irLux,
          AppLocalizations.of(context).uvLux: t.environmentMetrics!.uvLux,
          AppLocalizations.of(context).windDirection:
              t.environmentMetrics!.windDirection,
          AppLocalizations.of(context).windSpeed:
              t.environmentMetrics!.windSpeed,
          AppLocalizations.of(context).weight: t.environmentMetrics!.weight,
          AppLocalizations.of(context).windGust: t.environmentMetrics!.windGust,
          AppLocalizations.of(context).windLull: t.environmentMetrics!.windLull,
        }),
      );
    }

    if (t.airQualityMetrics != null) {
      children.add(
        _Subheader(AppLocalizations.of(context).airQualityMetricsTitle),
      );
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).pm10Standard:
              t.airQualityMetrics!.pm10Standard,
          AppLocalizations.of(context).pm25Standard:
              t.airQualityMetrics!.pm25Standard,
          AppLocalizations.of(context).pm100Standard:
              t.airQualityMetrics!.pm100Standard,
          AppLocalizations.of(context).pm10Environmental:
              t.airQualityMetrics!.pm10Environmental,
          AppLocalizations.of(context).pm25Environmental:
              t.airQualityMetrics!.pm25Environmental,
          AppLocalizations.of(context).pm100Environmental:
              t.airQualityMetrics!.pm100Environmental,
          AppLocalizations.of(context).particles03um:
              t.airQualityMetrics!.particles03um,
          AppLocalizations.of(context).particles05um:
              t.airQualityMetrics!.particles05um,
          AppLocalizations.of(context).particles10um:
              t.airQualityMetrics!.particles10um,
          AppLocalizations.of(context).particles25um:
              t.airQualityMetrics!.particles25um,
          AppLocalizations.of(context).particles50um:
              t.airQualityMetrics!.particles50um,
          AppLocalizations.of(context).particles100um:
              t.airQualityMetrics!.particles100um,
          AppLocalizations.of(context).telemetryCo2: t.airQualityMetrics!.co2,
          AppLocalizations.of(context).co2Temperature:
              t.airQualityMetrics!.co2Temperature,
          AppLocalizations.of(context).co2Humidity:
              t.airQualityMetrics!.co2Humidity,
          AppLocalizations.of(context).formaldehyde:
              t.airQualityMetrics!.formFormaldehyde,
          AppLocalizations.of(context).formaldehydeHumidity:
              t.airQualityMetrics!.formHumidity,
          AppLocalizations.of(context).formaldehydeTemperature:
              t.airQualityMetrics!.formTemperature,
          AppLocalizations.of(context).pm40Standard:
              t.airQualityMetrics!.pm40Standard,
        }),
      );
    }

    if (t.powerMetrics != null) {
      children.add(_Subheader(AppLocalizations.of(context).powerMetricsTitle));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).ch1Voltage: t.powerMetrics!.ch1Voltage,
          AppLocalizations.of(context).ch1Current: t.powerMetrics!.ch1Current,
          AppLocalizations.of(context).ch2Voltage: t.powerMetrics!.ch2Voltage,
          AppLocalizations.of(context).ch2Current: t.powerMetrics!.ch2Current,
          AppLocalizations.of(context).ch3Voltage: t.powerMetrics!.ch3Voltage,
          AppLocalizations.of(context).ch3Current: t.powerMetrics!.ch3Current,
        }),
      );
    }

    if (t.localStats != null) {
      children.add(_Subheader(AppLocalizations.of(context).localStatsTitle));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).uptime: t.localStats!.uptimeSeconds,
          AppLocalizations.of(context).telemetryChannelUtil:
              t.localStats!.channelUtilization,
          AppLocalizations.of(context).telemetryAirUtilTx:
              t.localStats!.airUtilTx,
          AppLocalizations.of(context).numPacketsTx: t.localStats!.numPacketsTx,
          AppLocalizations.of(context).numPacketsRx: t.localStats!.numPacketsRx,
          AppLocalizations.of(context).numPacketsRxBad:
              t.localStats!.numPacketsRxBad,
          AppLocalizations.of(context).numOnlineNodes:
              t.localStats!.numOnlineNodes,
        }),
      );
    }

    if (t.healthMetrics != null) {
      children.add(_Subheader(AppLocalizations.of(context).healthMetricsTitle));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).heartBpm: t.healthMetrics!.heartBpm,
          AppLocalizations.of(context).spO2: t.healthMetrics!.spO2,
          AppLocalizations.of(context).telemetryTemperature:
              t.healthMetrics!.temperature,
        }),
      );
    }

    if (t.hostMetrics != null) {
      children.add(_Subheader(AppLocalizations.of(context).hostMetricsTitle));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).uptime: t.hostMetrics!.uptimeSeconds,
          AppLocalizations.of(context).freememBytes:
              t.hostMetrics!.freememBytes,
          AppLocalizations.of(context).diskfree1Bytes:
              t.hostMetrics!.diskfree1Bytes,
          AppLocalizations.of(context).diskfree2Bytes:
              t.hostMetrics!.diskfree2Bytes,
          AppLocalizations.of(context).diskfree3Bytes:
              t.hostMetrics!.diskfree3Bytes,
          AppLocalizations.of(context).load1: t.hostMetrics!.load1,
          AppLocalizations.of(context).load5: t.hostMetrics!.load5,
          AppLocalizations.of(context).load15: t.hostMetrics!.load15,
          AppLocalizations.of(context).userString: t.hostMetrics!.userString,
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
          AppLocalizations.of(context).role: d.role,
          AppLocalizations.of(context).serialEnabled: d.serialEnabled,
          AppLocalizations.of(context).buttonGpio: d.buttonGpio,
          AppLocalizations.of(context).buzzerGpio: d.buzzerGpio,
          AppLocalizations.of(context).rebroadcastMode: d.rebroadcastMode,
          AppLocalizations.of(context).nodeInfoBroadcastSecs:
              d.nodeInfoBroadcastSecs,
          AppLocalizations.of(context).doubleTapAsButtonPress:
              d.doubleTapAsButtonPress,
          AppLocalizations.of(context).isManaged: d.isManaged,
          AppLocalizations.of(context).disableTripleClick: d.disableTripleClick,
          AppLocalizations.of(context).timezone: d.tzdef,
          AppLocalizations.of(context).ledHeartbeatDisabled:
              d.ledHeartbeatDisabled,
          AppLocalizations.of(context).buzzerMode: d.buzzerMode,
        }),
      );
    }
    if (cfg.position != null) {
      final p = cfg.position!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).position));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).positionBroadcastSecs:
              p.positionBroadcastSecs,
          AppLocalizations.of(context).positionBroadcastSmartEnabled:
              p.positionBroadcastSmartEnabled,
          AppLocalizations.of(context).fixedPosition: p.fixedPosition,
          AppLocalizations.of(context).gpsEnabled: p.gpsEnabled,
          AppLocalizations.of(context).gpsUpdateInterval: p.gpsUpdateInterval,
          AppLocalizations.of(context).gpsAttemptTime: p.gpsAttemptTime,
          AppLocalizations.of(context).positionFlags: p.positionFlags,
          AppLocalizations.of(context).rxGpio: p.rxGpio,
          AppLocalizations.of(context).txGpio: p.txGpio,
          AppLocalizations.of(context).broadcastSmartMinimumDistance:
              p.broadcastSmartMinimumDistance,
          AppLocalizations.of(context).broadcastSmartMinimumIntervalSecs:
              p.broadcastSmartMinimumIntervalSecs,
          AppLocalizations.of(context).gpsEnableGpio: p.gpsEnGpio,
          AppLocalizations.of(context).gpsMode: p.gpsMode,
        }),
      );
    }
    if (cfg.power != null) {
      final p = cfg.power!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).power));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).isPowerSaving: p.isPowerSaving,
          AppLocalizations.of(context).onBatteryShutdownAfterSecs:
              p.onBatteryShutdownAfterSecs,
          AppLocalizations.of(context).adcMultiplierOverride:
              p.adcMultiplierOverride,
          AppLocalizations.of(context).waitBluetoothSecs: p.waitBluetoothSecs,
          AppLocalizations.of(context).sdsSecs: p.sdsSecs,
          AppLocalizations.of(context).lsSecs: p.lsSecs,
          AppLocalizations.of(context).minWakeSecs: p.minWakeSecs,
          AppLocalizations.of(context).deviceBatteryInaAddress:
              p.deviceBatteryInaAddress,
          AppLocalizations.of(context).powermonEnables: p.powermonEnables,
        }),
      );
    }
    if (cfg.network != null) {
      final n = cfg.network!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).network));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).wifiEnabled: n.wifiEnabled,
          AppLocalizations.of(context).wifiSsid: n.wifiSsid,
          AppLocalizations.of(context).wifiPsk: n.wifiPsk != null
              ? '••••'
              : null,
          AppLocalizations.of(context).ntpServer: n.ntpServer,
          AppLocalizations.of(context).ethEnabled: n.ethEnabled,
          AppLocalizations.of(context).addressMode: n.addressMode,
          AppLocalizations.of(context).rsyslogServer: n.rsyslogServer,
          AppLocalizations.of(context).enabledProtocols: n.enabledProtocols,
          AppLocalizations.of(context).ipv6Enabled: n.ipv6Enabled,
        }),
      );
      if (n.ipv4Config != null) {
        final i = n.ipv4Config!;
        children.add(
          _Indent(
            child: _kvTable(context, {
              AppLocalizations.of(context).ip: i.ip,
              AppLocalizations.of(context).gateway: i.gateway,
              AppLocalizations.of(context).subnet: i.subnet,
              AppLocalizations.of(context).dns: i.dns,
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
          AppLocalizations.of(context).screenOnSecs: d.screenOnSecs,
          AppLocalizations.of(context).autoScreenCarouselSecs:
              d.autoScreenCarouselSecs,
          AppLocalizations.of(context).compassNorthTop: d.compassNorthTop,
          AppLocalizations.of(context).flipScreen: d.flipScreen,
          AppLocalizations.of(context).units: d.units,
          AppLocalizations.of(context).oled: d.oled,
          AppLocalizations.of(context).displaymode: d.displaymode,
          AppLocalizations.of(context).headingBold: d.headingBold,
          AppLocalizations.of(context).wakeOnTapOrMotion: d.wakeOnTapOrMotion,
          AppLocalizations.of(context).compassOrientation: d.compassOrientation,
          AppLocalizations.of(context).use12hClock: d.use12hClock,
          AppLocalizations.of(context).useLongNodeName: d.useLongNodeName,
        }),
      );
    }
    if (cfg.lora != null) {
      final l = cfg.lora!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).lora));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).usePreset: l.usePreset,
          AppLocalizations.of(context).modemPreset: l.modemPreset,
          AppLocalizations.of(context).bandwidth: l.bandwidth,
          AppLocalizations.of(context).spreadFactor: l.spreadFactor,
          AppLocalizations.of(context).codingRate: l.codingRate,
          AppLocalizations.of(context).frequencyOffset: l.frequencyOffset,
          AppLocalizations.of(context).region: l.region,
          AppLocalizations.of(context).hopLimit: l.hopLimit,
          AppLocalizations.of(context).txEnabled: l.txEnabled,
          AppLocalizations.of(context).txPower: l.txPower,
          AppLocalizations.of(context).channelNum: l.channelNum,
          AppLocalizations.of(context).overrideDutyCycle: l.overrideDutyCycle,
          AppLocalizations.of(context).sx126xRxBoostedGain:
              l.sx126xRxBoostedGain,
          AppLocalizations.of(context).overrideFrequency: l.overrideFrequency,
          AppLocalizations.of(context).paFanDisabled: l.paFanDisabled,
          AppLocalizations.of(context).ignoreIncoming: l.ignoreIncoming?.join(
            ', ',
          ),
          AppLocalizations.of(context).ignoreMqtt: l.ignoreMqtt,
          AppLocalizations.of(context).configOkToMqtt: l.configOkToMqtt,
        }),
      );
    }
    if (cfg.bluetooth != null) {
      final b = cfg.bluetooth!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).bluetooth));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).enabled: b.enabled,
          AppLocalizations.of(context).mode: b.mode,
          AppLocalizations.of(context).fixedPin: b.fixedPin,
        }),
      );
    }
    if (cfg.security != null) {
      final s = cfg.security!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).security));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).publicKey: s.publicKey?.length,
          AppLocalizations.of(context).privateKey: s.privateKey != null
              ? '••••'
              : null,
          AppLocalizations.of(context).adminKeyCount: s.adminKey?.length,
          AppLocalizations.of(context).isManaged: s.isManaged,
          AppLocalizations.of(context).serialEnabled: s.serialEnabled,
          AppLocalizations.of(context).debugLogApiEnabled: s.debugLogApiEnabled,
          AppLocalizations.of(context).adminChannelEnabled:
              s.adminChannelEnabled,
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
          AppLocalizations.of(context).enabled: x.enabled,
          AppLocalizations.of(context).address: x.address,
          AppLocalizations.of(context).username: x.username,
          AppLocalizations.of(context).password: x.password != null
              ? '••••'
              : null,
          AppLocalizations.of(context).encryptionEnabled: x.encryptionEnabled,
          AppLocalizations.of(context).jsonEnabled: x.jsonEnabled,
          AppLocalizations.of(context).tlsEnabled: x.tlsEnabled,
          AppLocalizations.of(context).root: x.root,
          AppLocalizations.of(context).proxyToClientEnabled:
              x.proxyToClientEnabled,
          AppLocalizations.of(context).mapReportingEnabled:
              x.mapReportingEnabled,
        }),
      );
      if (x.mapReportSettings != null) {
        final s = x.mapReportSettings!;
        children.add(
          _Indent(
            child: _kvTable(context, {
              AppLocalizations.of(context).publishIntervalSecs:
                  s.publishIntervalSecs,
              AppLocalizations.of(context).positionPrecision:
                  s.positionPrecision,
              AppLocalizations.of(context).shouldReportLocation:
                  s.shouldReportLocation,
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
          AppLocalizations.of(context).deviceUpdateInterval:
              x.deviceUpdateInterval,
          AppLocalizations.of(context).environmentUpdateInterval:
              x.environmentUpdateInterval,
          AppLocalizations.of(context).environmentMeasurementEnabled:
              x.environmentMeasurementEnabled,
          AppLocalizations.of(context).environmentScreenEnabled:
              x.environmentScreenEnabled,
          AppLocalizations.of(context).environmentDisplayFahrenheit:
              x.environmentDisplayFahrenheit,
          AppLocalizations.of(context).airQualityEnabled: x.airQualityEnabled,
          AppLocalizations.of(context).airQualityInterval: x.airQualityInterval,
          AppLocalizations.of(context).powerMeasurementEnabled:
              x.powerMeasurementEnabled,
          AppLocalizations.of(context).powerUpdateInterval:
              x.powerUpdateInterval,
          AppLocalizations.of(context).powerScreenEnabled: x.powerScreenEnabled,
          AppLocalizations.of(context).healthMeasurementEnabled:
              x.healthMeasurementEnabled,
          AppLocalizations.of(context).healthUpdateInterval:
              x.healthUpdateInterval,
          AppLocalizations.of(context).healthScreenEnabled:
              x.healthScreenEnabled,
          AppLocalizations.of(context).deviceTelemetryEnabled:
              x.deviceTelemetryEnabled,
        }),
      );
    }
    if (m.serial != null) {
      final x = m.serial!;
      children.add(_Subheader(AppLocalizations.of(context).serial));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).enabled: x.enabled,
          AppLocalizations.of(context).echo: x.echo,
          AppLocalizations.of(context).rxd: x.rxd,
          AppLocalizations.of(context).txd: x.txd,
          AppLocalizations.of(context).baud: x.baud,
          AppLocalizations.of(context).timeout: x.timeout,
          AppLocalizations.of(context).mode: x.mode,
          AppLocalizations.of(context).overrideConsoleSerialPort:
              x.overrideConsoleSerialPort,
        }),
      );
    }
    if (m.storeForward != null) {
      final x = m.storeForward!;
      children.add(_Subheader(AppLocalizations.of(context).storeForward));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).enabled: x.enabled,
          AppLocalizations.of(context).heartbeat: x.heartbeat,
          AppLocalizations.of(context).records: x.records,
          AppLocalizations.of(context).historyReturnMax: x.historyReturnMax,
          AppLocalizations.of(context).historyReturnWindow:
              x.historyReturnWindow,
          AppLocalizations.of(context).isServer: x.isServer,
          AppLocalizations.of(context).emitControlSignals: x.emitControlSignals,
        }),
      );
    }
    if (m.rangeTest != null) {
      final x = m.rangeTest!;
      children.add(_Subheader(AppLocalizations.of(context).rangeTest));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).enabled: x.enabled,
          AppLocalizations.of(context).sender: x.sender,
          AppLocalizations.of(context).save: x.save,
          AppLocalizations.of(context).clearOnReboot: x.clearOnReboot,
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
          AppLocalizations.of(context).enabled: x.enabled,
          AppLocalizations.of(context).outputMs: x.outputMs,
          AppLocalizations.of(context).output: x.output,
          AppLocalizations.of(context).active: x.active,
          AppLocalizations.of(context).alertMessage: x.alertMessage,
          AppLocalizations.of(context).alertBell: x.alertBell,
          AppLocalizations.of(context).usePwm: x.usePwm,
          AppLocalizations.of(context).outputVibra: x.outputVibra,
          AppLocalizations.of(context).outputBuzzer: x.outputBuzzer,
          AppLocalizations.of(context).alertMessageVibra: x.alertMessageVibra,
          AppLocalizations.of(context).alertMessageBuzzer: x.alertMessageBuzzer,
          AppLocalizations.of(context).alertBellVibra: x.alertBellVibra,
          AppLocalizations.of(context).alertBellBuzzer: x.alertBellBuzzer,
          AppLocalizations.of(context).nagTimeout: x.nagTimeout,
          AppLocalizations.of(context).useI2sAsBuzzer: x.useI2sAsBuzzer,
        }),
      );
    }
    if (m.audio != null) {
      final x = m.audio!;
      children.add(_Subheader(AppLocalizations.of(context).audio));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).codec2Enabled: x.codec2Enabled,
          AppLocalizations.of(context).pttPin: x.pttPin,
          AppLocalizations.of(context).bitrate: x.bitrate,
          AppLocalizations.of(context).i2sWs: x.i2sWs,
          AppLocalizations.of(context).i2sSd: x.i2sSd,
          AppLocalizations.of(context).i2sDin: x.i2sDin,
          AppLocalizations.of(context).i2sSck: x.i2sSck,
        }),
      );
    }
    if (m.neighborInfo != null) {
      final x = m.neighborInfo!;
      children.add(_Subheader(AppLocalizations.of(context).neighborInfo));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).enabled: x.enabled,
          AppLocalizations.of(context).updateInterval: x.updateInterval,
          AppLocalizations.of(context).transmitOverLora: x.transmitOverLora,
        }),
      );
    }
    if (m.remoteHardware != null) {
      final x = m.remoteHardware!;
      children.add(_Subheader(AppLocalizations.of(context).remoteHardware));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).enabled: x.enabled,
          AppLocalizations.of(context).allowUndefinedPinAccess:
              x.allowUndefinedPinAccess,
          AppLocalizations.of(context).availablePinsCount:
              x.availablePins?.length,
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
                        AppLocalizations.of(context).gpioPin: p.gpioPin,
                        AppLocalizations.of(context).name: p.name,
                        AppLocalizations.of(context).type: p.type,
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
          AppLocalizations.of(context).enabled: x.enabled,
          AppLocalizations.of(context).paxcounterUpdateInterval:
              x.paxcounterUpdateInterval,
          AppLocalizations.of(context).wifiThreshold: x.wifiThreshold,
          AppLocalizations.of(context).bleThreshold: x.bleThreshold,
        }),
      );
    }
    if (m.cannedMessage != null) {
      final x = m.cannedMessage!;
      children.add(_Subheader(AppLocalizations.of(context).cannedMessage));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).rotary1Enabled: x.rotary1Enabled,
          AppLocalizations.of(context).inputbrokerPinA: x.inputbrokerPinA,
          AppLocalizations.of(context).inputbrokerPinB: x.inputbrokerPinB,
          AppLocalizations.of(context).inputbrokerPinPress:
              x.inputbrokerPinPress,
          AppLocalizations.of(context).inputbrokerEventCw: x.inputbrokerEventCw,
          AppLocalizations.of(context).inputbrokerEventCcw:
              x.inputbrokerEventCcw,
          AppLocalizations.of(context).inputbrokerEventPress:
              x.inputbrokerEventPress,
          AppLocalizations.of(context).updown1Enabled: x.updown1Enabled,
          AppLocalizations.of(context).enabledDeprecated: x.enabled,
          AppLocalizations.of(context).allowInputSource: x.allowInputSource,
          AppLocalizations.of(context).sendBell: x.sendBell,
        }),
      );
    }
    if (m.ambientLighting != null) {
      final x = m.ambientLighting!;
      children.add(_Subheader(AppLocalizations.of(context).ambientLighting));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).ledState: x.ledState,
          AppLocalizations.of(context).current: x.current,
          AppLocalizations.of(context).red: x.red,
          AppLocalizations.of(context).green: x.green,
          AppLocalizations.of(context).blue: x.blue,
        }),
      );
    }
    if (m.detectionSensor != null) {
      final x = m.detectionSensor!;
      children.add(_Subheader(AppLocalizations.of(context).detectionSensor));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).enabled: x.enabled,
          AppLocalizations.of(context).minimumBroadcastSecs:
              x.minimumBroadcastSecs,
          AppLocalizations.of(context).stateBroadcastSecs: x.stateBroadcastSecs,
          AppLocalizations.of(context).sendBell: x.sendBell,
          AppLocalizations.of(context).name: x.name,
          AppLocalizations.of(context).monitorPin: x.monitorPin,
          AppLocalizations.of(context).detectionTriggerType:
              x.detectionTriggerType,
          AppLocalizations.of(context).usePullup: x.usePullup,
        }),
      );
    }
    if (m.dtnOverlay != null) {
      final x = m.dtnOverlay!;
      children.add(_Subheader(AppLocalizations.of(context).dtnOverlay));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).enabled: x.enabled,
          AppLocalizations.of(context).ttlMinutes: x.ttlMinutes,
          AppLocalizations.of(context).initialDelayBaseMs: x.initialDelayBaseMs,
          AppLocalizations.of(context).retryBackoffMs: x.retryBackoffMs,
          AppLocalizations.of(context).maxTries: x.maxTries,
          AppLocalizations.of(context).lateFallbackEnabled:
              x.lateFallbackEnabled,
          AppLocalizations.of(context).fallbackTailPercent:
              x.fallbackTailPercent,
          AppLocalizations.of(context).milestonesEnabled: x.milestonesEnabled,
          AppLocalizations.of(context).perDestMinSpacingMs:
              x.perDestMinSpacingMs,
          AppLocalizations.of(context).maxActiveDm: x.maxActiveDm,
          AppLocalizations.of(context).probeFwplusNearDeadline:
              x.probeFwplusNearDeadline,
        }),
      );
    }
    if (m.broadcastAssist != null) {
      final x = m.broadcastAssist!;
      children.add(_Subheader(AppLocalizations.of(context).broadcastAssist));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).enabled: x.enabled,
          AppLocalizations.of(context).degreeThreshold: x.degreeThreshold,
          AppLocalizations.of(context).dupThreshold: x.dupThreshold,
          AppLocalizations.of(context).windowMs: x.windowMs,
          AppLocalizations.of(context).maxExtraHops: x.maxExtraHops,
          AppLocalizations.of(context).jitterMs: x.jitterMs,
          AppLocalizations.of(context).airtimeGuard: x.airtimeGuard,
          AppLocalizations.of(context).allowedPorts: x.allowedPorts?.join(', '),
        }),
      );
    }
    if (m.nodeMod != null) {
      final x = m.nodeMod!;
      children.add(_Subheader(AppLocalizations.of(context).nodeMod));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).textStatus: x.textStatus,
          AppLocalizations.of(context).emoji: x.emoji,
        }),
      );
    }
    if (m.nodeModAdmin != null) {
      final x = m.nodeModAdmin!;
      children.add(_Subheader(AppLocalizations.of(context).nodeModAdmin));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).snifferEnabled: x.snifferEnabled,
          AppLocalizations.of(context).doNotSendPrvOverMqtt:
              x.doNotSendPrvOverMqtt,
          AppLocalizations.of(context).localStatsOverMeshEnabled:
              x.localStatsOverMeshEnabled,
          AppLocalizations.of(context).localStatsExtendedOverMeshEnabled:
              x.localStatsExtendedOverMeshEnabled,
          AppLocalizations.of(context).idlegameEnabled: x.idlegameEnabled,
          AppLocalizations.of(context).additionalChutil: x.additionalChutil,
          AppLocalizations.of(context).additionalTxutil: x.additionalTxutil,
          AppLocalizations.of(context).additionalPoliteChannelPercent:
              x.additionalPoliteChannelPercent,
          AppLocalizations.of(context).additionalPoliteDutyCyclePercent:
              x.additionalPoliteDutyCyclePercent,
          AppLocalizations.of(context).currentTxUtilLimit: x.currentTxUtilLimit,
          AppLocalizations.of(context).currentMaxChannelUtilPercent:
              x.currentMaxChannelUtilPercent,
          AppLocalizations.of(context).currentPoliteChannelUtilPercent:
              x.currentPoliteChannelUtilPercent,
          AppLocalizations.of(context).currentPoliteDutyCyclePercent:
              x.currentPoliteDutyCyclePercent,
          AppLocalizations.of(context).autoResponderEnabled:
              x.autoResponderEnabled,
          AppLocalizations.of(context).autoResponderText: x.autoResponderText,
          AppLocalizations.of(context).autoRedirectMessages:
              x.autoRedirectMessages,
          AppLocalizations.of(context).autoRedirectTargetNodeId:
              x.autoRedirectTargetNodeId,
          AppLocalizations.of(context).telemetryLimiterEnabled:
              x.telemetryLimiterEnabled,
          AppLocalizations.of(context).telemetryLimiterPacketsPerMinute:
              x.telemetryLimiterPacketsPerMinute,
          AppLocalizations.of(context).telemetryLimiterAutoChanutilEnabled:
              x.telemetryLimiterAutoChanutilEnabled,
          AppLocalizations.of(context).telemetryLimiterAutoChanutilThreshold:
              x.telemetryLimiterAutoChanutilThreshold,
          AppLocalizations.of(context).positionLimiterEnabled:
              x.positionLimiterEnabled,
          AppLocalizations.of(context).positionLimiterTimeMinutesThreshold:
              x.positionLimiterTimeMinutesThreshold,
          AppLocalizations.of(context).opportunisticFloodingEnabled:
              x.opportunisticFloodingEnabled,
          AppLocalizations.of(context).opportunisticBaseDelayMs:
              x.opportunisticBaseDelayMs,
          AppLocalizations.of(context).opportunisticHopDelayMs:
              x.opportunisticHopDelayMs,
          AppLocalizations.of(context).opportunisticSnrGainMs:
              x.opportunisticSnrGainMs,
          AppLocalizations.of(context).opportunisticJitterMs:
              x.opportunisticJitterMs,
          AppLocalizations.of(context).opportunisticCancelOnFirstHear:
              x.opportunisticCancelOnFirstHear,
          AppLocalizations.of(context).opportunisticAuto: x.opportunisticAuto,
        }),
      );
    }
    if (m.idleGame != null) {
      final x = m.idleGame!;
      children.add(_Subheader(AppLocalizations.of(context).idleGame));
      children.add(
        _kvTable(context, {AppLocalizations.of(context).variant: x.variant}),
      );
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
        AppLocalizations.of(context).version: u.version,
        AppLocalizations.of(context).screenBrightness: u.screenBrightness,
        AppLocalizations.of(context).screenTimeout: u.screenTimeout,
        AppLocalizations.of(context).screenLock: u.screenLock,
        AppLocalizations.of(context).settingsLock: u.settingsLock,
        AppLocalizations.of(context).pinCode: u.pinCode,
        AppLocalizations.of(context).theme: u.theme,
        AppLocalizations.of(context).alertEnabled: u.alertEnabled,
        AppLocalizations.of(context).bannerEnabled: u.bannerEnabled,
        AppLocalizations.of(context).ringToneId: u.ringToneId,
        AppLocalizations.of(context).language: u.language,
        AppLocalizations.of(context).compassMode: u.compassMode,
        AppLocalizations.of(context).screenRgbColor: u.screenRgbColor,
        AppLocalizations.of(context).isClockfaceAnalog: u.isClockfaceAnalog,
        AppLocalizations.of(context).gpsFormat: u.gpsFormat,
        AppLocalizations.of(context).calibrationDataLen:
            u.calibrationData?.length,
      }),
    );
    if (u.nodeFilter != null) {
      final f = u.nodeFilter!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).nodeFilter));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).filterEnabled: f.filterEnabled,
          AppLocalizations.of(context).minSnr: f.minSnr,
          AppLocalizations.of(context).hideIgnoredNodes: f.hideIgnoredNodes,
        }),
      );
    }
    if (u.nodeHighlight != null) {
      final h = u.nodeHighlight!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).nodeHighlight));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).highlightEnabled: h.highlightEnabled,
          AppLocalizations.of(context).minSnr: h.minSnr,
        }),
      );
    }
    if (u.mapData != null) {
      final m = u.mapData!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader(AppLocalizations.of(context).map));
      children.add(
        _kvTable(context, {
          AppLocalizations.of(context).zoom: m.zoom,
          AppLocalizations.of(context).centerLatI: m.centerLatI,
          AppLocalizations.of(context).centerLonI: m.centerLonI,
          AppLocalizations.of(context).followMe: m.followMe,
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
        AppLocalizations.of(context).name: s.name,
        AppLocalizations.of(context).psk: s.psk != null && s.psk!.isNotEmpty
            ? '****'
            : null,
        AppLocalizations.of(context).idTitle: s.id,
        AppLocalizations.of(context).uplinkEnabled: s.uplinkEnabled,
        AppLocalizations.of(context).downlinkEnabled: s.downlinkEnabled,
        AppLocalizations.of(context).channelNum: s.channelNum,
      }),
    );

    if (s.moduleSettings != null) {
      children.add(
        _Indent(
          child: _kvTable(context, {
            AppLocalizations.of(context).positionPrecision:
                s.moduleSettings!.positionPrecision,
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
