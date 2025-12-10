import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_mappers.dart';
import '../meshtastic/model/device_type.dart';
import 'logging_service.dart';
import 'meshtastic_client.dart';
import 'device_communication_event_service.dart';

/// Meshtastic IP client that connects via TCP.
class MeshtasticIpClient extends MeshtasticClient {
  final String host;
  final int port;
  final String
  deviceId; // We might not know this until we connect, but for now let's assume we pass it or discover it.

  Socket? _socket;
  final _eventsController = StreamController<MeshtasticEvent>.broadcast();
  final _rssiController =
      StreamController<
        int
      >.broadcast(); // IP might not have RSSI in the same way, or we get it from packets.

  bool _isDisposed = false;

  MeshtasticIpClient({
    required this.host,
    required this.port,
    required this.deviceId,
  });

  @override
  DeviceType get deviceType => DeviceType.meshtastic;

  @override
  Stream<MeshtasticEvent> get events => _eventsController.stream;

  @override
  Stream<int> get rssi => _rssiController.stream;

  static Map<String, Object?> logTagsForDeviceId(String deviceId) => {
    'network': 'meshtastic',
    'deviceId': deviceId,
    'class': 'MeshtasticIpClient',
  };

  void _log(String msg, {String level = 'info'}) {
    LoggingService.instance.push(
      tags: logTagsForDeviceId(deviceId),
      level: level,
      message: msg,
    );
  }

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 20)}) async {
    _log('Connecting to $host:$port ...');
    try {
      _socket = await Socket.connect(host, port, timeout: timeout);
      _log('Connected to $host:$port');

      _socket!.listen(
        (data) {
          _handleData(data);
        },
        onError: (error) {
          _log('Socket error: $error', level: 'error');
          disconnect();
        },
        onDone: () {
          _log('Socket closed');
          disconnect();
        },
      );

      // Send startConfig
      await requestConfig();
    } catch (e) {
      _log('Failed to connect: $e', level: 'error');
      rethrow;
    }
  }

  @override
  Future<void> requestConfig() async {
    _log('Sending startConfig (wantConfigId=0)');
    final start = mesh.ToRadio(wantConfigId: 0);
    await sendToRadio(start);
  }

  // Buffer for incoming data to handle fragmentation
  final List<int> _buffer = [];

  void _handleData(Uint8List data) {
    _buffer.addAll(data);

    while (_buffer.length >= 4) {
      // Meshtastic TCP protocol:
      // First 2 bytes: magic 0x94C3
      // Next 2 bytes: length (big endian)
      // Payload: length bytes (FromRadio protobuf)

      // Check magic
      if (_buffer[0] != 0x94 || _buffer[1] != 0xC3) {
        // Invalid magic, scan forward? Or just drop?
        // For now, let's try to find the magic byte
        _log(
          'Invalid magic bytes: ${_buffer[0].toRadixString(16)} ${_buffer[1].toRadixString(16)}',
          level: 'warn',
        );
        _buffer.removeAt(0);
        continue;
      }

      final length = (_buffer[2] << 8) | _buffer[3];
      if (_buffer.length < 4 + length) {
        // Not enough data yet
        return;
      }

      final payload = _buffer.sublist(4, 4 + length);
      _buffer.removeRange(0, 4 + length);

      try {
        final msg = mesh.FromRadio.fromBuffer(payload);
        _log('FromRadio received: $msg');

        try {
          final event = MeshtasticMappers.fromFromRadio(msg);
          _eventsController.add(event);
          try {
            DeviceCommunicationEventService.instance.pushMeshtastic(
              event: event,
              deviceId: deviceId,
              summary: event.runtimeType.toString(),
            );
          } catch (_) {}
        } catch (mapErr) {
          _log('Failed to map FromRadio to event: $mapErr', level: 'warn');
        }
      } catch (e) {
        _log('Failed to parse FromRadio: $e', level: 'error');
      }
    }
  }

  @override
  Future<void> sendToRadio(mesh.ToRadio message) async {
    if (_socket == null) throw StateError('Not connected');

    final data = message.writeToBuffer();
    final length = data.length;

    // Header: Magic (2 bytes) + Length (2 bytes)
    final header = [0x94, 0xC3, (length >> 8) & 0xFF, length & 0xFF];

    _socket!.add(header);
    _socket!.add(data);
    await _socket!.flush();
  }

  @override
  Future<void> sendMeshPacket(mesh.MeshPacket packet) async {
    await sendToRadio(mesh.ToRadio(packet: packet));
  }

  @override
  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    await dispose();
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _socket?.close();
    await _eventsController.close();
    await _rssiController.close();
  }
}
