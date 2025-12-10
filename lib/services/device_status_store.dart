import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'logging_service.dart';
import 'meshtastic_ble_client.dart';
import 'meshcore_ble_client.dart';
import 'meshtastic_ip_client.dart';
import 'meshtastic_usb_client.dart';
import 'meshtastic_client.dart';
import 'simulation_meshtastic_device.dart';
import 'device_communication_event_service.dart';
import 'recent_devices_service.dart';
import 'settings_service.dart';
import 'ble_exceptions.dart';
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshcore_constants.dart';
import '../meshtastic/model/device_type.dart';

/// Represents the connection state for a device along with optional error.
@immutable
class DeviceStatus {
  final String deviceId;
  final DeviceConnectionState state;
  final Object? error;
  final DateTime updatedAt;

  /// Latest known RSSI (dBm) for this device while connected. Null if unknown.
  final int? rssi;

  /// The type of protocol this device uses.
  final DeviceType? deviceType;

  DeviceStatus({
    required this.deviceId,
    required this.state,
    this.error,
    this.rssi,
    this.deviceType,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  DeviceStatus copyWith({
    DeviceConnectionState? state,
    Object? error = _sentinel,
    int? rssi = _rssiSentinel,
    DeviceType? deviceType,
  }) => DeviceStatus(
    deviceId: deviceId,
    state: state ?? this.state,
    error: identical(error, _sentinel) ? this.error : error,
    rssi: identical(rssi, _rssiSentinel) ? this.rssi : rssi,
    deviceType: deviceType ?? this.deviceType,
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
  /// [deviceName] is an optional display name for the device.
  /// [heartbeatInterval] is the interval for BLE heartbeat messages (default: 1 minute).
  Future<MeshtasticClient> connect(
    BluetoothDevice device, {
    String? deviceName,
    Duration heartbeatInterval = const Duration(minutes: 1),
  }) async {
    final id = device.remoteId.str;
    final entry = _entries.putIfAbsent(id, () => _Entry(device));

    // IMPORTANT: Update the device reference in the entry.
    // If the entry was a placeholder (from recent devices list), it might have a null device
    // or a device object that isn't fully initialized/doesn't have the same internal state.
    // We want to ensure we are using the fresh BluetoothDevice object passed to connect().
    entry.device = device;

    // Store the device name if provided, otherwise use platformName
    if (deviceName != null && deviceName.isNotEmpty) {
      entry.deviceName = deviceName;
    } else if (entry.deviceName == null || entry.deviceName!.isEmpty) {
      entry.deviceName = device.platformName.isNotEmpty
          ? device.platformName
          : device.remoteId.str;
    }

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

    // Monitor bond state for pairing failures (bonding -> none)
    // Declaring here so it is visible in catch/finally blocks
    bool pairingFailureDetected = false;
    StreamSubscription<BluetoothBondState>? bondStateSub;

    try {
      // Get heartbeat interval from settings if not explicitly provided
      final effectiveHeartbeat = heartbeatInterval != const Duration(minutes: 1)
          ? heartbeatInterval
          : Duration(
              seconds:
                  SettingsService
                      .instance
                      .current
                      ?.bleHeartbeatIntervalSeconds ??
                  60,
            );

      // Ensure connection before discovering services
      _log(id, 'Ensuring BLE connection...');
      await device.connect(license: License.free);

      // We only care about this check on Android usually, as iOS handles pairing differently (OS level).
      // But flutter_blue_plus exposes bondState which might be useful cross-platform or just Android.
      // We'll listen anyway.
      try {
        BluetoothBondState? previousState;
        bondStateSub = device.bondState.listen((state) {
          if (previousState == BluetoothBondState.bonding &&
              state == BluetoothBondState.none) {
            pairingFailureDetected = true;
            _log(
              id,
              'Detected pairing failure (bonding -> none)',
              level: 'warn',
            );
          }
          previousState = state;
        });
      } catch (e) {
        _log(id, 'Failed to listen to bondState: $e', level: 'warn');
      }

      // Discover services to detect protocol (Meshtastic vs MeshCore)
      _log(id, 'Discovering services to detect protocol...');
      List<BluetoothService> services;
      try {
        services = await device.discoverServices();
      } catch (e) {
        _log(
          id,
          'Service discovery for protocol detection failed: $e',
          level: 'error',
        );
        await bondStateSub?.cancel();
        throw StateError('Failed to discover services for protocol detection');
      }

      // Check for MeshCore protocol (Nordic UART Service)
      bool isMeshCore = false;
      for (final service in services) {
        if (service.uuid.str.toLowerCase() == MeshCoreConstants.serviceUuid) {
          isMeshCore = true;
          break;
        }
      }

      entry.deviceType = isMeshCore
          ? DeviceType.meshcore
          : DeviceType.meshtastic;

      // Instantiate the appropriate client
      final MeshtasticClient client;
      if (isMeshCore) {
        _log(id, 'Detected MeshCore protocol device');
        client = MeshCoreBleClient(device);
      } else {
        _log(id, 'Detected Meshtastic protocol device');
        client = MeshtasticBleClient(
          device,
          heartbeatInterval: effectiveHeartbeat,
        );
      }

      // Wait for ConfigCompleteEvent to ensure we have full state
      final configCompleter = Completer<void>();
      Timer? activityTimer;

      // Get timeout from settings (default to 15 seconds if not set)
      final timeoutSeconds =
          SettingsService.instance.current?.configTimeoutSeconds ?? 15;
      final timeoutDuration = Duration(seconds: timeoutSeconds);

      // We must subscribe before connecting because connect() triggers the initial download
      final configSub = client.events.listen((event) {
        // Reset the activity timer on any event
        activityTimer?.cancel();
        activityTimer = Timer(timeoutDuration, () {
          if (!configCompleter.isCompleted) {
            configCompleter.completeError(
              TimeoutException(
                'No events received for $timeoutSeconds seconds',
              ),
            );
          }
        });

        if (event is ConfigCompleteEvent) {
          activityTimer?.cancel();
          if (!configCompleter.isCompleted) {
            configCompleter.complete();
          }
        }
      });

      // Start the initial activity timer
      activityTimer = Timer(timeoutDuration, () {
        if (!configCompleter.isCompleted) {
          configCompleter.completeError(
            TimeoutException('No events received for $timeoutSeconds seconds'),
          );
        }
      });

      await client.connect();
      entry.client = client;

      // Wait for config to complete or timeout based on inactivity
      try {
        _log(
          id,
          'Waiting for ConfigCompleteEvent (timeout: ${timeoutSeconds}s)...',
        );
        await configCompleter.future;
        _log(id, 'ConfigCompleteEvent received');
      } catch (e) {
        _log(
          id,
          'Timed out waiting for ConfigCompleteEvent (no activity for ${timeoutSeconds}s), proceeding anyway',
          level: 'warn',
        );
      } finally {
        activityTimer?.cancel();
        configSub.cancel();
        bondStateSub?.cancel();
      }

      // Begin listening for OS/device connection state changes
      entry._listenConnectionState();
      entry._update(DeviceConnectionState.connected);
      entry._subscribeClientRssi();
      _connectedDevicesController.add(connectedDevices);
      _log(id, 'Connected');

      // Add to recent devices list ONLY if pairing didn't fail
      if (!pairingFailureDetected) {
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
      } else {
        _log(
          id,
          'Pairing failure detected, not adding to recent devices',
          level: 'warn',
        );
      }

      completer.complete(client);
      return client;
    } catch (e) {
      // If we failed to connect, we should probably disconnect to clean up
      try {
        await bondStateSub?.cancel(); // Ensure cleanup on error
      } catch (_) {}
      try {
        await entry.client?.dispose();
      } catch (_) {}
      entry.client = null;

      Object error = e;
      // Check for common "device not found" errors from flutter_blue_plus
      // Android: "Device not found"
      // iOS: might differ, but "Device not found" is a good catch-all heuristic for now
      if (e.toString().contains("Device not found")) {
        error = ScanRequiredException();
      }

      entry._update(DeviceConnectionState.error, error: error);
      entry._scheduleErrorRemoval();
      _connectedDevicesController.add(connectedDevices);
      _log(id, 'Connect failed: $error', level: 'error');
      completer.completeError(error);
      throw error;
    } finally {
      entry.connecting = null;
    }
  }

  Future<MeshtasticClient> connectIp(String host, int port) async {
    final deviceId =
        'IP:$host:$port'; // Temporary ID until we get real one from config
    final entry = _entries.putIfAbsent(deviceId, () => _Entry.ip(deviceId));
    // Store IP device name
    entry.deviceName = '$host:$port';

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

      entry.deviceType =
          DeviceType.meshtastic; // IP clients are Meshtastic for now

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
    // Store USB device name
    entry.deviceName = portName;

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

      entry.deviceType =
          DeviceType.meshtastic; // USB clients are Meshtastic for now

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

  Future<MeshtasticClient> connectSimulation() async {
    if (!kDebugMode && !const bool.fromEnvironment('ENABLE_SIMULATION')) {
      throw Exception('Simulation not enabled in this build');
    }
    const deviceId = 'SIM-DEVICE-001';
    final entry = _entries.putIfAbsent(
      deviceId,
      () => _Entry.simulation(deviceId),
    );
    entry.deviceName = 'Simulation Device';

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
      final client = SimulationMeshtasticDevice();
      entry.deviceType = DeviceType.meshtastic;
      await client.connect();
      entry.client = client;

      entry._update(DeviceConnectionState.connected);
      entry._subscribeClientRssi();
      _log(deviceId, 'Connected via Simulation');

      // Add to recent devices list so it appears in the UI
      final scanResult = ScanResult(
        device: BluetoothDevice(remoteId: DeviceIdentifier(deviceId)),
        advertisementData: AdvertisementData(
          advName: 'Simulation Device',
          txPowerLevel: null,
          connectable: true,
          manufacturerData: {},
          serviceData: {},
          serviceUuids: [],
          appearance: null,
        ),
        rssi: -50,
        timeStamp: DateTime.now(),
      );
      await RecentDevicesService.instance.add(scanResult);

      completer.complete(client);
      return client;
    } catch (e) {
      try {
        await entry.client?.dispose();
      } catch (_) {}
      entry.client = null;
      entry._update(DeviceConnectionState.error, error: e);
      entry._scheduleErrorRemoval();
      _log(deviceId, 'Connect Simulation failed: $e', level: 'error');
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
  ///
  /// [userInitiated] - If true, marks this as a user-initiated disconnect,
  /// which will prevent automatic reconnection attempts.
  Future<void> disconnect(String deviceId, {bool userInitiated = true}) async {
    final entry = _entries[deviceId];
    if (entry == null) return;

    // Mark as user disconnect to prevent auto-reconnect
    if (userInitiated) {
      entry._userDisconnect = true;
    }

    // Cancel any pending reconnection attempts
    entry._cancelReconnection();

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
      } else if (entry.device != null) {
        // If we don't have a client yet (e.g. still connecting), disconnect the raw device
        // This stops the connection attempt if it's in the "connecting" state at the BLE level
        try {
          // Check if we are actually connected or connecting before calling disconnect
          // to avoid unnecessary errors, although disconnect() is usually idempotent-ish safe.
          // Note: connectionState might be useful but sometimes async disconnect is safer to just call.
          _log(deviceId, 'Cancelling/Disconnecting raw BLE device...');
          await entry.device!.disconnect();
        } catch (e) {
          _log(deviceId, 'Error disconnecting raw device: $e', level: 'warn');
        }
      }

      entry._unsubscribeClientRssi();
      await entry.connStateSub?.cancel();
    } catch (_) {}
    try {
      await entry.client?.dispose();
    } catch (_) {}
    entry.client = null;
    entry.connecting = null; // Clear any pending connection future
    entry._update(DeviceConnectionState.disconnected);
    _connectedDevicesController.add(connectedDevices);
    _log(deviceId, 'Disconnected');
  }

  /// Obtain the latest status synchronously if present.
  DeviceStatus? statusNow(String deviceId) => _entries[deviceId]?.status;

  /// Get the stored device name for a given device ID.
  String? getDeviceName(String deviceId) => _entries[deviceId]?.deviceName;

  /// Get the stored device type for a given device ID.
  DeviceType? getDeviceType(String deviceId) => _entries[deviceId]?.deviceType;

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

  /// Returns all connected device IDs (including BLE, IP, and USB).
  List<String> get connectedDeviceIds {
    return _entries.entries
        .where((e) => e.value.status?.state == DeviceConnectionState.connected)
        .map((e) => e.key)
        .toList();
  }

  /// Get the MeshtasticClient for a given device ID.
  MeshtasticClient? getClient(String deviceId) => _entries[deviceId]?.client;

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
    final entry = instance._entries[deviceId];
    // Default to meshtastic if unknown, or use the stored device type
    final network = entry?.deviceType?.name ?? 'meshtastic';

    LoggingService.instance.push(
      tags: {
        'network': network,
        'deviceId': deviceId,
        'class': 'DeviceStatusStore',
      },
      level: level,
      message: '[DeviceStatusStore] $msg',
    );
  }
}

class _Entry {
  final String deviceId;
  BluetoothDevice? device; // Nullable for IP/USB devices
  MeshtasticClient? client;
  DeviceType? deviceType; // Track the protocol type

  Future<MeshtasticClient>? connecting;
  final StreamController<DeviceStatus> controller =
      StreamController<DeviceStatus>.broadcast();
  DeviceStatus? status;
  StreamSubscription<BluetoothConnectionState>? connStateSub;
  // Subscription to client's RSSI stream
  StreamSubscription<int>? _clientRssiSub;
  Timer? _errorRemovalTimer;
  // Stored device name for display
  String? deviceName;
  // Reconnection tracking
  bool _userDisconnect = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;

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

  _Entry.simulation(this.deviceId)
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
      deviceType: deviceType,
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
    if (device == null) {
      return; // IP/USB devices don't have OS-level connection state stream yet
    }
    connStateSub = device!.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        // Update status and notify services so UI can reflect and users can see it.
        _unsubscribeClientRssi();
        _update(DeviceConnectionState.disconnected);
        DeviceStatusStore.instance._connectedDevicesController.add(
          DeviceStatusStore.instance.connectedDevices,
        );
        DeviceStatusStore._log(deviceId, 'Disconnected (device event)');

        // Determine if we should attempt auto-reconnect
        final settings = SettingsService.instance.current;
        final shouldReconnect =
            !_userDisconnect && (settings?.autoReconnectEnabled ?? true);

        if (shouldReconnect) {
          DeviceStatusStore._log(
            deviceId,
            'Unexpected disconnect detected, will attempt reconnection',
          );
          _attemptReconnection();
        } else {
          DeviceStatusStore._log(
            deviceId,
            'User-initiated disconnect or auto-reconnect disabled, not reconnecting',
          );
          // Push a lightweight device communication event for user-visible notification
          try {
            DeviceCommunicationEventService.instance.push(
              tags: {
                'network': deviceType?.name ?? 'meshtastic',
                'deviceId': deviceId,
                'class': 'DeviceStatusStore',
              },
              summary: 'Device disconnected',
            );
          } catch (_) {}
        }
      }
    });
  }

  /// Attempt to reconnect to the device with exponential backoff.
  Future<void> _attemptReconnection() async {
    // Cancel any existing reconnection timer
    _reconnectTimer?.cancel();

    final settings = SettingsService.instance.current;
    final maxAttempts = settings?.maxReconnectAttempts ?? 3;
    final baseDelay = settings?.reconnectBaseDelaySeconds ?? 1;

    if (_reconnectAttempts >= maxAttempts) {
      DeviceStatusStore._log(
        deviceId,
        'Max reconnection attempts ($maxAttempts) reached, giving up',
        level: 'warn',
      );
      _reconnectAttempts = 0;
      // Notify user that reconnection failed
      try {
        DeviceCommunicationEventService.instance.push(
          tags: {
            'network': deviceType?.name ?? 'meshtastic',
            'deviceId': deviceId,
            'class': 'DeviceStatusStore',
          },
          summary: 'Reconnection failed after $maxAttempts attempts',
        );
      } catch (_) {}
      return;
    }

    _reconnectAttempts++;
    final delaySeconds = baseDelay * (1 << (_reconnectAttempts - 1));
    final delay = Duration(seconds: delaySeconds);

    DeviceStatusStore._log(
      deviceId,
      'Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s',
    );

    // Notify user about reconnection attempt via event service
    try {
      DeviceCommunicationEventService.instance.push(
        tags: {
          'network': deviceType?.name ?? 'meshtastic',
          'deviceId': deviceId,
          'class': 'DeviceStatusStore',
        },
        summary:
            'Reconnecting in ${delay.inSeconds}s (Attempt $_reconnectAttempts)',
      );
    } catch (_) {}

    _reconnectTimer = Timer(delay, () async {
      DeviceStatusStore._log(
        deviceId,
        'Executing reconnection attempt $_reconnectAttempts',
      );
      if (device != null) {
        try {
          await DeviceStatusStore.instance.connect(device!);
        } catch (e) {
          DeviceStatusStore._log(
            deviceId,
            'Reconnection attempt $_reconnectAttempts failed: $e',
            level: 'warn',
          );
          // Recursively schedule next attempt if we failed
          _attemptReconnection();
        }
      }
    });
  }

  void _cancelReconnection() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
  }

  void _subscribeClientRssi() {
    _unsubscribeClientRssi();
    // Forward client RSSI updates to our subject
    if (client != null) {
      _clientRssiSub = client!.rssi.listen((rssi) {
        // Update just the RSSI without changing state
        _update(status!.state, rssi: rssi);
      });
    }
  }

  void _unsubscribeClientRssi() {
    _clientRssiSub?.cancel();
    _clientRssiSub = null;
  }
}
