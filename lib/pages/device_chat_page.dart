import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../l10n/app_localizations.dart';
import '../widgets/chat_widget.dart';
import '../widgets/mesh_app_bar.dart';
import '../utils/text_sanitize.dart';

class DeviceChatPage extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceChatPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MeshAppBar(
        title: Text('${AppLocalizations.of(context).chat} - ${safeText(device.platformName.isNotEmpty ? device.platformName : device.remoteId.str)}'),
      ),
      body: ChatWidget(device: device),
    );
  }
}
