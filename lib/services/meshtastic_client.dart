import 'dart:async';

import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../meshtastic/model/meshtastic_event.dart';

/// Abstract base class for a Meshtastic client (BLE, IP, Serial, etc.).
abstract class MeshtasticClient {
  /// Stream of high-level Meshtastic events.
  Stream<MeshtasticEvent> get events;

  /// Stream of RSSI updates (if applicable).
  Stream<int> get rssi;

  /// Connect to the device.
  Future<void> connect({Duration timeout});

  /// Disconnect from the device.
  Future<void> disconnect();

  /// Send a ToRadio protobuf message.
  Future<void> sendToRadio(mesh.ToRadio message);

  /// Send a MeshPacket (convenience wrapper around sendToRadio).
  Future<void> sendMeshPacket(mesh.MeshPacket packet);

  /// Request configuration from the device.
  Future<void> requestConfig();

  /// Dispose resources.
  Future<void> dispose();
}
