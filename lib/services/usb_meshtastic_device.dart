import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';

import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../generated/meshtastic/meshtastic/portnums.pbenum.dart' as port;
import 'device_status_store.dart';
import 'device_state_service.dart';
import 'chatting_device.dart';

/// Implementation of [ChattingDevice] for USB devices.
class UsbMeshtasticDevice implements ChattingDevice {
  final String _portName;
  final String _deviceId; // The node ID
  int _currentPacketId = Random().nextInt(0xFFFFFFFF);

  UsbMeshtasticDevice(this._portName, this._deviceId);

  @override
  String get id => _deviceId;

  @override
  String get displayName => 'USB:$_portName';

  int _generatePacketId() {
    var nextPacketId = (_currentPacketId + 1) & 0xFFFFFFFF;
    nextPacketId = nextPacketId & 0x3FF; // masks upper 22 bits
    var randomPart = (Random().nextInt(0x3FFFFF) << 10) & 0xFFFFFFFF;
    _currentPacketId = nextPacketId | randomPart;
    return _currentPacketId;
  }

  @override
  Future<int> sendMessage(String text, int? toId, {int? channelIndex}) async {
    // Ensure connected
    final client = await DeviceStatusStore.instance.connectToId(_deviceId);

    if (client == null) {
      // Try to connect if not connected?
      await DeviceStatusStore.instance.connectUsb(_portName);
      // Try getting client again
      final retryClient = await DeviceStatusStore.instance.connectToId(
        _deviceId,
      );
      if (retryClient == null) {
        throw Exception('Could not connect to USB device $_deviceId');
      }
      return _sendMessageWithClient(
        retryClient,
        text,
        toId,
        channelIndex: channelIndex,
      );
    }

    return _sendMessageWithClient(
      client,
      text,
      toId,
      channelIndex: channelIndex,
    );
  }

  Future<int> _sendMessageWithClient(
    dynamic client,
    String text,
    int? toId, {
    int? channelIndex,
  }) async {
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
        'UsbMeshtasticDevice: sendMessage: toId is null and channelIndex is null. Not sending message.',
      );
      return 0;
    }

    packet.decoded = mesh.Data();
    packet.decoded.portnum = port.PortNum.TEXT_MESSAGE_APP;
    packet.decoded.payload = Uint8List.fromList(utf8.encode(text));
    // Only want ack for direct messages
    packet.wantAck = toId != null;

    // Fetch hopLimit from device state, default to 3 if not found (standard default)
    final state = DeviceStateService.instance.getState(_deviceId);
    packet.hopLimit = state?.config?.lora?.hopLimit ?? 3;

    packet.priority = mesh.MeshPacket_Priority.RELIABLE;

    // Generate ID using Python-compatible logic
    packet.id = _generatePacketId();

    // packet.from is intentionally NOT set.

    print(packet);

    await client.sendMeshPacket(packet);
    return packet.id;
  }

  @override
  Future<int> sendTraceroute(int targetNodeId) async {
    // Ensure connected
    final client = await DeviceStatusStore.instance.connectToId(_deviceId);

    if (client == null) {
      await DeviceStatusStore.instance.connectUsb(_portName);
      final retryClient = await DeviceStatusStore.instance.connectToId(
        _deviceId,
      );
      if (retryClient == null) {
        throw Exception('Could not connect to USB device $_deviceId');
      }
      return _sendTracerouteWithClient(retryClient, targetNodeId);
    }

    return _sendTracerouteWithClient(client, targetNodeId);
  }

  Future<int> _sendTracerouteWithClient(
    dynamic client,
    int targetNodeId,
  ) async {
    final packet = mesh.MeshPacket();
    packet.to = targetNodeId;

    packet.decoded = mesh.Data();
    packet.decoded.portnum = port.PortNum.TRACEROUTE_APP;
    packet.decoded.payload = Uint8List(0);

    packet.wantAck = true;

    final state = DeviceStateService.instance.getState(_deviceId);
    packet.hopLimit = state?.config?.lora?.hopLimit ?? 3;

    packet.priority = mesh.MeshPacket_Priority.RELIABLE;
    packet.id = _generatePacketId();

    print(
      'Sending traceroute packet to node $targetNodeId (USB device): $packet',
    );

    await client.sendMeshPacket(packet);
    return packet.id;
  }
}
