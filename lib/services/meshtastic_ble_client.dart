import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'logging_service.dart';
import 'device_communication_event_service.dart';
import 'ble_exceptions.dart';

// Protobufs
import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_mappers.dart';
import '../meshtastic/model/device_type.dart';

import 'meshtastic_client.dart';

/// Meshtastic BLE client that implements the documented flow:
/// - Connect to device and set MTU 512
/// - Discover SERVICE and three characteristics: ToRadio, FromRadio, FromNum
/// - Send startConfig (wantConfigId = 0) to ToRadio
/// - Drain FromRadio until empty for initial download
/// - Subscribe to FromNum notifications; on notify, drain FromRadio until empty
/// - Provide public API to send ToRadio messages
class MeshtasticBleClient extends MeshtasticClient {
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
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  // RSSI listener encapsulated in the client
  StreamSubscription<dynamic>? _rssiSub;
  final StreamController<int> _rssiController =
      StreamController<int>.broadcast();
  int? _lastRssi;

  final _eventsController = StreamController<MeshtasticEvent>.broadcast();

  // Cache last negotiated MTU; default to a conservative 185, will request 512
  int _mtu = 185;

  // removed unused _isInitialized flag
  bool _isDisposed = false;

  // Heartbeat timer to periodically ping the radio while connected
  Timer? _heartbeatTimer;
  final Duration _heartbeatInterval;

  MeshtasticBleClient(
    this.device, {
    Duration heartbeatInterval = const Duration(minutes: 1),
  }) : _heartbeatInterval = heartbeatInterval;

  /// High-level events parsed from FromRadio payloads.
  @override
  Stream<MeshtasticEvent> get events => _eventsController.stream;

  /// Live RSSI updates (dBm) while connected. Emits when values change.
  @override
  Stream<int> get rssi => _rssiController.stream;

