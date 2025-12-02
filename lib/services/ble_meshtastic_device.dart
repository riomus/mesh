import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../generated/meshtastic/meshtastic/portnums.pbenum.dart' as port;
import 'device_status_store.dart';
import 'chatting_device.dart';

/// Implementation of [ChattingDevice] for Bluetooth LE devices.
class BleMeshtasticDevice implements ChattingDevice {
  final BluetoothDevice _device;

  BleMeshtasticDevice(this._device);

  @override
  String get id => _device.remoteId.str;

  @override
  String get displayName => _device.platformName.isNotEmpty
      ? _device.platformName
      : _device.remoteId.str;

  @override
  Future<void> sendMessage(String text, int? toId, {int? channelIndex}) async {
    final client = await DeviceStatusStore.instance.connect(_device);

    // Construct MeshPacket
    final packet = mesh.MeshPacket();
    if (toId != null) {
      packet.to = toId;
    }
    if (channelIndex != null) {
      packet.channel = channelIndex;
    }
    packet.decoded = mesh.Data();
    packet.decoded.portnum = port.PortNum.TEXT_MESSAGE_APP;
    packet.decoded.payload = Uint8List.fromList(text.codeUnits);
    packet.wantAck = true;
    packet.hopLimit = 7;
    packet.priority = mesh.MeshPacket_Priority.RELIABLE;

    await client.sendMeshPacket(packet);
  }
}
