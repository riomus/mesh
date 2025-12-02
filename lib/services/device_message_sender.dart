import 'chatting_device.dart';
import 'message_sender.dart';

/// Message sender for direct device-to-device messaging.
class DeviceMessageSender implements MessageSender {
  final ChattingDevice device;
  final int? toNodeId;

  DeviceMessageSender({required this.device, this.toNodeId});

  @override
  Future<void> sendMessage(String content) async {
    await device.sendMessage(content, toNodeId);
  }
}