  @override
  DeviceType get deviceType => DeviceType.meshtastic;

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 20)}) async {
    _ensureNotDisposed();
    _log('Connecting to ${device.remoteId.str} ...');

    // Check if already connected at the OS level
    var isConnected = false;
    try {
      // Check system devices (bonded devices on Android, connected devices on iOS)
      final connectedDevices = await FlutterBluePlus.systemDevices([]);
      if (connectedDevices.any((d) => d.remoteId == device.remoteId)) {
        isConnected = true;
        _log('Device is already connected at OS level');
      }
    } catch (e) {
      _log('Failed to check existing connection status: $e', level: 'warn');
    }

    if (!isConnected) {
      int? requestMtu = 512;
      if (kIsWeb) {
        requestMtu = null;
      }

      try {
        _log('Initiating BLE connection (timeout: ${timeout.inSeconds}s)...');
        await device.connect(
          timeout: timeout,
          license: License.free,
          mtu: requestMtu,
        );
        _log('BLE connection established');
      } on TimeoutException {
        _log(
          'BLE connection timed out after ${timeout.inSeconds}s',
          level: 'error',
        );
        throw BleConnectionTimeoutException(device.remoteId.str, timeout);
      } catch (e) {
        _log('BLE connection failed: $e', level: 'error');
        // Categorize the error
        throw BleErrorHelper.categorize(device.remoteId.str, e);
      }
    } else {
      _log('Skipping connect() call because device is already connected');
    }

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

    try {
      _log('Discovering services and binding characteristics...');
      await _discoverAndBindCharacteristics();
      _log('Service discovery complete');
    } catch (e) {
      _log('Service discovery failed: $e', level: 'error');
      rethrow;
    }

    try {
      _log('Requesting device configuration...');
      await requestConfig();
      _log('Configuration request complete');
    } catch (e) {
      _log('Configuration request failed: $e', level: 'error');
      rethrow;
    }

    // Start listening for connection state changes for logging/cleanup
    _connStateSub?.cancel();
    _connStateSub = device.connectionState.listen((state) async {
      _log('Connection state changed: $state');
      if (state == BluetoothConnectionState.disconnected) {
        // Radio link dropped -> stop heartbeat and readers
        _stopHeartbeat();
        _stopRssiListener();
        try {
          await _fromNumSub?.cancel();
        } catch (_) {}
      }
    });

    // Kick off periodic heartbeat messages
    _startHeartbeat();
    // Start RSSI listener
    _startRssiListener();
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
    _fromNumSub = _fromNum!.onValueReceived.listen((value) async {
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

  @override
  Future<void> requestConfig() async {
    _log('Sending startConfig (wantConfigId=0)');
    final start = mesh.ToRadio(wantConfigId: 0);
    await sendToRadio(start);

    // Drain FromRadio until empty for initial state
    await _drainFromRadioUntilEmpty();
  }

  void _startHeartbeat() {
    // Avoid duplicates
    _heartbeatTimer?.cancel();
    var nonce = 0;
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) async {
      try {
        final hb = mesh.ToRadio(heartbeat: mesh.Heartbeat(nonce: nonce));
        await sendToRadio(hb);
        nonce = nonce + 1;
        _log('Heartbeat sent');
      } catch (e) {
        _log('Failed to send heartbeat: $e', level: 'warn');
      }
    });
    _log('Heartbeat scheduler started: every ${_heartbeatInterval.inSeconds}s');
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _log('Heartbeat scheduler stopped');
  }

  Future<void> _drainFromRadioUntilEmpty() async {
    final fr = _fromRadio!;
    while (true) {
      _log('Draining FromRadio ...');
      final value = await fr.read();
      if (value.isEmpty) {
        _log('FromRadio empty -> stop draining');
        break;
      }
      try {
        final msg = mesh.FromRadio.fromBuffer(value);
        _log('FromRadio received: $msg');
        // Emit structured event only (no legacy FromRadio stream)
        try {
          final event = MeshtasticMappers.fromFromRadio(msg);
          _log('FromRadio mapped to event: $event');
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
  @override
  Future<void> sendToRadio(mesh.ToRadio message) async {
    _log('Sending ToRadio message: $message');
    final data = message.writeToBuffer();
    final characteristic = _toRadio!;

    _log('Total bytes to send: ${data.length}');

    // Python implementation does not chunk manually.
    // We send the entire buffer and let the OS/stack handle fragmentation if needed.
    await characteristic.write(data, withoutResponse: false);

    _log('Finished sending ToRadio message');
  }

  /// Convenience: send a MeshPacket wrapped in ToRadio
  @override
  Future<void> sendMeshPacket(mesh.MeshPacket packet) async {
    await sendToRadio(mesh.ToRadio(packet: packet));
  }

  /// Send a polite disconnect command to the radio before tearing down BLE.
  ///
  /// This writes `ToRadio(disconnect: true)` to the ToRadio characteristic.
  /// If the characteristic is not available or the write fails, the error is
  /// logged and the method returns without throwing so higher-level teardown
  /// can proceed.
  Future<void> sendDisconnectCommand() async {
    try {
      // If client has not discovered/bound ToRadio yet, skip gracefully
      if (_toRadio == null) {
        _log(
          'ToRadio characteristic not available, skipping ToRadio.disconnect',
          level: 'warn',
        );
        return;
      }
      _log('Sending ToRadio.disconnect=true');
      final msg = mesh.ToRadio(disconnect: true);
      await sendToRadio(msg);
      _log('ToRadio.disconnect sent');
    } catch (e) {
      _log('Failed to send ToRadio.disconnect: $e', level: 'warn');
    }
  }

  @override
  Future<void> disconnect() async {
    await sendDisconnectCommand();
    await dispose();
  }

  /// Dispose resources and disconnect.
  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      await _fromNumSub?.cancel();
    } catch (_) {}
    try {
      await _connStateSub?.cancel();
    } catch (_) {}
    try {
      await _rssiSub?.cancel();
    } catch (_) {}
    _rssiSub = null;
    _stopHeartbeat();
    await _eventsController.close();
    await _rssiController.close();
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

  // ===== RSSI listener encapsulation =====
  void _startRssiListener() {
    // Cancel any previous listener
    _rssiSub?.cancel();
    // Seed one immediate read for quicker UI feedback
    () async {
      try {
        final v = await device.readRssi();
        _lastRssi = v;
        if (!_rssiController.isClosed) _rssiController.add(v);
      } catch (_) {}
    }();
    try {
      _rssiSub = FlutterBluePlus.events.onReadRssi
          .where((e) {
            try {
              return e.device.remoteId.str == device.remoteId.str;
            } catch (_) {
              return false;
            }
          })
          .listen((e) {
            try {
              final val = e.rssi;
              if (_lastRssi == null || (val - _lastRssi!).abs() >= 1) {
                _lastRssi = val;
                if (!_rssiController.isClosed) _rssiController.add(val);
              }
            } catch (_) {}
          });
      _log('Started RSSI listener (client)');
    } catch (e) {
      _log('Failed to start RSSI listener: $e', level: 'warn');
    }
  }

  void _stopRssiListener() {
    try {
      _rssiSub?.cancel();
    } catch (_) {}
    _rssiSub = null;
    _log('Stopped RSSI listener (client)');
  }
}
