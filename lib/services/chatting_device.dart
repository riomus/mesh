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
  Future<int> sendMessage(String text, int? toId, {int? channelIndex});

  /// Sends a traceroute request to discover the path to a target node.
  /// [targetNodeId] is the destination node to trace the route to.
  /// Returns the packet ID for tracking the response.
  Future<int> sendTraceroute(int targetNodeId);
}
