import 'dart:async';
import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import 'meshtastic_client.dart';
import '../meshtastic/model/meshtastic_event.dart';

/// Stub implementation of MeshtasticUsbClient for web platform.
/// USB serial communication is not supported on web.
class MeshtasticUsbClient extends MeshtasticClient {
  final String portName;
  final String deviceId;

  final StreamController<MeshtasticEvent> _eventsController =
      StreamController.broadcast();
  final StreamController<int> _rssiController = StreamController.broadcast();

  MeshtasticUsbClient({required this.portName, required this.deviceId});

  @override
  Stream<MeshtasticEvent> get events => _eventsController.stream;

  @override
  Stream<int> get rssi => _rssiController.stream;

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 20)}) async {
    throw UnsupportedError('USB serial communication is not supported on web');
  }

  @override
  Future<void> disconnect() async {
    throw UnsupportedError('USB serial communication is not supported on web');
  }

  @override
  Future<void> dispose() async {
    await _eventsController.close();
    await _rssiController.close();
  }

  @override
  Future<void> requestConfig() async {
    throw UnsupportedError('USB serial communication is not supported on web');
  }

  @override
  Future<void> sendMeshPacket(mesh.MeshPacket packet) async {
    throw UnsupportedError('USB serial communication is not supported on web');
  }

  @override
  Future<void> sendToRadio(mesh.ToRadio message) async {
    throw UnsupportedError('USB serial communication is not supported on web');
  }
}

/// Stub class for SerialPort availability check on web
class SerialPortStub {
  static List<String> get availablePorts => [];
}
