import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter/foundation.dart';
import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import 'meshtastic_client.dart';
import 'logging_service.dart';
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_mappers.dart';

class MeshtasticUsbClient implements MeshtasticClient {
  final String portName;
  final String deviceId; // We might need to fetch this from the device
  SerialPort? _port;
  SerialPortReader? _reader;

  final StreamController<MeshtasticEvent> _eventsController =
      StreamController.broadcast();
  final StreamController<int> _rssiController = StreamController.broadcast();

  MeshtasticUsbClient({required this.portName, required this.deviceId});

  @override
  Stream<MeshtasticEvent> get events => _eventsController.stream;

  @override
  Stream<int> get rssi => _rssiController.stream;

  static const _start1 = 0x94;
  static const _start2 = 0xC3;
  static const _headerLen = 4; // start1 + start2 + length (2 bytes)

  final List<int> _buffer = [];

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 20)}) async {
    _log('Connecting to USB port $portName');

    try {
      _port = SerialPort(portName);
      if (!_port!.openReadWrite()) {
        throw Exception('Failed to open serial port $portName');
      }

      final config = SerialPortConfig();
      config.baudRate = 115200; // Standard Meshtastic baud rate
      _port!.config = config;

      _reader = SerialPortReader(_port!);
      _reader!.stream.listen(
        _handleData,
        onError: (e) {
          _log('Error reading from port: $e', level: 'error');
          _eventsController.addError(e);
        },
        onDone: () {
          _log('Port closed');
          _eventsController.close();
        },
      );

      _log('Connected');

      // Request config
      await requestConfig();
    } catch (e) {
      _log('Failed to connect: $e', level: 'error');
      await dispose();
      rethrow;
    }
  }

  void _handleData(Uint8List data) {
    _buffer.addAll(data);

    while (_buffer.length >= _headerLen) {
      // Look for start bytes
      if (_buffer[0] != _start1 || _buffer[1] != _start2) {
        // parsing error, skip one byte and try again
        _buffer.removeAt(0);
        continue;
      }

      // Parse length (big endian)
      final length = (_buffer[2] << 8) | _buffer[3];

      if (_buffer.length < _headerLen + length) {
        // Not enough data yet
        break;
      }

      // Extract packet
      final packetData = _buffer.sublist(_headerLen, _headerLen + length);
      _buffer.removeRange(0, _headerLen + length);

      try {
        final fromRadio = mesh.FromRadio.fromBuffer(packetData);
        _handleFromRadio(fromRadio);
      } catch (e) {
        _log('Error parsing protobuf: $e', level: 'error');
      }
    }
  }

  void _handleFromRadio(mesh.FromRadio fromRadio) {
    try {
      final event = MeshtasticMappers.fromFromRadio(fromRadio);
      _eventsController.add(event);
    } catch (e) {
      _log('Error mapping FromRadio to event: $e', level: 'error');
    }
  }

  @override
  Future<void> disconnect() async {
    _log('Disconnecting');
    try {
      // Send disconnect packet if possible?
      // Not strictly required for serial, but good practice if protocol supports it.
      // For now just close port.
    } catch (_) {}
    await dispose();
  }

  @override
  Future<void> dispose() async {
    _reader?.close();
    _port?.close();
    _port?.dispose();
    _port = null;
    _eventsController.close();
    _rssiController.close();
  }

  @override
  Future<void> requestConfig() async {
    _log('Sending startConfig (wantConfigId=0)');
    final start = mesh.ToRadio(wantConfigId: 0);
    await sendToRadio(start);
  }

  @override
  Future<void> sendMeshPacket(mesh.MeshPacket packet) async {
    final toRadio = mesh.ToRadio(packet: packet);
    await sendToRadio(toRadio);
  }

  @override
  Future<void> sendToRadio(mesh.ToRadio message) async {
    if (_port == null || !_port!.isOpen) {
      throw Exception('Port not open');
    }

    final data = message.writeToBuffer();
    final length = data.length;

    final header = Uint8List(4);
    header[0] = _start1;
    header[1] = _start2;
    header[2] = (length >> 8) & 0xFF;
    header[3] = length & 0xFF;

    final bytes = Uint8List(header.length + data.length);
    bytes.setAll(0, header);
    bytes.setAll(header.length, data);

    _port!.write(bytes);
  }

  void _log(String msg, {String level = 'info'}) {
    LoggingService.instance.push(
      tags: {'category': 'usb', 'deviceId': deviceId},
      level: level,
      message: '[MeshtasticUsbClient] $msg',
    );
  }
}
