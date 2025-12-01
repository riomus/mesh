import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Event details')),
      body: SingleChildScrollView(
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
                  child: MeshtasticEventTile(
                    event: m.event,
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
            if (payload case MeshtasticDeviceEventPayload m)
              _MeshtasticEventDetails(
                event: m.event,
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasValidCoords(e.nodeInfo.position?.latitudeI, e.nodeInfo.position?.longitudeI))
              MapSection(
                latitude: latFromI(e.nodeInfo.position?.latitudeI)!,
                longitude: lonFromI(e.nodeInfo.position?.longitudeI)!,
                label: e.nodeInfo.user?.shortName ?? e.nodeInfo.user?.longName,
              ),
            _Section(
              emoji: '🪪',
              title: 'NodeInfo',
              child: _kvTable({
                'num': e.nodeInfo.num,
                'user.longName': e.nodeInfo.user?.longName,
                'user.shortName': e.nodeInfo.user?.shortName,
                'position.lat': e.nodeInfo.position?.latitudeI,
                'position.lon': e.nodeInfo.position?.longitudeI,
              }),
            ),
          ],
        );
      case ConfigEvent e:
        return _Section(
          emoji: '⚙️',
          title: 'Config',
          child: _configDetails(e.config),
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
          child: _moduleConfigDetails(e.moduleConfig),
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
          child: _kvTable({
            'topic': e.message.topic,
            'retained': e.message.retained,
            'text': e.message.text,
            'dataLen': e.message.data?.length,
          }),
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
          child: _deviceUiConfigDetails(e.uiConfig),
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
      PositionPayloadDto pos => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasValidCoords(pos.latitudeI, pos.longitudeI))
              MapSection(
                latitude: latFromI(pos.latitudeI)!,
                longitude: lonFromI(pos.longitudeI)!,
                label: 'Position',
              ),
            _Section(
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
              title: 'Waypoint',
              child: _kvTable({
                'name': w.waypoint.name,
                'latI': w.waypoint.latitudeI,
                'lonI': w.waypoint.longitudeI,
                'expire': w.waypoint.expire,
              }),
            ),
          ],
        ),
      UserPayloadDto u => _Section(
          emoji: '🪪',
          title: 'User',
          child: _kvTable({
            'longName': u.user.longName,
            'shortName': u.user.shortName,
          }),
        ),
      RoutingPayloadDto _ => _Section(
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
          child: _kvTable({
            'type': rh.type,
            'gpioMask': rh.gpioMask,
            'gpioValue': rh.gpioValue,
          }),
        ),
      NeighborInfoPayloadDto ni => _Section(
          emoji: '🕸️',
          title: 'Neighbor info',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kvTable({
                'nodeId': ni.nodeId,
                'lastSentById': ni.lastSentById,
                'nodeBroadcastIntervalSecs': ni.nodeBroadcastIntervalSecs,
              }),
              if (ni.neighbors != null && ni.neighbors!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Neighbors', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Column(
                  children: ni.neighbors!
                      .map((n) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: _kvTable({
                              'nodeId': n.nodeId,
                              'snr': n.snr,
                              'lastRxTime': n.lastRxTime,
                              'broadcastIntSecs': n.nodeBroadcastIntervalSecs,
                            }),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      StoreForwardPayloadDto sf => _Section(
          emoji: '🗄️',
          title: 'Store & Forward',
          child: _kvTable({'variant': sf.variant}),
        ),
      TelemetryPayloadDto t => _Section(
          emoji: '📊',
          title: 'Telemetry',
          child: _kvTable({'variant': t.variant}),
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

  // --- Structured renderers for nested DTOs ---

  Widget _configDetails(ConfigDto cfg) {
    final children = <Widget>[];
    if (cfg.device != null) {
      final d = cfg.device!;
      children.add(_Subheader('Device'));
      children.add(_kvTable({
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
      }));
    }
    if (cfg.position != null) {
      final p = cfg.position!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader('Position'));
      children.add(_kvTable({
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
        'broadcastSmartMinimumIntervalSecs': p.broadcastSmartMinimumIntervalSecs,
        'gpsEnGpio': p.gpsEnGpio,
        'gpsMode': p.gpsMode,
      }));
    }
    if (children.isEmpty) return const Text('—');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _moduleConfigDetails(ModuleConfigDto m) {
    final children = <Widget>[];
    if (m.mqtt != null) {
      final x = m.mqtt!;
      children.add(_Subheader('MQTT'));
      children.add(_kvTable({
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
      }));
      if (x.mapReportSettings != null) {
        final s = x.mapReportSettings!;
        children.add(_Indent(child: _kvTable({
          'publishIntervalSecs': s.publishIntervalSecs,
          'positionPrecision': s.positionPrecision,
          'shouldReportLocation': s.shouldReportLocation,
        })));
      }
    }
    if (m.telemetry != null) {
      final x = m.telemetry!;
      children.add(_Subheader('Telemetry'));
      children.add(_kvTable({
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
      }));
    }
    if (m.serial != null) {
      final x = m.serial!;
      children.add(_Subheader('Serial'));
      children.add(_kvTable({
        'enabled': x.enabled,
        'echo': x.echo,
        'rxd': x.rxd,
        'txd': x.txd,
        'baud': x.baud,
        'timeout': x.timeout,
        'mode': x.mode,
        'overrideConsoleSerialPort': x.overrideConsoleSerialPort,
      }));
    }
    if (m.storeForward != null) {
      final x = m.storeForward!;
      children.add(_Subheader('Store & Forward'));
      children.add(_kvTable({
        'enabled': x.enabled,
        'heartbeat': x.heartbeat,
        'records': x.records,
        'historyReturnMax': x.historyReturnMax,
        'historyReturnWindow': x.historyReturnWindow,
        'isServer': x.isServer,
        'emitControlSignals': x.emitControlSignals,
      }));
    }
    if (m.rangeTest != null) {
      final x = m.rangeTest!;
      children.add(_Subheader('Range test'));
      children.add(_kvTable({
        'enabled': x.enabled,
        'sender': x.sender,
        'save': x.save,
        'clearOnReboot': x.clearOnReboot,
      }));
    }
    if (m.externalNotification != null) {
      final x = m.externalNotification!;
      children.add(_Subheader('External notification'));
      children.add(_kvTable({
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
      }));
    }
    if (m.audio != null) {
      final x = m.audio!;
      children.add(_Subheader('Audio'));
      children.add(_kvTable({
        'codec2Enabled': x.codec2Enabled,
        'pttPin': x.pttPin,
        'bitrate': x.bitrate,
        'i2sWs': x.i2sWs,
        'i2sSd': x.i2sSd,
        'i2sDin': x.i2sDin,
        'i2sSck': x.i2sSck,
      }));
    }
    if (m.neighborInfo != null) {
      final x = m.neighborInfo!;
      children.add(_Subheader('Neighbor info'));
      children.add(_kvTable({
        'enabled': x.enabled,
        'updateInterval': x.updateInterval,
        'transmitOverLora': x.transmitOverLora,
      }));
    }
    if (m.remoteHardware != null) {
      final x = m.remoteHardware!;
      children.add(_Subheader('Remote hardware'));
      children.add(_kvTable({
        'enabled': x.enabled,
        'allowUndefinedPinAccess': x.allowUndefinedPinAccess,
        'availablePinsCount': x.availablePins?.length,
      }));
      if (x.availablePins != null && x.availablePins!.isNotEmpty) {
        children.add(_Indent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: x.availablePins!
                .map((p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: _kvTable({
                        'gpioPin': p.gpioPin,
                        'name': p.name,
                        'type': p.type,
                      }),
                    ))
                .toList(),
          ),
        ));
      }
    }
    if (m.paxcounter != null) {
      final x = m.paxcounter!;
      children.add(_Subheader('Paxcounter'));
      children.add(_kvTable({
        'enabled': x.enabled,
        'paxcounterUpdateInterval': x.paxcounterUpdateInterval,
        'wifiThreshold': x.wifiThreshold,
        'bleThreshold': x.bleThreshold,
      }));
    }
    if (m.cannedMessage != null) {
      final x = m.cannedMessage!;
      children.add(_Subheader('Canned message'));
      children.add(_kvTable({
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
      }));
    }
    if (m.ambientLighting != null) {
      final x = m.ambientLighting!;
      children.add(_Subheader('Ambient lighting'));
      children.add(_kvTable({
        'ledState': x.ledState,
        'current': x.current,
        'red': x.red,
        'green': x.green,
        'blue': x.blue,
      }));
    }
    if (m.detectionSensor != null) {
      final x = m.detectionSensor!;
      children.add(_Subheader('Detection sensor'));
      children.add(_kvTable({
        'enabled': x.enabled,
        'minimumBroadcastSecs': x.minimumBroadcastSecs,
        'stateBroadcastSecs': x.stateBroadcastSecs,
        'sendBell': x.sendBell,
        'name': x.name,
        'monitorPin': x.monitorPin,
        'detectionTriggerType': x.detectionTriggerType,
        'usePullup': x.usePullup,
      }));
    }
    if (m.dtnOverlay != null) {
      final x = m.dtnOverlay!;
      children.add(_Subheader('DTN overlay'));
      children.add(_kvTable({
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
      }));
    }
    if (m.broadcastAssist != null) {
      final x = m.broadcastAssist!;
      children.add(_Subheader('Broadcast assist'));
      children.add(_kvTable({
        'enabled': x.enabled,
        'degreeThreshold': x.degreeThreshold,
        'dupThreshold': x.dupThreshold,
        'windowMs': x.windowMs,
        'maxExtraHops': x.maxExtraHops,
        'jitterMs': x.jitterMs,
        'airtimeGuard': x.airtimeGuard,
        'allowedPorts': x.allowedPorts?.join(', '),
      }));
    }
    if (children.isEmpty) return const Text('—');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _deviceUiConfigDetails(DeviceUiConfigDto u) {
    final children = <Widget>[];
    children.add(_kvTable({
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
    }));
    if (u.nodeFilter != null) {
      final f = u.nodeFilter!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader('Node filter'));
      children.add(_kvTable({
        'filterEnabled': f.filterEnabled,
        'minSnr': f.minSnr,
        'hideIgnoredNodes': f.hideIgnoredNodes,
      }));
    }
    if (u.nodeHighlight != null) {
      final h = u.nodeHighlight!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader('Node highlight'));
      children.add(_kvTable({
        'highlightEnabled': h.highlightEnabled,
        'minSnr': h.minSnr,
      }));
    }
    if (u.mapData != null) {
      final m = u.mapData!;
      children.add(const SizedBox(height: 8));
      children.add(_Subheader('Map'));
      children.add(_kvTable({
        'zoom': m.zoom,
        'centerLatI': m.centerLatI,
        'centerLonI': m.centerLonI,
        'followMe': m.followMe,
      }));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: child,
      );
}
