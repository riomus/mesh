import 'dart:io';

/// Custom exception for BLE connection timeouts.
/// Thrown when the initial BLE connection fails to establish within the timeout period.
class BleConnectionTimeoutException implements Exception {
  final String deviceId;
  final Duration timeout;

  BleConnectionTimeoutException(this.deviceId, this.timeout);

  @override
  String toString() =>
      'BLE connection to $deviceId timed out after ${timeout.inSeconds}s';
}

/// Transient BLE errors that may be resolved by retrying the connection.
/// Examples: temporary radio interference, device busy, etc.
class BleTransientException implements Exception {
  final String deviceId;
  final Object originalError;

  BleTransientException(this.deviceId, this.originalError);

  @override
  String toString() =>
      'Transient BLE error for $deviceId: $originalError (may retry)';
}

/// Permanent BLE errors that should not trigger automatic reconnection.
/// Examples: device not found, service not supported, user cancellation.
class BlePermanentException implements Exception {
  final String deviceId;
  final Object originalError;

  BlePermanentException(this.deviceId, this.originalError);

  @override
  String toString() =>
      'Permanent BLE error for $deviceId: $originalError (will not retry)';
}

/// Exception indicating that a scan is required before attempting to connect.
class ScanRequiredException implements Exception {
  @override
  String toString() => 'ScanRequiredException';
}

/// Helper to categorize BLE errors.
class BleErrorHelper {
  /// Determine if an error is transient (worth retrying).
  static bool isTransient(Object error) {
    final errorStr = error.toString().toLowerCase();

    // Platform-specific transient errors
    if (Platform.isAndroid) {
      return errorStr.contains('busy') ||
          errorStr.contains('timeout') ||
          errorStr.contains('133') || // GATT error 133
          errorStr.contains('device not ready');
    } else if (Platform.isIOS) {
      return errorStr.contains('timeout') ||
          errorStr.contains('busy') ||
          errorStr.contains('not ready');
    }

    return errorStr.contains('timeout') || errorStr.contains('busy');
  }

  /// Determine if an error is permanent (should not retry).
  static bool isPermanent(Object error) {
    final errorStr = error.toString().toLowerCase();

    return errorStr.contains('not found') ||
        errorStr.contains('not supported') ||
        errorStr.contains('cancelled') ||
        errorStr.contains('user') ||
        errorStr.contains('authorization') ||
        errorStr.contains('permission');
  }

  /// Wrap an error in the appropriate exception type.
  static Exception categorize(String deviceId, Object error) {
    if (isPermanent(error)) {
      return BlePermanentException(deviceId, error);
    } else if (isTransient(error)) {
      return BleTransientException(deviceId, error);
    }

    // Default to transient if we can't categorize
    return BleTransientException(deviceId, error);
  }
}
