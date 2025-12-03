import 'chatting_device.dart';

/// Abstract interface for a transport layer that can provide devices for chatting.
abstract class TransportLayer {
  /// Retrieves a device by its ID.
  /// Returns null if the device is not found or not connected via this transport.
  Future<ChattingDevice?> getDevice(String deviceId);
}
