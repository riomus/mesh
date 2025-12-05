import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../generated/meshtastic/meshtastic/portnums.pbenum.dart' as port;
import 'device_status_store.dart';

import 'device_state_service.dart';
import 'chatting_device.dart';

/// Implementation of [ChattingDevice] for Bluetooth LE devices.
class BleMeshtasticDevice implements ChattingDevice {
  final BluetoothDevice _device;
  int _currentPacketId = Random().nextInt(0xFFFFFFFF);

  BleMeshtasticDevice(this._device);

  @override
  String get id => _device.remoteId.str;

  @override
  String get displayName => _device.platformName.isNotEmpty
      ? _device.platformName
      : _device.remoteId.str;

  int _generatePacketId() {
    var nextPacketId = (_currentPacketId + 1) & 0xFFFFFFFF;
    nextPacketId = nextPacketId & 0x3FF; // masks upper 22 bits
    var randomPart = (Random().nextInt(0x3FFFFF) << 10) & 0xFFFFFFFF;
    _currentPacketId = nextPacketId | randomPart;
    return _currentPacketId;
  }

  @override
  Future<int> sendMessage(String text, int? toId, {int? channelIndex}) async {
    final client = await DeviceStatusStore.instance.connect(_device);

    // Construct MeshPacket
    final packet = mesh.MeshPacket();
    // 0xFFFFFFFF is broadcast

    // Default to channel 0 (Primary) if not specified (e.g. for DMs)
    if (channelIndex != null) {
      packet.channel = channelIndex;
      packet.to = 0xFFFFFFFF;
    } else if (toId != null) {
      packet.to = toId;
    } else {
      print(
        'BleMeshtasticDevice: sendMessage: toId is null and channelIndex is null. Not sending message.',
      );
      return 0;
    }

    packet.decoded = mesh.Data();
    packet.decoded.portnum = port.PortNum.TEXT_MESSAGE_APP;
    packet.decoded.payload = Uint8List.fromList(utf8.encode(text));
    // Only want ack for direct messages
    if (toId != null) {
      packet.wantAck = true;
    }

    // Fetch hopLimit from device state, default to 3 if not found (standard default)
    // Python implementation: loraConfig.hop_limit
    final state = DeviceStateService.instance.getState(_device.remoteId.str);
    packet.hopLimit = state?.config?.lora?.hopLimit ?? 3;

    packet.priority = mesh.MeshPacket_Priority.RELIABLE;

    // Generate ID using Python-compatible logic
    packet.id = _generatePacketId();

    // packet.from is intentionally NOT set.
    // The device firmware will populate this with its own node ID.
    // Setting it manually can cause the device to reject the packet as a duplicate/loopback.

    print(packet);

    await client.sendMeshPacket(packet);
    return packet.id;
  }

  @override
  Future<int> sendTraceroute(int targetNodeId) async {
    final client = await DeviceStatusStore.instance.connect(_device);

    // Construct MeshPacket for traceroute
    final packet = mesh.MeshPacket();
    packet.to = targetNodeId;

    // Create Data payload with TRACEROUTE_APP portnum
    packet.decoded = mesh.Data();
    packet.decoded.portnum = port.PortNum.TRACEROUTE_APP;
    // Payload should be empty RouteDiscovery (firmware handles the actual tracing)
    packet.decoded.payload = Uint8List(0);

    // Request ACK to track when the packet is received
    packet.wantAck = true;

    // Fetch hopLimit from device state
    final state = DeviceStateService.instance.getState(_device.remoteId.str);
    packet.hopLimit = state?.config?.lora?.hopLimit ?? 3;

    packet.priority = mesh.MeshPacket_Priority.RELIABLE;

    // Generate unique packet ID
    packet.id = _generatePacketId();

    print('Sending traceroute packet to node $targetNodeId: $packet');

    await client.sendMeshPacket(packet);
    return packet.id;
  }
}
