import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:collection';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../meshtastic/model/device_type.dart';
import '../meshtastic/model/meshcore_constants.dart';
import '../meshtastic/model/meshcore_packet.dart';
import '../meshtastic/model/meshcore_channel.dart';
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';
import 'meshtastic_client.dart';
import 'device_communication_event_service.dart';

/// MeshCore Bluetooth Low Energy Client
///
/// Implements the MeshCore protocol using Nordic UART Service for BLE communication.
/// Uses frame-based queuing with binary packet protocol.
class MeshCoreBleClient extends MeshtasticClient {
  final BluetoothDevice device;

  // BLE Characteristics
  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;

  // Frame queues
  final Queue<MeshCoreFrame> _sendQueue = Queue();
  final Queue<MeshCoreFrame> _recvQueue = Queue();

  // Subscriptions
  StreamSubscription<BluetoothConnectionState>? _connStateSub;
  StreamSubscription<List<int>>? _txNotifySub;

  // Write throttling
  DateTime? _lastWriteTime;
  Timer? _writeTimer;

  // Connection state
  bool _isConnected = false;
  bool _disposed = false;

  // Stream controllers for events and RSSI
  final _eventsController = StreamController<MeshtasticEvent>.broadcast();
  final _rssiController = StreamController<int>.broadcast();

  // Channel state
  final List<MeshCoreChannel> _channels = [];
  Completer<MeshCoreChannel>? _channelQueryCompleter;

  @override
  DeviceType get deviceType => DeviceType.meshcore;

  @override
  Stream<MeshtasticEvent> get events => _eventsController.stream;

  @override
  Stream<int> get rssi => _rssiController.stream;

  /// Get all cached channels
  List<MeshCoreChannel> get channels => List.unmodifiable(_channels);

  MeshCoreBleClient(this.device);

