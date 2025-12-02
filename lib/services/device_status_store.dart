import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'logging_service.dart';
import 'meshtastic_ble_client.dart';
import 'device_communication_event_service.dart';

/// Represents the connection state for a device along with optional error.
@immutable
class DeviceStatus {
  final String deviceId;
  final DeviceConnectionState state;
  final Object? error;
  final DateTime updatedAt;

  DeviceStatus({
    required this.deviceId,
    required this.state,
    this.error,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  DeviceStatus copyWith({
    DeviceConnectionState? state,
    Object? error = _sentinel,
  }) => DeviceStatus(
        deviceId: deviceId,
        state: state ?? this.state,
        error: identical(error, _sentinel) ? this.error : error,
      );
}

const _sentinel = Object();

enum DeviceConnectionState { disconnected, connecting, connected, error }

/// A singleton store that owns BLE clients per device and exposes
/// replayable connection status streams. This preserves device status
/// across widget rebuilds and navigation, and provides a single place
/// for notifications or background handlers to subscribe.
class DeviceStatusStore {
  DeviceStatusStore._();

  static final DeviceStatusStore instance = DeviceStatusStore._();

  // Per-device entry
  final Map<String, _Entry> _entries = <String, _Entry>{};

  /// Connect (or reuse existing connection) for the given device.
  /// Returns the active [MeshtasticBleClient].
  Future<MeshtasticBleClient> connect(BluetoothDevice device) async {
    final id = device.remoteId.str;
    final entry = _entries.putIfAbsent(id, () => _Entry(device));
    // If already connected or connecting, return the existing client
    if (entry.client != null && entry.status?.state == DeviceConnectionState.connected) {
      return entry.client!;
    }
    if (entry.connecting != null) {
      return await entry.connecting!;
    }

    entry._update(DeviceConnectionState.connecting);
    final completer = Completer<MeshtasticBleClient>();
    entry.connecting = completer.future;
    try {
      final client = MeshtasticBleClient(device);
      await client.connect();
      entry.client = client;
      // Begin listening for OS/device connection state changes
      entry._listenConnectionState();
      entry._update(DeviceConnectionState.connected);
      _log(id, 'Connected');
      completer.complete(client);
      return client;
    } catch (e) {
      entry._update(DeviceConnectionState.error, error: e);
      _log(id, 'Connect failed: $e', level: 'error');
      completer.completeError(e);
      rethrow;
    } finally {
      entry.connecting = null;
    }
  }

  /// Disconnect the device and dispose its client. Keeps the entry so status
  /// can be replayed as `disconnected`.
  Future<void> disconnect(String deviceId) async {
    final entry = _entries[deviceId];
    if (entry == null) return;
    try {
      // Politely inform the radio first via ToRadio(disconnect=true)
      if (entry.client != null) {
        try {
          await entry.client!.sendDisconnectCommand();
          // Give the radio a brief moment to handle the request
          await Future<void>.delayed(const Duration(milliseconds: 100));
        } catch (_) {
          // Proceed with teardown regardless of failures
        }
      }
      await entry.connStateSub?.cancel();
    } catch (_) {}
    try {
      await entry.client?.dispose();
    } catch (_) {}
    entry.client = null;
    entry._update(DeviceConnectionState.disconnected);
    _log(deviceId, 'Disconnected');
  }

  /// Obtain the latest status synchronously if present.
  DeviceStatus? statusNow(String deviceId) => _entries[deviceId]?.status;

  /// A stream of status updates for a given device that first replays the last
  /// known status (if any) and then emits live updates.
  Stream<DeviceStatus> statusStream(String deviceId) async* {
    final entry = _entries.putIfAbsent(deviceId, () => _Entry.placeholder(deviceId));
    if (entry.status != null) {
      yield entry.status!;
    }
    yield* entry.controller.stream;
  }

  /// Convenience helper: true if connected now.
  bool isConnected(String deviceId) =>
      _entries[deviceId]?.status?.state == DeviceConnectionState.connected;

  /// Dispose all clients (e.g., on app shutdown).
  Future<void> disposeAll() async {
    for (final e in _entries.values) {
      try {
        await e.connStateSub?.cancel();
      } catch (_) {}
      try {
        await e.client?.dispose();
      } catch (_) {}
      await e.controller.close();
    }
    _entries.clear();
  }

  static void _log(String deviceId, String msg, {String level = 'info'}) {
    final tags = MeshtasticBleClient.logTagsForDeviceId(deviceId);
    LoggingService.instance.push(tags: tags, level: level, message: '[DeviceStatusStore] $msg');
  }
}

class _Entry {
  final String deviceId;
  BluetoothDevice device;
  MeshtasticBleClient? client;
  Future<MeshtasticBleClient>? connecting;
  final StreamController<DeviceStatus> controller = StreamController<DeviceStatus>.broadcast();
  DeviceStatus? status;
  StreamSubscription<BluetoothConnectionState>? connStateSub;

  _Entry(this.device)
      : deviceId = device.remoteId.str,
        status = DeviceStatus(deviceId: device.remoteId.str, state: DeviceConnectionState.disconnected);

  _Entry.placeholder(this.deviceId)
      : device = BluetoothDevice(remoteId: DeviceIdentifier(deviceId)),
        status = null;

  void _update(DeviceConnectionState state, {Object? error}) {
    final s = DeviceStatus(deviceId: deviceId, state: state, error: error);
    status = s;
    controller.add(s);
  }

  void _listenConnectionState() {
    connStateSub?.cancel();
    connStateSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        // Update status and notify services so UI can reflect and users can see it.
        _update(DeviceConnectionState.disconnected);
        DeviceStatusStore._log(deviceId, 'Disconnected (device event)');
        // Push a lightweight device communication event for user-visible notification
        try {
          DeviceCommunicationEventService.instance.push(
            tags: {
              'network': 'meshtastic',
              'deviceId': deviceId,
              'class': 'DeviceStatusStore',
            },
            summary: 'Device disconnected',
          );
        } catch (_) {}
      }
    });
  }
}
