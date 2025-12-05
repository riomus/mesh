import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'logging_service.dart';
import 'meshtastic_ble_client.dart';
import 'meshtastic_ip_client.dart';
import 'meshtastic_usb_client.dart';
import 'meshtastic_client.dart';
import 'device_communication_event_service.dart';
import 'recent_devices_service.dart';
import '../meshtastic/model/meshtastic_event.dart';

/// Represents the connection state for a device along with optional error.
@immutable
class DeviceStatus {
  final String deviceId;
  final DeviceConnectionState state;
  final Object? error;
  final DateTime updatedAt;

  /// Latest known RSSI (dBm) for this device while connected. Null if unknown.
  final int? rssi;

  DeviceStatus({
    required this.deviceId,
    required this.state,
    this.error,
    this.rssi,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  DeviceStatus copyWith({
    DeviceConnectionState? state,
    Object? error = _sentinel,
    int? rssi = _rssiSentinel,
  }) => DeviceStatus(
    deviceId: deviceId,
    state: state ?? this.state,
    error: identical(error, _sentinel) ? this.error : error,
    rssi: identical(rssi, _rssiSentinel) ? this.rssi : rssi,
  );
}

const _sentinel = Object();
const _rssiSentinel = -999999; // impossible dBm sentinel for copyWith

enum DeviceConnectionState { disconnected, connecting, connected, error }

/// A singleton store that owns BLE clients per device and exposes
/// replayable connection status streams. This preserves device status
/// across widget rebuilds and navigation, and provides a single place
/// for notifications or background handlers to subscribe.
class DeviceStatusStore {
  DeviceStatusStore._();

  static final DeviceStatusStore instance = DeviceStatusStore._();

  final StreamController<List<BluetoothDevice>> _connectedDevicesController =
      StreamController.broadcast();
  Stream<List<BluetoothDevice>> get connectedDevicesStream =>
      _connectedDevicesController.stream;

  // Per-device entry
  final Map<String, _Entry> _entries = <String, _Entry>{};

  /// Connect (or reuse existing connection) for the given device.
  /// Returns the active [MeshtasticClient].
  Future<MeshtasticClient> connect(BluetoothDevice device) async {
    final id = device.remoteId.str;
    final entry = _entries.putIfAbsent(id, () => _Entry(device));

    // IMPORTANT: Update the device reference in the entry.
    // If the entry was a placeholder (from recent devices list), it might have a null device
    // or a device object that isn't fully initialized/doesn't have the same internal state.
    // We want to ensure we are using the fresh BluetoothDevice object passed to connect().
    entry.device = device;

    // If already connected or connecting, return the existing client
    if (entry.client != null &&
        entry.status?.state == DeviceConnectionState.connected) {
      return entry.client!;
    }
    if (entry.connecting != null) {
      return await entry.connecting!;
    }

    entry._update(DeviceConnectionState.connecting);
    _connectedDevicesController.add(connectedDevices);
    final completer = Completer<MeshtasticClient>();
    entry.connecting = completer.future;
    try {
      final client = MeshtasticBleClient(device);

      // Wait for ConfigCompleteEvent to ensure we have full state
      final configCompleter = Completer<void>();
      // We must subscribe before connecting because connect() triggers the initial download
      final configSub = client.events.listen((event) {
        if (event is ConfigCompleteEvent) {
          if (!configCompleter.isCompleted) {
            configCompleter.complete();
          }
        }
      });

      await client.connect();
      entry.client = client;

      // Wait for config to complete or timeout, but don't block forever
      try {
        _log(id, 'Waiting for ConfigCompleteEvent...');
        await configCompleter.future.timeout(const Duration(seconds: 15));
        _log(id, 'ConfigCompleteEvent received');
      } catch (e) {
        _log(
          id,
          'Timed out waiting for ConfigCompleteEvent, proceeding anyway',
          level: 'warn',
        );
      } finally {
        configSub.cancel();
      }

      // Begin listening for OS/device connection state changes
      entry._listenConnectionState();
      entry._update(DeviceConnectionState.connected);
      entry._subscribeClientRssi();
      _connectedDevicesController.add(connectedDevices);
      _log(id, 'Connected');

      // Add to recent devices list
      final scanResult = ScanResult(
        device: device,
        advertisementData: AdvertisementData(
          advName: device.platformName,
          txPowerLevel: null,
          connectable: true,
          manufacturerData:
              {}, // We might miss this, but it's okay for basic listing
          serviceData: {},
          serviceUuids: [],
          appearance: null,
        ),
        rssi: 0, // Unknown
        timeStamp: DateTime.now(),
      );
      RecentDevicesService.instance.add(scanResult);

      completer.complete(client);
      return client;
    } catch (e) {
      // If we failed to connect, we should probably disconnect to clean up
      try {
        await entry.client?.dispose();
      } catch (_) {}
      entry.client = null;

      entry._update(DeviceConnectionState.error, error: e);
      entry._scheduleErrorRemoval();
      _connectedDevicesController.add(connectedDevices);
      _log(id, 'Connect failed: $e', level: 'error');
      completer.completeError(e);
      rethrow;
    } finally {
      entry.connecting = null;
    }
  }

  Future<MeshtasticClient> connectIp(String host, int port) async {
    final deviceId =
        'IP:$host:$port'; // Temporary ID until we get real one from config
    final entry = _entries.putIfAbsent(deviceId, () => _Entry.ip(deviceId));

    if (entry.client != null &&
        entry.status?.state == DeviceConnectionState.connected) {
      return entry.client!;
    }
    if (entry.connecting != null) {
      return await entry.connecting!;
    }

    entry._update(DeviceConnectionState.connecting);
    // Note: IP devices are not added to _connectedDevicesController yet as it expects BluetoothDevice

    final completer = Completer<MeshtasticClient>();
    entry.connecting = completer.future;

    try {
      final client = MeshtasticIpClient(
        host: host,
        port: port,
        deviceId: deviceId,
      );

      // Wait for ConfigCompleteEvent? IP might be faster, but let's stick to pattern if needed.
      // For now, just connect.

      await client.connect();
      entry.client = client;

      entry._update(DeviceConnectionState.connected);
      entry._subscribeClientRssi();
      _log(deviceId, 'Connected via IP');
      completer.complete(client);
      return client;
    } catch (e) {
      try {
        await entry.client?.dispose();
      } catch (_) {}
      entry.client = null;
      entry._update(DeviceConnectionState.error, error: e);
      entry._scheduleErrorRemoval();
      _log(deviceId, 'Connect IP failed: $e', level: 'error');
      completer.completeError(e);
      rethrow;
    } finally {
      entry.connecting = null;
    }
  }

  Future<MeshtasticClient> connectUsb(String portName) async {
    final deviceId = 'USB:$portName'; // Temporary ID
    final entry = _entries.putIfAbsent(deviceId, () => _Entry.usb(deviceId));

    if (entry.client != null &&
        entry.status?.state == DeviceConnectionState.connected) {
      return entry.client!;
    }
    if (entry.connecting != null) {
      return await entry.connecting!;
    }

    entry._update(DeviceConnectionState.connecting);

    final completer = Completer<MeshtasticClient>();
    entry.connecting = completer.future;

    try {
      final client = MeshtasticUsbClient(
        portName: portName,
        deviceId: deviceId,
      );
      await client.connect();
      entry.client = client;

      entry._update(DeviceConnectionState.connected);
      entry._subscribeClientRssi();
      _log(deviceId, 'Connected via USB');
      completer.complete(client);
      return client;
    } catch (e) {
      try {
        await entry.client?.dispose();
      } catch (_) {}
      entry.client = null;
      entry._update(DeviceConnectionState.error, error: e);
      entry._scheduleErrorRemoval();
      _log(deviceId, 'Connect USB failed: $e', level: 'error');
      completer.completeError(e);
      rethrow;
    } finally {
      entry.connecting = null;
    }
  }

  /// Connect to a device by its ID if it is already known to the store.
  Future<MeshtasticClient?> connectToId(String deviceId) async {
    final entry = _entries[deviceId];
    if (entry != null) {
      // If we have an active client, return it
      if (entry.client != null &&
          entry.status?.state == DeviceConnectionState.connected) {
        return entry.client;
      }

      if (entry.device != null) {
        return connect(entry.device!);
      } else {
        // For IP/USB devices, if we are not connected, we can't easily reconnect
        // without host/port/portName unless we stored them.
        // But if we are here, maybe we are just checking status or trying to send message.
        return null;
      }
    }
    return null;
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
          await entry.client!.disconnect();
          // Give the radio a brief moment to handle the request
          await Future<void>.delayed(const Duration(milliseconds: 100));
        } catch (_) {
          // Proceed with teardown regardless of failures
        }
      }
      entry._unsubscribeClientRssi();
      await entry.connStateSub?.cancel();
    } catch (_) {}
    try {
      await entry.client?.dispose();
    } catch (_) {}
    entry.client = null;
    entry._update(DeviceConnectionState.disconnected);
    _connectedDevicesController.add(connectedDevices);
    _log(deviceId, 'Disconnected');
  }

  /// Obtain the latest status synchronously if present.
  DeviceStatus? statusNow(String deviceId) => _entries[deviceId]?.status;

  /// A stream of status updates for a given device that first replays the last
  /// known status (if any) and then emits live updates.
  Stream<DeviceStatus> statusStream(String deviceId) async* {
    final entry = _entries.putIfAbsent(
      deviceId,
      () => _Entry.placeholder(deviceId),
    );
    if (entry.status != null) {
      yield entry.status!;
    }
    yield* entry.controller.stream;
  }

  /// Convenience helper: true if connected now.
  bool isConnected(String deviceId) =>
      _entries[deviceId]?.status?.state == DeviceConnectionState.connected;

  /// Returns the first connected device found, or null if none.
  BluetoothDevice? get connectedDevice {
    final devices = connectedDevices;
    return devices.isNotEmpty ? devices.first : null;
  }

  /// Returns all connected or connecting devices.
  List<BluetoothDevice> get connectedDevices {
    return _entries.values
        .where(
          (e) =>
              e.status?.state == DeviceConnectionState.connected ||
              e.status?.state == DeviceConnectionState.connecting ||
              e.status?.state == DeviceConnectionState.error,
        )
        .map((e) => e.device)
        .where((d) => d != null)
        .cast<BluetoothDevice>()
        .toList();
  }

  /// Dispose all clients (e.g., on app shutdown).
  Future<void> disposeAll() async {
    for (final e in _entries.values) {
      try {
        await e.connStateSub?.cancel();
      } catch (_) {}
      try {
        await e.client?.dispose();
      } catch (_) {}
      e._cancelErrorRemoval();
      await e.controller.close();
    }
    _entries.clear();
  }

  static void _log(String deviceId, String msg, {String level = 'info'}) {
    final tags = MeshtasticBleClient.logTagsForDeviceId(deviceId);
    LoggingService.instance.push(
      tags: tags,
      level: level,
      message: '[DeviceStatusStore] $msg',
    );
  }
}