  void _log(String message, {String level = 'info'}) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint(
      '[$timestamp] MeshCoreBleClient[${device.remoteId.str}] $level: $message',
    );
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('MeshCoreBleClient has been disposed');
    }
  }

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 20)}) async {
    _ensureNotDisposed();
    _log('Connecting to ${device.remoteId.str}...');

    // Check if already connected at OS level
    var isConnected = false;
    try {
      final connectedDevices = await FlutterBluePlus.systemDevices([]);
      if (connectedDevices.any((d) => d.remoteId == device.remoteId)) {
        isConnected = true;
        _log('Device is already connected at OS level');
      }
    } catch (e) {
      _log('Error checking system devices: $e', level: 'warn');
    }

    // Connect if not already connected
    if (!isConnected) {
      _log('Initiating BLE connection...');
      await device.connect(
        timeout: timeout,
        autoConnect: false,
        license: License.free,
      );
      _log('BLE connection established');
    }

    // Discover services and bind characteristics
    try {
      _log('Discovering services...');
      await _discoverAndBindCharacteristics();
      _isConnected = true; // Ensure we are marked as connected before handshake
      _log('Service discovery complete');
    } catch (e) {
      _log('Service discovery failed: $e', level: 'error');
      rethrow;
    }

    // Start listening for connection state changes
    _connStateSub?.cancel();
    _connStateSub = device.connectionState.listen((state) {
      _log('Connection state changed: $state');
      if (state == BluetoothConnectionState.disconnected) {
        _isConnected = false;
        _stopWriteTimer();
        try {
          _txNotifySub?.cancel();
        } catch (_) {}
      } else if (state == BluetoothConnectionState.connected) {
        _isConnected = true;
      }
    });

    _log('MeshCore client connected and ready');

    // Perform handshake to initialize session
    await _performHandshake();
  }

  Future<void> _discoverAndBindCharacteristics() async {
    _log('Discovering services...');
    final services = await device.discoverServices();

    BluetoothService? targetService;
    for (final s in services) {
      if (s.uuid.str.toLowerCase() == MeshCoreConstants.serviceUuid) {
        targetService = s;
        break;
      }
    }

    if (targetService == null) {
      _log(
        'MeshCore service not found: ${MeshCoreConstants.serviceUuid}',
        level: 'error',
      );
      throw StateError(
        'MeshCore service not found: ${MeshCoreConstants.serviceUuid}',
      );
    }

    _log('Found MeshCore service, binding characteristics...');

    for (final c in targetService.characteristics) {
      final id = c.uuid.str.toLowerCase();
      if (id == MeshCoreConstants.rxCharacteristicUuid) {
        _rxCharacteristic = c;
        _log('Bound RX characteristic');
      } else if (id == MeshCoreConstants.txCharacteristicUuid) {
        _txCharacteristic = c;
        _log('Bound TX characteristic');
      }
    }

    if (_rxCharacteristic == null || _txCharacteristic == null) {
      _log('Missing required characteristics', level: 'error');
      throw StateError('Missing RX or TX characteristics');
    }

    // Subscribe to TX notifications (data from device)
    _txNotifySub?.cancel();
    _txNotifySub = _txCharacteristic!.onValueReceived.listen((value) {
      _log('RX frame received: ${value.length} bytes');
      _onFrameReceived(Uint8List.fromList(value));
    });

    try {
      await _txCharacteristic!.setNotifyValue(true);
      _log('Subscribed to TX notifications');
    } catch (e) {
      _log('Failed to enable notifications on TX: $e', level: 'error');
      rethrow;
    }

    // Start write processing timer
    _startWriteTimer();
  }

  void _onFrameReceived(Uint8List frameData) {
    _ensureNotDisposed();

    // Check for handshake responses (Command Protocol)
    if (frameData.isNotEmpty) {
      final cmd = frameData[0];
      if (cmd == MeshCoreConstants.respDeviceInfo) {
        _log('Received RESP_DEVICE_INFO');

        // Parse MyInfo
        final myInfo = MyInfoDto(
          myNodeNum: 0, // Mock, extracted if payload available
          firmwareEdition: 'MeshCore',
        );
        _emitEvent(MyInfoEvent(myInfo));

        if (_deviceQueryCompleter != null &&
            !_deviceQueryCompleter!.isCompleted) {
          _deviceQueryCompleter!.complete();
          return; // Don't process as mesh packet
        }
      } else if (cmd == MeshCoreConstants.respCodeChannelInfo) {
        _log('Received RESP_CHANNEL_INFO');

        try {
          final channel = MeshCoreChannel.fromBytes(frameData);
          _log('Parsed channel: $channel');

          // Update channel cache
          final existingIndex = _channels.indexWhere(
            (c) => c.index == channel.index,
          );
          if (existingIndex != -1) {
            _channels[existingIndex] = channel;
          } else {
            _channels.add(channel);
          }

          // Emit channel event
          final channelDto = ChannelDto(
            index: channel.index,
            role: 'PRIMARY', // MeshCore doesn't have role concept, use default
            settings: ChannelSettingsDto(
              name: channel.name,
              psk: channel.psk,
              channelNum: channel.index,
            ),
          );
          _emitEvent(ChannelEvent(channelDto));

          // Complete channel query if waiting
          if (_channelQueryCompleter != null &&
              !_channelQueryCompleter!.isCompleted) {
            _channelQueryCompleter!.complete(channel);
          }

          return; // Don't process as mesh packet
        } catch (e) {
          _log('Failed to parse RESP_CHANNEL_INFO: $e', level: 'error');
        }
      } else if (cmd == MeshCoreConstants.respSelfInfo) {
        _log('Received RESP_SELF_INFO');

        var nodeId = 0;
        var longName = 'MeshCore Device';
        var shortName = 'MSHC';

        try {
          // Parse RESP_SELF_INFO payload
          // Byte 0: CMD (0x05)
          // Byte 1: AdvType
          // Byte 2: TxPower
          // Byte 3: MaxPower
          // Byte 4..35: PubKey (32 bytes)
          // Byte 36..39: Lat
          // Byte 40..43: Lon
          // Byte 44: MultiAcks
          // Byte 45: LocPolicy
          // Byte 46: TelemetryModes
          // Byte 47: ManualAddContacts
          // Byte 48..51: Freq
          // Byte 52..55: BW
          // Byte 56: SF
          // Byte 57: CR
          // Byte 58..: Node Name

          const pubKeyStart = 4;
          const pubKeyLen = 32; // Assuming PUB_KEY_SIZE = 32
          const pubKeyEnd = pubKeyStart + pubKeyLen;

          if (frameData.length > pubKeyEnd) {
            final pubKey = frameData.sublist(pubKeyStart, pubKeyEnd);
            // Use first 4 bytes of PubKey as Node ID (MeshCore convention)
            final idBytes = pubKey.sublist(0, 4);
            nodeId = ByteData.sublistView(idBytes).getUint32(0, Endian.little);
            shortName = 'MSHC_${nodeId.toRadixString(16)}';
          }

          const nodeNameStart = 58;
          if (frameData.length > nodeNameStart) {
            try {
              // Assuming remaining bytes are the string
              final nameBytes = frameData.sublist(nodeNameStart);
              // Remove null terminator if present
              final len = nameBytes.indexWhere((b) => b == 0);
              final actualBytes = len != -1
                  ? nameBytes.sublist(0, len)
                  : nameBytes;
              longName = String.fromCharCodes(actualBytes);
            } catch (e) {
              _log('Error parsing node name: $e', level: 'warn');
            }
          }
        } catch (e) {
          _log('Error parsing RESP_SELF_INFO structure: $e', level: 'error');
        }

        // Parse NodeInfo
        final nodeInfo = NodeInfoDto(
          num: nodeId,
          user: UserDto(
            id: '!${nodeId.toRadixString(16)}',
            longName: longName,
            shortName: shortName,
            hwModel: 'MeshCore',
          ),
          lastHeard: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
        _emitEvent(NodeInfoEvent(nodeInfo));

        // Parse LoRa Config
        // Payload structure (offsets including cmd byte):
        // [0] CMD (5)
        // [1] ADV_TYPE
        // [2] TX_POWER
        // [3] MAX_TX_POWER
        // [4..35] PUB_KEY (32 bytes)
        // [36..39] LAT
        // [40..43] LON
        // [44] MULTI_ACKS
        // [45] ADV_LOC_POLICY
        // [46] TELEMETRY_MODE
        // [47] MANUAL_ADD_CONTACTS
        // [48..51] FREQ (uint32 * 1000)
        // [52..55] BW (uint32 * 1000)
        // [56] SF
        // [57] CR

        try {
          if (frameData.length >= 58) {
            final txPower = frameData[2];

            // Offsets based on 32-byte public key
            final freqBytes = frameData.sublist(48, 52);
            final bwBytes = frameData.sublist(52, 56);

            final freqInt = ByteData.sublistView(
              freqBytes,
            ).getUint32(0, Endian.little);
            final bwInt = ByteData.sublistView(
              bwBytes,
            ).getUint32(0, Endian.little);

            final sf = frameData[56];
            final cr = frameData[57];

            // Convert to Meshtastic units/format
            // Freq: sent as freq*1000 (kHz? no, float freq*1000 usually means MHz*1000 = kHz, or Hz/1000?)
            // Code says: uint32_t freq = _prefs.freq * 1000; where _prefs.freq is float.
            // If _prefs.freq is MHz (e.g. 915.0), then freq is 915000.
            // LoRaConfigDto expects what? Currently unused, but usually Hz or MHz.
            // Let's assume we want to store it primarily for display.
            // wait, DeviceStateWidget usually relies on `region` or `channel settings`.
            // But we can repurpose LoRaConfigDto fields.

            final loraConfig = LoRaConfigDto(
              txPower: txPower,
              spreadFactor: sf,
              codingRate: cr,
              bandwidth: bwInt / 1000.0, // Convert Hz to kHz (decimal)
              overrideFrequency: freqInt / 1000.0, // MHz
              // Using region field to store "Custom" or similar if needed,
              // but we are setting explicit params.
              usePreset: false,
            );

            _emitEvent(ConfigEvent(ConfigDto(lora: loraConfig)));
            _log(
              'Parsed LoRa config: SF=$sf, CR=$cr, BW=$bwInt, Freq=$freqInt, Pwr=$txPower',
            );
          }
        } catch (e) {
          _log(
            'Error parsing LoRa config from RESP_SELF_INFO: $e',
            level: 'warn',
          );
        }

        if (_appStartCompleter != null && !_appStartCompleter!.isCompleted) {
          _appStartCompleter!.complete();
          return; // Don't process as mesh packet
        }
      }
    }

    if (frameData.length > MeshCoreConstants.maxFrameSize) {
      _log(
        'Frame too large: ${frameData.length} > ${MeshCoreConstants.maxFrameSize}',
        level: 'warn',
      );
      return;
    }

    if (_recvQueue.length >= MeshCoreConstants.frameQueueSize) {
      _log('Receive queue full, dropping frame', level: 'warn');
      return;
    }

    _recvQueue.add(MeshCoreFrame(frameData));
    _log('Frame queued for processing (queue size: ${_recvQueue.length})');

    // Process frames immediately
    _processReceivedFrames();
  }

  void _processReceivedFrames() {
    while (_recvQueue.isNotEmpty) {
      final frame = _recvQueue.removeFirst();

      // Log hex dump for all frames to help debug parsing issues
      final hexDump = frame.data
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ');
      _log('Processing frame: ${frame.data.length} bytes, hex: $hexDump');

      // Handle short frames (Command Responses)
      // A valid MeshPacket is at least 2 bytes (Header + PathLen), but usually more.
      // Command responses like '1' (Success) or error codes are 1-2 bytes.
      if (frame.data.length < 3) {
        _log('Identified as command response/short frame (< 3 bytes)');

        // Parse and emit command response event
        final responseCode = frame.data[0];
        final additionalData = frame.data.length > 1
            ? frame.data.sublist(1)
            : null;

        final responseDesc = MeshCoreConstants.getResponseCodeDescription(
          responseCode,
        );
        _log(
          'Command response: $responseDesc (0x${responseCode.toRadixString(16).padLeft(2, '0')})',
        );

        final event = MeshCoreCommandResponseEvent(
          responseCode: responseCode,
          additionalData: additionalData,
        );

        _emitEvent(event);
        continue;
      }

      try {
        final packet = MeshCorePacket.fromBytes(frame.data);
        _log('Successfully parsed packet: $packet');
        _handlePacket(packet);
      } catch (e) {
        _log(
          'Failed to parse frame as MeshCore packet: $e\n'
          'Frame may be a non-mesh protocol message or malformed packet.',
          level: 'warn',
        );
      }
    }
  }

  void _handlePacket(MeshCorePacket packet) {
    switch (packet.header.payloadType) {
      case MeshCoreConstants.payloadTypeTxtMsg:
        _handleTextMessage(packet);
        break;
      case MeshCoreConstants.payloadTypeAdvert:
        _handleNodeAdvert(packet);
        break;
      case MeshCoreConstants.payloadTypeAck:
        _log('Received ACK packet');
        break;
      default:
        _log(
          'Unhandled payload type: ${packet.header.payloadType}',
          level: 'warn',
        );
    }
  }

  void _handleTextMessage(MeshCorePacket packet) {
    try {
      final textMsg = MeshCoreTextMessage.fromPayload(packet.payload);
      _log('Received text message: ${textMsg.message}');

      int sender = 0;
      int destination = 0;
      if (packet.path.isNotEmpty) {
        sender = packet.path.first; // Naive: assume first byte is sender
        if (packet.path.length > 1) {
          destination = packet.path.last;
        }
      }

      // Map to MeshPacketEvent (TextPayload)
      final meshPacket = MeshPacketDto(
        from: sender,
        to: destination,
        rxTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        decoded: TextPayloadDto(textMsg.message),
      );

      final event = MeshPacketEvent(
        packet: meshPacket,
        decoded: meshPacket.decoded!,
      );

      _emitEvent(event);
    } catch (e) {
      _log('Failed to parse text message: $e', level: 'error');
    }
  }

  void _handleNodeAdvert(MeshCorePacket packet) {
    _log('Received node advertisement (${packet.payload.length} bytes)');

    int sender = 0;
    if (packet.path.isNotEmpty) {
      sender = packet.path.first;
    }

    final nodeInfo = NodeInfoDto(
      num: sender,
      user: UserDto(
        id: '!${sender.toRadixString(16)}',
        shortName: 'MeshCore_${sender.toRadixString(16)}',
        longName: 'MeshCore Device $sender',
      ),
      lastHeard: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      snr: 10.0,
    );

    _emitEvent(NodeInfoEvent(nodeInfo));
  }

  void _emitEvent(MeshtasticEvent event) {
    _eventsController.add(event);
    DeviceCommunicationEventService.instance.pushMeshtastic(
      event: event,
      deviceId: device.remoteId.str,
      summary: event.runtimeType.toString(),
    );
  }

  /// Send a text message
  Future<void> sendTextMessage(String message, {String? destinationId}) async {
    _ensureNotDisposed();

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final textMsg = MeshCoreTextMessage(
      timestamp: timestamp,
      txtType: MeshCoreConstants.txtTypePlain,
      attempt: 0,
      message: message,
    );

    final packet = MeshCorePacket(
      header: MeshCorePacketHeader(
        routeType: MeshCoreConstants.routeTypeFlood, // Use flood for now
        payloadType: MeshCoreConstants.payloadTypeTxtMsg,
        payloadVersion: MeshCoreConstants.payloadVersion1,
      ),
      path: Uint8List(0), // Empty path for flood
      payload: textMsg.toPayload(),
    );

    await _writeFrame(packet.toBytes());
    _log('Queued text message for sending: "$message"');
  }

  // --- Handshake Implementation ---

  // Completers for handshake responses
  Completer<void>? _deviceQueryCompleter;
  Completer<void>? _appStartCompleter;

  Future<void> _performHandshake() async {
    _log('Starting MeshCore handshake...');
    try {
      // 1. Send CMD_DEVICE_QUERY
      _deviceQueryCompleter = Completer<void>();
      await _sendDeviceQuery();
      _log('Sent CMD_DEVICE_QUERY, waiting for response...');
      await _deviceQueryCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _log('Timeout waiting for RESP_DEVICE_INFO', level: 'warn');
          // proceed anyway?
        },
      );

      // 2. Send CMD_APP_START
      _appStartCompleter = Completer<void>();
      await _sendAppStart();
      _log('Sent CMD_APP_START, waiting for response...');
      await _appStartCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _log('Timeout waiting for RESP_SELF_INFO', level: 'warn');
        },
      );

      _log('Handshake complete');

      // Emit ConfigCompleteEvent to notify UI
      final configEvent = ConfigCompleteEvent(0); // 0 = dummy ID
      _eventsController.add(configEvent);
      DeviceCommunicationEventService.instance.pushMeshtastic(
        event: configEvent,
        deviceId: device.remoteId.str,
        summary: 'ConfigCompleteEvent',
      );
    } catch (e) {
      _log('Handshake failed: $e', level: 'error');
      // We might want to rethrow, but for now let's allow connection to proceed
      // so we can at least debug with basic connectivity if possible.
    } finally {
      _deviceQueryCompleter = null;
      _appStartCompleter = null;
    }
  }

  Future<void> _sendDeviceQuery() async {
    // CMD_DEVICE_QUERY (22) + Protocol Version (1)
    final payload = Uint8List.fromList([
      MeshCoreConstants.cmdDeviceQuery,
      1, // Protocol version we understand
    ]);
    await _writeRaw(payload);
  }

  Future<void> _sendAppStart() async {
    // CMD_APP_START (1) + reserved(7) + AppName
    // We'll use "MeshApp" as app name
    final appName = 'MeshApp';
    final payload = BytesBuilder();
    payload.addByte(MeshCoreConstants.cmdAppStart);
    payload.add(Uint8List(7)); // 7 reserved bytes (0)
    payload.add(appName.codeUnits);
    payload.addByte(0); // null terminator for string

    await _writeRaw(payload.toBytes());
  }

  /// Write raw bytes directly to characteristic (omitting MeshCoreFrame queue if high priority)
  /// But `_writeFrame` queues it. Handshake commands should probably use the queue
  /// to ensure order, or bypass if queue is for "Mesh Packets" only.
  /// For now, reusing _writeFrame logic but exposing a raw write helper.
  Future<void> _writeRaw(Uint8List data) async {
    await _writeFrame(data);
  }

  // --- End Handshake Implementation ---

  Future<void> _writeFrame(Uint8List frameData) async {
    _ensureNotDisposed();

    if (frameData.length > MeshCoreConstants.maxFrameSize) {
      throw ArgumentError(
        'Frame exceeds max size: ${frameData.length} > ${MeshCoreConstants.maxFrameSize}',
      );
    }

    if (!_isConnected) {
      throw StateError('Device not connected');
    }

    if (_sendQueue.length >= MeshCoreConstants.frameQueueSize) {
      throw StateError('Send queue full');
    }

    _sendQueue.add(MeshCoreFrame(frameData));
    _log('Frame queued for sending (queue size: ${_sendQueue.length})');
  }

  void _startWriteTimer() {
    _writeTimer?.cancel();
    _writeTimer = Timer.periodic(
      Duration(milliseconds: MeshCoreConstants.bleWriteMinIntervalMs),
      (_) => _processWrites(),
    );
  }

  void _stopWriteTimer() {
    _writeTimer?.cancel();
    _writeTimer = null;
  }

  Future<void> _processWrites() async {
    if (_disposed || !_isConnected || _sendQueue.isEmpty) {
      return;
    }

    // Throttle writes to respect BLE_WRITE_MIN_INTERVAL
    final now = DateTime.now();
    if (_lastWriteTime != null) {
      final elapsed = now.difference(_lastWriteTime!).inMilliseconds;
      if (elapsed < MeshCoreConstants.bleWriteMinIntervalMs) {
        return;
      }
    }

    final frame = _sendQueue.removeFirst();
    try {
      await _rxCharacteristic!.write(frame.data, withoutResponse: false);
      _lastWriteTime = now;
      _log(
        'Sent frame: ${frame.length} bytes (${_sendQueue.length} remaining in queue)',
      );
    } catch (e) {
      _log('Failed to write frame: $e', level: 'error');
      // Re-queue on failure?
      // _sendQueue.addFirst(frame);
    }
  }

  @override
  Future<void> disconnect() async {
    _log('Disconnecting...');

    _stopWriteTimer();
    await _connStateSub?.cancel();
    await _txNotifySub?.cancel();

    try {
      await device.disconnect();
    } catch (e) {
      _log('Error during disconnect: $e', level: 'warn');
    }

    _isConnected = false;
    _log('Disconnected');
  }

  // MeshtasticClient protobuf methods - not directly applicable to MeshCore
  @override
  Future<void> sendToRadio(mesh.ToRadio message) async {
    _log(
      'sendToRadio() - MeshCore uses binary protocol, not protobuf',
      level: 'warn',
    );
    throw UnsupportedError(
      'MeshCore does not support protobuf ToRadio messages',
    );
  }

  @override
  Future<void> sendMeshPacket(mesh.MeshPacket packet) async {
    _log(
      'sendMeshPacket() - MeshCore uses binary protocol, not protobuf',
      level: 'warn',
    );
    throw UnsupportedError('MeshCore does not support protobuf MeshPacket');
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;

    _log('Disposing MeshCoreBleClient');
    _disposed = true;

    _stopWriteTimer();
    await _connStateSub?.cancel();
    await _txNotifySub?.cancel();

    _sendQueue.clear();
    _recvQueue.clear();

    await _eventsController.close();
    _rssiController.close();
  }

  // MeshtasticClient interface - not all methods applicable to MeshCore

  @override
  Future<void> requestConfig() async {
    // MeshCore doesn't have protobuf-style config requests
    // Configuration might be done via binary request packets
    _log('requestConfig() - not implemented for MeshCore', level: 'warn');
  }

  @override
  Future<void> requestSessionKey(int? nodeId) async {
    // MeshCore uses different encryption model
    _log('requestSessionKey() - not implemented for MeshCore', level: 'warn');
  }

  @override
  Future<void> setOwner({
    String? longName,
    String? shortName,
    bool? isLicensed,
    bool? isUnmessagable,
    Uint8List? sessionPasskey,
    int? nodeId,
  }) async {
    _log('setOwner(longName: $longName) - MeshCore');

    if (shortName != null || isLicensed != null || isUnmessagable != null) {
      _log(
        'Warning: shortName, isLicensed, and isUnmessagable are not supported by the MeshCore protocol.',
        level: 'warn',
      );
    }

    if (longName == null) {
      _log('setOwner: longName is null, nothing to do.', level: 'warn');
      return;
    }

    // CMD_SET_ADVERT_NAME (0x08)
    // Payload: [CMD][Name String][Null Terminator]
    final payload = BytesBuilder();
    payload.addByte(MeshCoreConstants.cmdSetAdvertName);
    payload.add(longName.codeUnits);
    payload.addByte(0); // Null terminator

    try {
      await _writeRaw(payload.toBytes());
      _log('Sent CMD_SET_ADVERT_NAME: "$longName"');
    } catch (e) {
      _log('Failed to send setOwner command: $e', level: 'error');
      rethrow;
    }
  }

  @override
  Future<void> sendModuleConfig(
    config, {
    Uint8List? sessionPasskey,
    int? nodeId,
  }) async {
    _log('sendModuleConfig() - not implemented for MeshCore', level: 'warn');
  }

  Future<void> sendMessage(
    String message, {
    required int destinationId,
    int channelIndex = 0,
  }) async {
    _ensureNotDisposed();

    if (channelIndex == 0) {
      // Channel 0 (default/primary) - send as channel message
      // For now, use a basic implementation without querying the channel
      // The device should have a default "Primary" channel at index 0
      await _sendChannelMessage(message, channelIndex: channelIndex);
    } else {
      // Non-default channel - also send as channel message
      await _sendChannelMessage(message, channelIndex: channelIndex);
    }
  }

  /// Send a message to a channel using PAYLOAD_TYPE_GRP_TXT
  Future<void> _sendChannelMessage(
    String message, {
    required int channelIndex,
  }) async {
    _ensureNotDisposed();

    // For MeshCore companion protocol, we need to build a proper packet
    //  However, the companion interface might not support sending raw mesh packets
    // Looking at the error (0x01), it seems the device rejects our packet format
    //
    // The issue is likely that:
    // 1. We're sending raw mesh packets when we should use a command
    // 2. OR we need proper encryption that we can't do client-side
    //
    // For now, let's try using direct text message format but see if we get
    // a different error. The real solution might require using a different
    // approach entirely.

    // Actually, looking at the constants again, there's no CMD_SEND_MESSAGE
    // This means messages are likely sent as raw mesh packets.
    // The problem is we're using the wrong payload type.

    // Let's try creating a proper group text packet
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Get device name for "name: message" format
    //  We don't have it readily available, so use a placeholder
    final senderName = 'User'; // TODO: Get from device state

    final groupMsg = MeshCoreGroupTextMessage(
      timestamp: timestamp,
      senderName: senderName,
      message: message,
    );

    // Calculate channel hash
    // For channel 0, typically named "Primary"
    final channelName = channelIndex == 0 ? 'Primary' : 'Channel$channelIndex';
    final channelHash = calculateChannelHash(channelName);

    // Create packet payload
    // Format for PAYLOAD_TYPE_GRP_TXT:
    // channel_hash (1 byte) | MAC (2 bytes) | encrypted_data
    //
    // Problem: We can't do encryption here without the channel PSK
    // and crypto library support
    //
    // Let's try sending without encryption as a test
    // The device might reject it, but it will help us understand the protocol

    final buffer = BytesBuilder();
    buffer.addByte(channelHash);

    // Add MAC placeholder (2 bytes of zeros for now - will likely fail)
    buffer.add(Uint8List(2)); // MAC = 0x00 0x00

    // Add "encrypted" payload (unencrypted for testing)
    buffer.add(groupMsg.toPayload());

    final packet = MeshCorePacket(
      header: MeshCorePacketHeader(
        routeType: MeshCoreConstants.routeTypeFlood,
        payloadType: MeshCoreConstants.payloadTypeGrpTxt, // Use group text!
        payloadVersion: MeshCoreConstants.payloadVersion1,
      ),
      path: Uint8List(0), // Empty path for flood
      payload: Uint8List.fromList(buffer.toBytes()),
    );

    await _writeFrame(packet.toBytes());
    _log('Queued channel message for channel $channelIndex: "$message"');
  }

  Future<void> sendWaypoint({
    required int waypointId,
    required double latitude,
  }) async {
    _log('sendWaypoint() - not implemented for MeshCore', level: 'warn');
  }

  Future<void> sendTraceRouteRequest(int destinationId) async {
    _log(
      'sendTraceRouteRequest() - not implemented for MeshCore',
      level: 'warn',
    );
    // TODO: Implement using payload type 0x09 (PAYLOAD_TYPE_TRACE)
  }

  /// Sets LoRa radio parameters.
  ///
  /// [frequency] in MHz.
  /// [bandwidth] in kHz.
  /// [sf] Spreading Factor (5-12).
  /// [cr] Coding Rate (5-8).
  Future<void> setLoRaConfig({
    required double frequency,
    required double bandwidth,
    required int sf,
    required int cr,
  }) async {
    _ensureNotDisposed();

    // Validate inputs locally to avoid sending invalid commands
    if (frequency < 300.0 || frequency > 2500.0) {
      throw ArgumentError('Invalid frequency: $frequency');
    }
    if (bandwidth < 7.0 || bandwidth > 500.0) {
      throw ArgumentError('Invalid bandwidth: $bandwidth');
    }
    if (sf < 5 || sf > 12) {
      throw ArgumentError('Invalid SF: $sf');
    }
    if (cr < 5 || cr > 8) {
      throw ArgumentError('Invalid CR: $cr');
    }

    final payload = BytesBuilder();
    payload.addByte(MeshCoreConstants.cmdSetRadioParams);

    // freq: float * 1000 -> uint32
    final freqInt = (frequency * 1000).round();
    final freqBytes = Uint8List(4)
      ..buffer.asByteData().setUint32(0, freqInt, Endian.little);
    payload.add(freqBytes);

    // bw: float * 1000 -> uint32 (bandwidth input is kHz, so * 1000 gives Hz? No wait)
    // C++: uint32_t bw = _prefs.bw * 1000;
    // C++ validation: bw >= 7000 && bw <= 500000
    // If input bandwidth is 125.0 kHz.
    // If _prefs.bw is in kHz, then 125 * 1000 = 125000. range 7000..500000 checks out for Hz?
    // Wait. 125 kHz = 125000 Hz.
    // If _prefs.bw was MHz, 0.125 * 1000 = 125.
    // Validation is 7000 to 500000.
    // 7000 Hz = 7 kHz. 500000 Hz = 500 kHz.
    // So C++ expects the value in the packet to be in Hz.
    // However, the C++ code calculating the packet `uint32_t bw` does `_prefs.bw * 1000`.
    // If `_prefs.bw` is kHz (e.g. 125.0), then packet has 125000.
    // So we need to send 125000 for 125 kHz.
    // Our input `bandwidth` is in kHz.
    // So we send `bandwidth * 1000`.

    final bwInt = (bandwidth * 1000).round();
    final bwBytes = Uint8List(4)
      ..buffer.asByteData().setUint32(0, bwInt, Endian.little);
    payload.add(bwBytes);

    payload.addByte(sf);
    payload.addByte(cr);

    await _writeRaw(payload.toBytes());
    _log(
      'Sent CMD_SET_RADIO_PARAMS: Freq=$frequency, BW=$bandwidth, SF=$sf, CR=$cr',
    );
  }

  /// Sets Tx Power.
  ///
  /// [power] can be 0-20? Max varies.
  Future<void> setTxPower(int power) async {
    _ensureNotDisposed();

    _log('Setting TX power to $power dBm');

    // MeshCore accepts power in dBm, no strict validation here,
    // but safe to allow what UI gives.

    final payload = BytesBuilder();
    payload.addByte(MeshCoreConstants.cmdSetRadioTxPower);
    payload.addByte(power);

    await _writeRaw(payload.toBytes());
    _log('Sent CMD_SET_RADIO_TX_POWER: $power');
  }

  /// Get a specific channel by index
  ///
  /// Sends CMD_GET_CHANNEL and waits for RESP_CODE_CHANNEL_INFO response
  Future<MeshCoreChannel> getChannel(int index) async {
    _ensureNotDisposed();

    if (index < 0 || index >= MeshCoreConstants.maxChannels) {
      throw ArgumentError(
        'Channel index must be 0-${MeshCoreConstants.maxChannels - 1}',
      );
    }

    _log('Requesting channel $index');

    // Set up completer for response
    _channelQueryCompleter = Completer<MeshCoreChannel>();

    try {
      // Send CMD_GET_CHANNEL
      final payload = Uint8List.fromList([
        MeshCoreConstants.cmdGetChannel,
        index,
      ]);
      await _writeRaw(payload);

      // Wait for response
      final channel = await _channelQueryCompleter!.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Timeout waiting for channel $index response');
        },
      );

      _log('Successfully retrieved channel $index: ${channel.name}');
      return channel;
    } finally {
      _channelQueryCompleter = null;
    }
  }

  /// Set a channel configuration
  ///
  /// Sends CMD_SET_CHANNEL with name and PSK
  Future<void> setChannel(int index, String name, Uint8List psk) async {
    _ensureNotDisposed();

    if (index < 0 || index >= MeshCoreConstants.maxChannels) {
      throw ArgumentError(
        'Channel index must be 0-${MeshCoreConstants.maxChannels - 1}',
      );
    }

    if (psk.length != MeshCoreConstants.channelPskLength) {
      throw ArgumentError(
        'PSK must be ${MeshCoreConstants.channelPskLength} bytes, got ${psk.length}',
      );
    }

    _log('Setting channel $index: "$name"');

    final channel = MeshCoreChannel(index: index, name: name, psk: psk);

    await _writeRaw(channel.toBytes());
    _log('Sent CMD_SET_CHANNEL for index $index');

    // Note: Device should respond with RESP_CODE_OK or RESP_CODE_ERR
    // We could add a completer here to wait for acknowledgment if needed
  }

  /// Query all available channels
  ///
  /// Requests channels 0 through maxChannels-1
  Future<List<MeshCoreChannel>> getAllChannels() async {
    _ensureNotDisposed();

    _log('Querying all channels (0-${MeshCoreConstants.maxChannels - 1})');

    final channels = <MeshCoreChannel>[];

    for (int i = 0; i < MeshCoreConstants.maxChannels; i++) {
      try {
        final channel = await getChannel(i);
        channels.add(channel);
      } catch (e) {
        // Channel might not be configured, that's okay
        _log('Channel $i not available: $e', level: 'debug');
        // Continue to next channel
      }
    }

    _log('Retrieved ${channels.length} channels');
    return channels;
  }
}
