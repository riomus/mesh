import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/models/chat_models.dart';
import 'package:mesh/services/chatting_device.dart';
import 'package:mesh/services/message_routing_service.dart';
import 'package:mesh/services/transport_layer.dart';

class MockChattingDevice implements ChattingDevice {
  @override
  final String id;
  @override
  final String displayName;
  final List<String> sentMessages = [];

  MockChattingDevice(this.id, this.displayName);

  @override
  Future<int> sendMessage(String text, int? toId, {int? channelIndex}) async {
    sentMessages.add(text);
    return 12345; // Mock packet ID
  }
}

class MockTransportLayer implements TransportLayer {
  final Map<String, ChattingDevice> devices = {};

  @override
  Future<ChattingDevice?> getDevice(String deviceId) async {
    return devices[deviceId];
  }
}

void main() {
  late MessageRoutingService service;
  late MockTransportLayer mockTransport;

  setUp(() {
    service = MessageRoutingService.instance;
    mockTransport = MockTransportLayer();
    service.transportLayer = mockTransport;
  });

  test('sendMessage sends direct message correctly', () async {
    final deviceId = 'device1';
    final nodeId = 123;
    final roomId = await service.getDirectChatRoomId(deviceId, nodeId);
    final mockDevice = MockChattingDevice(deviceId, 'Device 1');
    mockTransport.devices[deviceId] = mockDevice;

    await service.sendMessage(roomId, 'Hello');

    expect(mockDevice.sentMessages.length, 1);
    expect(mockDevice.sentMessages.first, 'Hello|$nodeId|null');
  });

  test('sendMessage sends channel message correctly', () async {
    final deviceId = 'device1';
    final channelIndex = 2;
    final roomId = await service.getChannelChatRoomId(deviceId, channelIndex);
    final mockDevice = MockChattingDevice(deviceId, 'Device 1');
    mockTransport.devices[deviceId] = mockDevice;

    await service.sendMessage(roomId, 'Hello Channel');

    expect(mockDevice.sentMessages.length, 1);
    expect(mockDevice.sentMessages.first, 'Hello Channel|null|$channelIndex');
  });

  test('sendMessage throws if device not found', () async {
    final deviceId = 'device2';
    final nodeId = 456;
    final roomId = await service.getDirectChatRoomId(deviceId, nodeId);

    expect(
      () => service.sendMessage(roomId, 'Should fail'),
      throwsA(isA<Exception>()),
    );
  });
}