class _Entry {
  final String deviceId;
  BluetoothDevice? device; // Nullable for IP/USB devices
  MeshtasticClient? client;
  Future<MeshtasticClient>? connecting;
  final StreamController<DeviceStatus> controller =
      StreamController<DeviceStatus>.broadcast();
  DeviceStatus? status;
  StreamSubscription<BluetoothConnectionState>? connStateSub;
  // Subscription to client's RSSI stream
  StreamSubscription<int>? _clientRssiSub;
  Timer? _errorRemovalTimer;

  _Entry(this.device)
    : deviceId = device!.remoteId.str,
      status = DeviceStatus(
        deviceId: device.remoteId.str,
        state: DeviceConnectionState.disconnected,
      );

  _Entry.ip(this.deviceId)
    : device = null,
      status = DeviceStatus(
        deviceId: deviceId,
        state: DeviceConnectionState.disconnected,
      );

  _Entry.usb(this.deviceId)
    : device = null,
      status = DeviceStatus(
        deviceId: deviceId,
        state: DeviceConnectionState.disconnected,
      );

  _Entry.placeholder(this.deviceId) : device = null, status = null;

  void _update(DeviceConnectionState state, {Object? error, int? rssi}) {
    // If we are moving out of error state, cancel any pending removal
    if (state != DeviceConnectionState.error) {
      _cancelErrorRemoval();
    }

    final s = DeviceStatus(
      deviceId: deviceId,
      state: state,
      error: error,
      rssi: rssi ?? status?.rssi,
    );
    status = s;
    controller.add(s);
  }

