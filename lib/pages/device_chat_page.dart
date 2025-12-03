import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../l10n/app_localizations.dart';
import '../widgets/chat_widget.dart';
import '../widgets/mesh_app_bar.dart';
import '../utils/text_sanitize.dart';

import '../services/message_routing_service.dart';

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

    return FutureBuilder<String>(
      future: (channelIndex != null || toNodeId == null)
          ? MessageRoutingService.instance.getChannelChatRoomId(
              device.remoteId.str,
              channelIndex ?? 0,
            )
          : MessageRoutingService.instance.getDirectChatRoomId(
              device.remoteId.str,
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
