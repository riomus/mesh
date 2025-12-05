import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/services/recent_devices_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RecentDevicesService', () {
    late RecentDevicesService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      // Accessing instance to ensure it's initialized, though it's a singleton.
      // We might need to reset it if it holds state, but for now we rely on fresh SharedPreferences.
      // Since it's a singleton, state might persist across tests if not careful.
      // Ideally we should have a way to reset it or use a fresh instance.
      // For this test, we can just clear the list if possible, or rely on load() clearing it?
      // load() overwrites _devices.
      service = RecentDevicesService.instance;
      await service.load(); // Should load empty
    });

    test('starts empty', () {
      expect(service.currentDevices, isEmpty);
    });

    test('adds a device', () async {
      final device = BluetoothDevice(
        remoteId: const DeviceIdentifier('11:22:33:44:55:66'),
      );
      final result = ScanResult(
        device: device,
        advertisementData: AdvertisementData(
          advName: 'Test Device',
          txPowerLevel: null,
          connectable: true,
          manufacturerData: {},
          serviceData: {},
          serviceUuids: [],
          appearance: null,
        ),
        rssi: -50,
        timeStamp: DateTime.now(),
      );

      await service.add(result);

      expect(service.currentDevices, hasLength(1));
      expect(service.currentDevices.first.id, '11:22:33:44:55:66');
      expect(service.currentDevices.first.name, 'Test Device');
    });

    test('persists devices', () async {
      final device = BluetoothDevice(
        remoteId: const DeviceIdentifier('AA:BB:CC:DD:EE:FF'),
      );
      final result = ScanResult(
        device: device,
        advertisementData: AdvertisementData(
          advName: 'Persisted Device',
          txPowerLevel: null,
          connectable: true,
          manufacturerData: {},
          serviceData: {},
          serviceUuids: [],
          appearance: null,
        ),
        rssi: -60,
        timeStamp: DateTime.now(),
      );

      await service.add(result);

      // Simulate app restart by reloading from SharedPreferences
      await service.load();

      expect(service.currentDevices, hasLength(greaterThanOrEqualTo(1)));
      final persisted = service.currentDevices.firstWhere(
        (d) => d.id == 'AA:BB:CC:DD:EE:FF',
      );
      expect(persisted.name, 'Persisted Device');
    });

    test('limits to 5 devices', () async {
      for (int i = 0; i < 6; i++) {
        final id = '00:00:00:00:00:0$i';
        final device = BluetoothDevice(remoteId: DeviceIdentifier(id));
        final result = ScanResult(
          device: device,
          advertisementData: AdvertisementData(
            advName: 'Device $i',
            txPowerLevel: null,
            connectable: true,
            manufacturerData: {},
            serviceData: {},
            serviceUuids: [],
            appearance: null,
          ),
          rssi: -50,
          timeStamp: DateTime.now(),
        );
        await service.add(result);
        // Small delay to ensure different timestamps if needed, though add() uses DateTime.now()
        await Future.delayed(const Duration(milliseconds: 10));
      }

      expect(service.currentDevices.length, lessThanOrEqualTo(5));
      // The last added (Device 5) should be first
      expect(service.currentDevices.first.name, 'Device 5');
    });
  });
}
