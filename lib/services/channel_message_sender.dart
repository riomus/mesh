import 'chatting_device.dart';
import 'message_sender.dart';

/// Message sender for channel messaging.
class ChannelMessageSender implements MessageSender {
  final ChattingDevice device;
  final int channelIndex;

  ChannelMessageSender({required this.device, required this.channelIndex});

  @override
  Future<void> sendMessage(String content) async {
    await device.sendMessage(content, null, channelIndex: channelIndex);
  }
}
