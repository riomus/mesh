import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mesh/services/meshcore_ble_client.dart';
import 'package:mesh/meshtastic/model/meshtastic_event.dart';
import 'package:mesh/meshtastic/model/meshcore_constants.dart';
import 'package:mesh/meshtastic/model/meshtastic_models.dart';

// Reuse existing mocks generated for MeshCore tests
import 'device_status_store_meshcore_test.mocks.dart';

class MockDeviceIdentifier extends Mock implements DeviceIdentifier {
  @override
  String get str => 'TEST_MESHCORE_ID';
  @override
  String toString() => 'TEST_MESHCORE_ID';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MeshCoreBleClient Event Emission', () {
    late MeshCoreBleClient client;
    late MockBluetoothDevice mockDevice;
    late MockBluetoothService mockService;
    late MockBluetoothCharacteristic mockRxChar;
    late MockBluetoothCharacteristic mockTxChar;
    late StreamController<List<int>> txNotifyController;

    setUp(() {
      mockDevice = MockBluetoothDevice();
      mockService = MockBluetoothService();
      mockRxChar = MockBluetoothCharacteristic();
      mockTxChar = MockBluetoothCharacteristic();
      txNotifyController = StreamController<List<int>>.broadcast();

      when(
        mockDevice.remoteId,
      ).thenReturn(DeviceIdentifier('TEST_MESHCORE_ID'));
      when(mockDevice.platformName).thenReturn('MeshCore Device');

      when(
        mockRxChar.uuid,
      ).thenReturn(Guid(MeshCoreConstants.rxCharacteristicUuid));
      when(
        mockTxChar.uuid,
      ).thenReturn(Guid(MeshCoreConstants.txCharacteristicUuid));

      when(
        mockTxChar.onValueReceived,
      ).thenAnswer((_) => txNotifyController.stream);
      when(mockTxChar.setNotifyValue(any)).thenAnswer((_) async => true);

      when(mockService.uuid).thenReturn(Guid(MeshCoreConstants.serviceUuid));
      when(mockService.characteristics).thenReturn([mockRxChar, mockTxChar]);
      when(
        mockDevice.discoverServices(),
      ).thenAnswer((_) async => [mockService]);

      when(
        mockDevice.connectionState,
      ).thenAnswer((_) => Stream.value(BluetoothConnectionState.connected));
      when(
        mockDevice.bondState,
      ).thenAnswer((_) => Stream.value(BluetoothBondState.bonded));
      when(
        mockDevice.connect(
          timeout: anyNamed('timeout'),
          mtu: anyNamed('mtu'),
          autoConnect: anyNamed('autoConnect'),
          license: anyNamed('license'),
        ),
      ).thenAnswer((_) async {});

      client = MeshCoreBleClient(mockDevice);
    });

    tearDown(() {
      txNotifyController.close();
      client.dispose();
    });

    Future<void> simulateHandshake() async {
      // Simulate response to CMD_DEVICE_QUERY
      Future.delayed(const Duration(milliseconds: 100), () {
        txNotifyController.add(
          Uint8List.fromList([MeshCoreConstants.respDeviceInfo]),
        );
      });
      // Simulate response to CMD_APP_START
      Future.delayed(const Duration(milliseconds: 200), () {
        txNotifyController.add(
          Uint8List.fromList([MeshCoreConstants.respSelfInfo]),
        );
      });
    }

    test('Emit MyInfoEvent and NodeInfoEvent during Handshake', () async {
      // Start connection which triggers handshake
      final connectFuture = client.connect();
      simulateHandshake();

      // We expect 3 events in total from handshake:
      // 1. MyInfoEvent (from RESP_DEVICE_INFO)
      // 2. NodeInfoEvent (from RESP_SELF_INFO)
      // 3. ConfigCompleteEvent (end of handshake)

      final events = <MeshtasticEvent>[];
      final subscription = client.events.listen(events.add);

      await connectFuture;
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Wait for events
      await subscription.cancel();

      expect(events.whereType<MyInfoEvent>(), isNotEmpty);
      expect(events.whereType<NodeInfoEvent>(), isNotEmpty);
      expect(events.whereType<ConfigCompleteEvent>(), isNotEmpty);
    });

    test('Emit MeshPacketEvent on Text Message', () async {
      simulateHandshake();
      await client.connect();

      // Construct Text Message Packet
      // Header: PayloadType=0x02 (TxtMsg), RouteType=0x01 (Flood) -> 0x09
      final headerByte = 0x09;

      // Path: Sender=0xAA, Dest=0xBB
      final pathBytes = [0xAA, 0xBB];

      // Payload: Text Message
      final buffer = BytesBuilder();
      // Timestamp (4 bytes)
      buffer.add(Uint8List(4));
      // TxtType + Attempt (1 byte) -> 0
      buffer.addByte(0);
      // Message
      buffer.add('Hello MeshCore'.codeUnits);
      final payloadBytes = buffer.toBytes();

      final packetBuilder = BytesBuilder();
      packetBuilder.addByte(headerByte);
      // No Transport Codes
      packetBuilder.addByte(pathBytes.length);
      packetBuilder.add(Uint8List.fromList(pathBytes));
      packetBuilder.add(payloadBytes);

      final packetData = packetBuilder.toBytes();

      // Expect event
      final futureEvent = client.events.firstWhere((e) => e is MeshPacketEvent);

      // Inject packet
      txNotifyController.add(packetData);

      final event = await futureEvent as MeshPacketEvent;
      expect(event.packet.decoded, isA<TextPayloadDto>());
      expect((event.packet.decoded as TextPayloadDto).text, 'Hello MeshCore');
      expect(event.packet.from, 0xAA);
      expect(event.packet.to, 0xBB);
    });

    test('Emit NodeInfoEvent on Advertisement', () async {
      simulateHandshake();
      await client.connect();

      // Header: PayloadType=0x04 (Advert), RouteType=0x01 (Flood) -> 0x11
      // (Advert=4 -> 0100 -> <<2 = 0001 0000 = 16 = 0x10)
      // RouteType=1 -> 0x01
      // Total = 0x11
      final headerByte = 0x11;

      final pathBytes = [0xCC];

      // Mock Advert Payload (format undefined in constants, sending dummy bytes)
      final payloadBytes = Uint8List(10);

      final packetBuilder = BytesBuilder();
      packetBuilder.addByte(headerByte);
      packetBuilder.addByte(pathBytes.length);
      packetBuilder.add(Uint8List.fromList(pathBytes));
      packetBuilder.add(payloadBytes);

      final packetData = packetBuilder.toBytes();

      final futureEvent = client.events.firstWhere((e) => e is NodeInfoEvent);

      txNotifyController.add(packetData);

      final event = await futureEvent as NodeInfoEvent;
      expect(event.nodeInfo.num, 0xCC);
      expect(event.nodeInfo.user?.shortName, contains('cc'));
    });
  });
}
