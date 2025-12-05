import 'package:flutter/material.dart';
import '../widgets/chat_widget.dart';
import '../widgets/mesh_app_bar.dart';

import '../services/message_routing_service.dart';

class DeviceChatPage extends StatelessWidget {
  final String deviceId;
  final int? toNodeId;
  final int? channelIndex;
  final String? chatTitle;

  const DeviceChatPage({
    super.key,
    required this.deviceId,
    this.toNodeId,
    this.channelIndex,
    this.chatTitle,
  });

  @override
  Widget build(BuildContext context) {
    // We can try to fetch the device name from DeviceStateService if not provided
    // But for now, just use ID if title is missing
    final title = chatTitle ?? 'Chat';

    return FutureBuilder<String>(
      future: (channelIndex != null || toNodeId == null)
          ? MessageRoutingService.instance.getChannelChatRoomId(
              deviceId,
              channelIndex ?? 0,
            )
          : MessageRoutingService.instance.getDirectChatRoomId(
              deviceId,
              toNodeId!,
            ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: MeshAppBar(title: Text(title)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: MeshAppBar(title: Text(title)),
          body: ChatWidget(roomId: snapshot.data!),
        );
      },
    );
  }
}
