import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../l10n/app_localizations.dart';
import '../widgets/chat_widget.dart';
import '../widgets/mesh_app_bar.dart';
import '../utils/text_sanitize.dart';

class DeviceChatPage extends StatelessWidget {
  final BluetoothDevice device;
  final int? toNodeId;
  final String? chatTitle;

  const DeviceChatPage({
    super.key,
    required this.device,
    this.toNodeId,
    this.chatTitle,
  });

  @override
  Widget build(BuildContext context) {
    final title = chatTitle ?? '${AppLocalizations.of(context).chat} - ${safeText(device.platformName.isNotEmpty ? device.platformName : device.remoteId.str)}';
    return Scaffold(
      appBar: MeshAppBar(
        title: Text(title),
      ),
      body: ChatWidget(device: device, toNodeId: toNodeId),
    );
  }
}
