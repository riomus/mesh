import 'package:flutter/foundation.dart';
import 'package:mesh/services/local_notification_provider.dart'
    if (dart.library.html) 'package:mesh/services/local_notification_provider_stub.dart';
import 'package:mesh/services/notification_provider.dart';
import 'package:mesh/services/web_notification_provider.dart'
    if (dart.library.io) 'package:mesh/services/web_notification_provider_stub.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  late NotificationProvider _provider;

  NotificationService._internal() {
    if (kIsWeb) {
      _provider = WebNotificationProvider();
    } else {
      _provider = LocalNotificationProvider();
    }
  }

  @visibleForTesting
  void setProviderForTesting(NotificationProvider provider) {
    _provider = provider;
  }

  Future<void> init() async {
    await _provider.init();
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    await _provider.requestPermissions();
  }

  Future<void> showNotification(
    int id,
    String title,
    String body,
    String? payload,
  ) async {
    await _provider.showNotification(id, title, body, payload);
  }
}
