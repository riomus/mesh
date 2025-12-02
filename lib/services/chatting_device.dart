/// Abstract interface for a device that can send chat messages.
abstract class ChattingDevice {
  /// Unique identifier for the device (e.g., MAC address or node ID).
  String get id;

  /// Display name for the device.
  String get displayName;

  /// Sends a text message to the device.
  /// [text] is the message content.
  /// [toId] is the optional destination node ID (if applicable).
  /// [channelIndex] is the optional channel index to send on.
  Future<void> sendMessage(String text, int? toId, {int? channelIndex});
}
