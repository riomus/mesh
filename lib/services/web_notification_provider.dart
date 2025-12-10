// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter_web_notification_platform/flutter_web_notification_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:mesh/services/notification_provider.dart';

class WebNotificationProvider implements NotificationProvider {
  final PlatformNotification _notificationPlatform = PlatformNotificationWeb();

  @override
  Future<void> init() async {
    // No specific initialization needed for web plugin currently,
    // but keeping method for consistency and future use.
  }

  @override
  Future<void> requestPermissions() async {
    debugPrint('WebNotificationProvider: Requesting permissions...');
    try {
      _notificationPlatform.requestPermission();
      debugPrint(
        'WebNotificationProvider: Permission request completed. Current status: ${html.Notification.permission}',
      );
    } catch (e) {
      debugPrint('WebNotificationProvider: Error requesting permissions: $e');
    }
  }

  @override
  Future<void> showNotification(
    int id,
    String title,
    String body,
    String? payload,
  ) async {
    final permission = html.Notification.permission;
    debugPrint(
      'WebNotificationProvider: Showing notification: $title - $body. Permission status: $permission',
    );

    if (permission != 'granted') {
      debugPrint(
        'WebNotificationProvider: Cannot show notification because permission is $permission',
      );
      return;
    }

    try {
      // Try using the plugin first
      _notificationPlatform.sendNotification(title, body);
    } catch (e) {
      debugPrint('WebNotificationProvider: Error using plugin: $e');
      // Fallback to direct html notification if plugin fails
      try {
        html.Notification(title, body: body);
      } catch (e2) {
        debugPrint('WebNotificationProvider: Error using fallback: $e2');
      }
    }
  }
}
