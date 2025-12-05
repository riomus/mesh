import 'package:flutter/material.dart';
import 'package:mesh/services/notification_service.dart';
import 'package:mesh/services/message_routing_service.dart';
import 'package:mesh/services/device_state_service.dart'; // Added import
import 'package:mesh/navigation/navigator_key.dart'; // Added import
import 'pages/device_chat_page.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Added _loadSettings and DeviceStateService initialization
  _loadSettings();
  DeviceStateService.instance.init();

  // NotificationService initialization and tap listener
  NotificationService.instance.init();
  NotificationService.instance.onNotificationTap.listen((payload) {
    if (payload.isNotEmpty) {
      // Payload is expected to be roomId
      // We need to parse it to get deviceId and other info if possible,
      // or just navigate to ChatWidget with this roomId.
      // However, we want to open DeviceChatPage which wraps ChatWidget.
      // The roomId format is 'dm_{deviceId}_{nodeId}' or 'ch_{deviceId}_{channelIndex}'

      final parts = payload.split('_');
      if (parts.length >= 3) {
        final deviceId = parts[1];
        print('Notification tapped: $payload, deviceId: $deviceId');

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => DeviceChatPage(
              deviceId: deviceId,
              // We can try to parse other parts if needed, e.g. channel index or node id
              // But DeviceChatPage handles room resolution internally if we pass just deviceId and maybe other params.
              // The payload is the roomId.
              // If roomId starts with 'dm_', it's a direct message.
              // If roomId starts with 'ch_', it's a channel message.
              // Let's parse it better.
              toNodeId: parts[0] == 'dm' ? int.tryParse(parts[2]) : null,
              channelIndex: parts[0] == 'ch' ? int.tryParse(parts[2]) : null,
            ),
          ),
        );
        // Example navigation (requires DeviceChatPage to be refactored to accept roomId or deviceId)
        // navigatorKey.currentState?.pushNamed('/deviceChat', arguments: payload);
      }
    }
  });

  // Initialize MessageRoutingService to start listening for messages globally
  // ignore: unnecessary_statements
  MessageRoutingService.instance;

  runApp(const MyApp());
}

// Placeholder for _loadSettings function
void _loadSettings() {
  // Implement your settings loading logic here
  print('Loading settings...');
}
