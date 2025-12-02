import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../l10n/app_localizations.dart';
import '../widgets/chat_widget.dart';
import '../widgets/mesh_app_bar.dart';
import '../utils/text_sanitize.dart';

import '../services/ble_meshtastic_device.dart';
import '../services/message_sender.dart';
import '../services/device_message_sender.dart';
import '../services/channel_message_sender.dart';

class DeviceChatPage extends StatelessWidget {
  final BluetoothDevice device;
  final int? toNodeId;
  final int? channelIndex;
  final String? chatTitle;

  const DeviceChatPage({
    super.key,
    required this.device,
    this.toNodeId,
    this.channelIndex,
    this.chatTitle,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        chatTitle ??
        '${AppLocalizations.of(context).chat} - ${safeText(device.platformName.isNotEmpty ? device.platformName : device.remoteId.str)}';

    final chattingDevice = BleMeshtasticDevice(device);
    final MessageSender messageSender;

    if (channelIndex != null) {
      messageSender = ChannelMessageSender(
        device: chattingDevice,
        channelIndex: channelIndex!,
      );
    } else {
      messageSender = DeviceMessageSender(
        device: chattingDevice,
        toNodeId: toNodeId,
      );
    }

    return Scaffold(
      appBar: MeshAppBar(title: Text(title)),
      body: ChatWidget(
        messageSender: messageSender,
        deviceId: device.remoteId.str,
        toNodeId: toNodeId,
      ),
    );
  }
}
