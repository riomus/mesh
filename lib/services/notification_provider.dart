abstract class NotificationProvider {
  Future<void> init();
  Future<void> requestPermissions();
  Future<void> showNotification(
    int id,
    String title,
    String body,
    String? payload,
  );
}
