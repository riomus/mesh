import 'transport_layer.dart';
import 'chatting_device.dart';
import 'ble_meshtastic_device.dart';
import 'device_status_store.dart';

class BleTransportLayer implements TransportLayer {
  @override
  Future<ChattingDevice?> getDevice(String deviceId) async {
    // Check for simulation device
    if (deviceId == 'SIM-DEVICE-001') {
      final client = await DeviceStatusStore.instance.connectToId(deviceId);
      if (client is ChattingDevice) {
        return client as ChattingDevice;
      }
    }

    // Check if the device is connected via DeviceStatusStore
    if (DeviceStatusStore.instance.isConnected(deviceId)) {
      // We need the BluetoothDevice object to create BleMeshtasticDevice.
      // DeviceStatusStore keeps track of connected devices.
      // We can iterate through connected devices to find the one with the matching ID.
      final connectedDevices = DeviceStatusStore.instance.connectedDevices;
      try {
        final device = connectedDevices.firstWhere(
          (d) => d.remoteId.str == deviceId,
        );
        return BleMeshtasticDevice(device);
      } catch (e) {
        // Not found in connected list, though isConnected said yes?
        // This might happen if there's a race condition or if isConnected checks status but device object is missing.
        // Let's try to get it from DeviceStatusStore if possible, but DeviceStatusStore doesn't expose the device object easily by ID if not in the list.
        // Actually, DeviceStatusStore.instance.connectToId(deviceId) returns a client, but we need the device for BleMeshtasticDevice constructor.
        // Let's rely on connectedDevices list for now.
        return null;
      }
    }
    return null;
  }
}
