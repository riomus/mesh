import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'logging_service.dart';
import 'device_communication_event_service.dart';

// Protobufs
import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_mappers.dart';

/// Meshtastic BLE client that implements the documented flow:
/// - Connect to device and set MTU 512
/// - Discover SERVICE and three characteristics: ToRadio, FromRadio, FromNum
/// - Send startConfig (wantConfigId = 0) to ToRadio
/// - Drain FromRadio until empty for initial download
/// - Subscribe to FromNum notifications; on notify, drain FromRadio until empty
/// - Provide public API to send ToRadio messages
class MeshtasticBleClient {
  // UUIDs (lowercase normalized)
  static const String serviceUuid = '6ba1b218-15a8-461f-9fa8-5dcae273eafd';
  static const String toRadioUuid = 'f75c76d2-129e-4dad-a1dd-7866124401e7';
  static const String fromRadioUuid = '2c55e69e-4993-11ed-b878-0242ac120002';
  static const String fromNumUuid = 'ed9da18c-a800-4f66-a670-aa7547e34453';

  /// Structured logging tags for Meshtastic devices.
  /// Example: {'network': ['meshtastic'], 'deviceId': [<id>], 'class': ['MeshtasticBleClient']}
  static Map<String, Object?> logTagsForDeviceId(String deviceId) => {
        'network': 'meshtastic',
        'deviceId': deviceId,
        'class': 'MeshtasticBleClient',
      };

  /// Convenience overload to build structured tags directly from a device.
  static Map<String, Object?> logTagsForDevice(BluetoothDevice device) =>
      logTagsForDeviceId(device.remoteId.str);

  final BluetoothDevice device;

  BluetoothCharacteristic? _toRadio;
  BluetoothCharacteristic? _fromRadio;
  BluetoothCharacteristic? _fromNum;

  StreamSubscription<List<int>>? _fromNumSub;

  final _eventsController = StreamController<MeshtasticEvent>.broadcast();

  // Cache last negotiated MTU; default to a conservative 185, will request 512
  int _mtu = 185;

  // removed unused _isInitialized flag
  bool _isDisposed = false;

  MeshtasticBleClient(this.device);

  /// High-level events parsed from FromRadio payloads.
  Stream<MeshtasticEvent> get events => _eventsController.stream;

  Future<void> connect({Duration timeout = const Duration(seconds: 20)}) async {
    _ensureNotDisposed();
    _log('Connecting to ${device.remoteId.str} ...');
    int? requestMtu = 512;
    if (kIsWeb){
      requestMtu=null;
    }

    await device.connect(timeout: timeout, license: License.free, mtu: requestMtu);

    // Request MTU 512 only on Android. Other platforms either ignore or don't support it.
    // On non-Android, just read the current MTU.
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await device.requestMtu(512);
        _mtu = device.mtuNow;
        _log('MTU negotiated (Android): $_mtu');
      } else {
        _mtu = device.mtuNow; // best effort on non-Android
        _log('MTU (no request on this platform): $_mtu');
      }
    } catch (e) {
      _log('MTU request failed or unsupported: $e', level: 'warn');
      _mtu = device.mtuNow; // best effort
    }

    await _discoverAndBindCharacteristics();
    await _startInitialDownload();
  }

  Future<void> _discoverAndBindCharacteristics() async {
    _log('Discovering services ...');
    final services = await device.discoverServices();

    BluetoothService? targetService;
    for (final s in services) {
      if (s.uuid.str.toLowerCase() == serviceUuid) {
        targetService = s;
        break;
      }
    }
    if (targetService == null) {
      _log('Meshtastic service not found: $serviceUuid', level: 'error');
      throw StateError('Meshtastic service not found: $serviceUuid');
    }

    for (final c in targetService.characteristics) {
      final id = c.uuid.str.toLowerCase();
      if (id == toRadioUuid) _toRadio = c;
      if (id == fromRadioUuid) _fromRadio = c;
      if (id == fromNumUuid) _fromNum = c;
    }
    _log('Found characteristics for Meshtastic');
    if (_toRadio == null || _fromRadio == null || _fromNum == null) {
      _log('Missing one or more required characteristics', level: 'error');
      throw StateError('Missing one or more required characteristics');
    }

    _fromNumSub?.cancel();
    _fromNumSub = _fromNum!.onValueReceived.listen((_) async {
      _log('FromNum notify received -> draining FromRadio');
      await _drainFromRadioUntilEmpty();
    });
    _log('Subscribed to from num');
    // Enable notify on FromNum now, and drain FromRadio on notifications
    try {
      await _fromNum!.setNotifyValue(true);
    } catch (e) {
        _log('Failed to enable notifications on FromNum: $e', level: 'error');
    }
    _log('Discovery done');
  }

  Future<void> _startInitialDownload() async {
    _log('Sending startConfig (wantConfigId=0)');
    final start = mesh.ToRadio(wantConfigId: 0);
    await sendToRadio(start);

    // Drain FromRadio until empty for initial state
    await _drainFromRadioUntilEmpty();
  }

  Future<void> _drainFromRadioUntilEmpty() async {
    final fr = _fromRadio!;
    while (true) {
      final value = await fr.read();
      if (value.isEmpty) {
        _log('FromRadio empty -> stop draining');
        break;
      }
      try {
        final msg = mesh.FromRadio.fromBuffer(value);
        // Emit structured event only (no legacy FromRadio stream)
        try {
          final event = MeshtasticMappers.fromFromRadio(msg);
          _eventsController.add(event);
          // Also publish into the global DeviceCommunicationEventService so
          // app-wide widgets (like EventsListWidget) can display events.
          try {
            DeviceCommunicationEventService.instance.pushMeshtastic(
              event: event,
              deviceId: device.remoteId.str,
              // Keep summary minimal; detailed rendering is handled by tiles.
              summary: event.runtimeType.toString(),
            );
          } catch (_) {
            // Do not fail the BLE read loop if the event service throws.
          }
        } catch (mapErr) {
          _log('Failed to map FromRadio to event: $mapErr', level: 'warn');
        }
      } catch (e, st) {
        _log('Failed to parse FromRadio: $e', level: 'error');
        if (kDebugMode) {
          // ignore: avoid_print
          print(st);
        }
      }
    }
  }

  /// Send arbitrary `ToRadio` protobuf to the device (Write With Response).
  /// Handles chunking to fit negotiated MTU (payload <= MTU-3).
  Future<void> sendToRadio(mesh.ToRadio message) async {
    final data = message.writeToBuffer();
    final characteristic = _toRadio!;

    final maxChunk = max(20, (_mtu - 3));
    int offset = 0;
    while (offset < data.length) {
      final end = (offset + maxChunk) > data.length ? data.length : (offset + maxChunk);
      final chunk = data.sublist(offset, end);
      await characteristic.write(chunk, withoutResponse: false);
      offset = end;
    }
  }

  /// Convenience: send a MeshPacket wrapped in ToRadio
  Future<void> sendMeshPacket(mesh.MeshPacket packet) async {
    await sendToRadio(mesh.ToRadio(packet: packet));
  }

  /// Dispose resources and disconnect.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      await _fromNumSub?.cancel();
    } catch (_) {}
    await _eventsController.close();
    try {
      await device.disconnect();
    } catch (_) {}
  }


  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('MeshtasticBleClient is disposed');
    }
  }

  void _log(String msg, {String level = 'info'}) {
    final t = MeshtasticBleClient.logTagsForDevice(device);
    LoggingService.instance.push(tags: t, level: level, message: msg);
  }
}