  void _scheduleErrorRemoval() {
    _cancelErrorRemoval();
    _errorRemovalTimer = Timer(const Duration(seconds: 5), () {
      if (status?.state == DeviceConnectionState.error) {
        _update(DeviceConnectionState.disconnected);
        DeviceStatusStore.instance._connectedDevicesController.add(
          DeviceStatusStore.instance.connectedDevices,
        );
      }
    });
  }

  void _cancelErrorRemoval() {
    _errorRemovalTimer?.cancel();
    _errorRemovalTimer = null;
  }

  void _listenConnectionState() {
    connStateSub?.cancel();
    if (device == null)
      return; // IP/USB devices don't have OS-level connection state stream yet
    connStateSub = device!.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        // Update status and notify services so UI can reflect and users can see it.
        _unsubscribeClientRssi();
        _update(DeviceConnectionState.disconnected);
        DeviceStatusStore.instance._connectedDevicesController.add(
          DeviceStatusStore.instance.connectedDevices,
        );
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

  void _subscribeClientRssi() {
    _clientRssiSub?.cancel();
    final c = client;
    if (c == null) return;
    _clientRssiSub = c.rssi.listen((value) {
      try {
        _update(status?.state ?? DeviceConnectionState.connected, rssi: value);
      } catch (_) {}
    });
    DeviceStatusStore._log(deviceId, 'Subscribed to client RSSI');
  }

  void _unsubscribeClientRssi() {
    try {
      _clientRssiSub?.cancel();
    } catch (_) {}
    _clientRssiSub = null;
    DeviceStatusStore._log(deviceId, 'Unsubscribed from client RSSI');
  }
}
