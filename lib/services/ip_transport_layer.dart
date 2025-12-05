import 'transport_layer.dart';
import 'chatting_device.dart';
import 'ip_meshtastic_device.dart';
import 'device_status_store.dart';

class IpTransportLayer implements TransportLayer {
  @override
  Future<ChattingDevice?> getDevice(String deviceId) async {
    // Check if the device is connected via DeviceStatusStore
    // For IP devices, deviceId is likely "IP:host:port" or just the node ID if we mapped it.
    // If it's "IP:...", we can parse it.

    // However, DeviceStatusStore stores entries by ID.
    // If we have an entry, we can check if it's an IP device.
    // But _Entry doesn't explicitly say "IP", it just has null BluetoothDevice.

    // Also, we need to return ChattingDevice.
    // IpMeshtasticDevice needs host and port.
    // If we only have deviceId, we might not be able to reconstruct host/port if it's just a node ID.
    // But if deviceId IS "IP:host:port", we can.

    if (deviceId.startsWith('IP:')) {
      final parts = deviceId.split(':');
      if (parts.length == 3) {
        final host = parts[1];
        final port = int.tryParse(parts[2]);
        if (port != null) {
          return IpMeshtasticDevice(deviceId, host, port);
        }
      }
    }

    // If it's a node ID, we might have it in DeviceStatusStore?
    // Current implementation of connectIp uses "IP:host:port" as ID.
    // So if we look it up by that ID, we are good.

    if (DeviceStatusStore.instance.isConnected(deviceId)) {
      // If it is connected, we can try to get it.
      // But we need to know if it is IP or BLE to return correct wrapper.
      // DeviceStatusStore doesn't expose type easily.
      // But we can check if we can parse it as IP ID.
      if (deviceId.startsWith('IP:')) {
        final parts = deviceId.split(':');
        if (parts.length == 3) {
          final host = parts[1];
          final port = int.tryParse(parts[2]);
          if (port != null) {
            return IpMeshtasticDevice(deviceId, host, port);
          }
        }
      }
    }

    return null;
  }
}
