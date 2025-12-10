import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mesh/services/device_status_store.dart';
import 'package:mesh/services/logging_service.dart';
import 'package:mesh/meshtastic/model/meshcore_constants.dart';

// Generate mocks
@GenerateNiceMocks([
  MockSpec<BluetoothDevice>(),
  MockSpec<BluetoothService>(),
  MockSpec<BluetoothCharacteristic>(),
])
import 'device_status_store_meshcore_test.mocks.dart';

// Mock DeviceIdentifier since it's a concrete class often
class MockDeviceIdentifier extends Mock implements DeviceIdentifier {
  @override
  String get str => 'TEST_MESHCORE_ID';
  @override
  String toString() => 'TEST_MESHCORE_ID';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceStatusStore MeshCore Logging', () {
    late DeviceStatusStore store;
    late MockBluetoothDevice mockDevice;
    late MockBluetoothService mockService;
    late MockBluetoothCharacteristic mockRxChar;
    late MockBluetoothCharacteristic mockTxChar;

    setUp(() {
      store = DeviceStatusStore.instance; // Singleton
      mockDevice = MockBluetoothDevice();
      mockService = MockBluetoothService();
      mockRxChar = MockBluetoothCharacteristic();
      mockTxChar = MockBluetoothCharacteristic();

      // Setup Device ID
      when(
        mockDevice.remoteId,
      ).thenReturn(DeviceIdentifier('TEST_MESHCORE_ID'));
      when(mockDevice.platformName).thenReturn('MeshCore Device');

      // Setup Characteristics
      when(
        mockRxChar.uuid,
      ).thenReturn(Guid(MeshCoreConstants.rxCharacteristicUuid));
      when(
        mockTxChar.uuid,
      ).thenReturn(Guid(MeshCoreConstants.txCharacteristicUuid));

      // Setup TX characteristic notification
      when(mockTxChar.setNotifyValue(any)).thenAnswer((_) async => true);
      when(mockTxChar.onValueReceived).thenAnswer((_) => Stream.empty());

      // Setup Service discovery for MeshCore
      when(mockService.uuid).thenReturn(Guid(MeshCoreConstants.serviceUuid));
      when(mockService.characteristics).thenReturn([mockRxChar, mockTxChar]);
      when(
        mockDevice.discoverServices(),
      ).thenAnswer((_) async => [mockService]);

      // Setup connection streams to avoid null errors
      when(
        mockDevice.connectionState,
      ).thenAnswer((_) => Stream.value(BluetoothConnectionState.connected));
      when(
        mockDevice.bondState,
      ).thenAnswer((_) => Stream.value(BluetoothBondState.bonded));

      // Setup connect to succeed
      when(
        mockDevice.connect(
          timeout: anyNamed('timeout'),
          mtu: anyNamed('mtu'),
          autoConnect: anyNamed('autoConnect'),
          license: anyNamed('license'), // Added required named parameter
        ),
      ).thenAnswer((_) async {});
    });

    test('connect detects MeshCore and logs with correct network tag', () async {
      final logCompleter = Completer<void>();
      bool meshCoreLogFound = false;

      // Listen to logs
      final sub = LoggingService.instance.listenAll().listen((event) {
        if (event.tags['network']?.contains('meshcore') ?? false) {
          meshCoreLogFound = true;
          if (!logCompleter.isCompleted) logCompleter.complete();
        }
      });

      // Execute connect
      // We expect it might fail later during client connection/handshake because we didn't mock characteristics fully
      // But we only care about the initial detection log.
      try {
        await store.connect(mockDevice);
      } catch (_) {
        // Ignore subsequent errors (like handshake timeout)
      }

      await logCompleter.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );

      await sub.cancel();

      expect(
        meshCoreLogFound,
        isTrue,
        reason: 'Should have received a log with network=meshcore tag',
      );

      // Verify device type was stored in the entry implicitly by checking statusNow or just relying on the log validation above
      // Since _entries is private, we can't check it directly, but the log presence confirms the logic flow.
    });
  });
}
