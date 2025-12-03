import 'package:mesh/services/notification_provider.dart';

class WebNotificationProvider implements NotificationProvider {
  @override
  Future<void> init() async {
    throw UnimplementedError(
      'WebNotificationProvider is not available on this platform',
    );
  }

  @override
  Future<void> requestPermissions() async {
    throw UnimplementedError(
      'WebNotificationProvider is not available on this platform',
    );
  }

  @override
  Future<void> showNotification(
    int id,
    String title,
    String body,
    String? payload,
  ) async {
    throw UnimplementedError(
      'WebNotificationProvider is not available on this platform',
    );
  }
}
