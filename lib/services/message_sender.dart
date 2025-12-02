/// Simple interface for sending messages.
/// Implementations should handle the specific details of where and how to send.
abstract class MessageSender {
  /// Sends a message with the given content.
  Future<void> sendMessage(String content);
}
