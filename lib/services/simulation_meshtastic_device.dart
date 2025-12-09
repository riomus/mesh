import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../generated/meshtastic/meshtastic/portnums.pbenum.dart' as port;
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';
import 'meshtastic_client.dart';
import 'device_communication_event_service.dart';
import 'logging_service.dart';

import 'chatting_device.dart';

class SimulationMeshtasticDevice implements MeshtasticClient, ChattingDevice {
  final String _deviceId = 'SIM-DEVICE-001';
  final StreamController<MeshtasticEvent> _eventsController =
      StreamController<MeshtasticEvent>.broadcast();
  final StreamController<int> _rssiController =
      StreamController<int>.broadcast();

  Timer? _simulationTimer;
  bool _isConnected = false;

  SimulationMeshtasticDevice();

  @override
  String get id => _deviceId;

  @override
  String get displayName => 'Simulation Device';

  @override
  Future<int?> getMyNodeNum() async {
    return 100000001;
  }

  @override
  Future<int> sendMessage(String text, int? toId, {int? channelIndex}) async {
    _log('Simulated sending message: "$text" to $toId');

    // Create a packet to represent the sent message
    final packet = mesh.MeshPacket();
    packet.from = 100000001; // My Node
    packet.to = toId ?? 0xFFFFFFFF;
    if (channelIndex != null) packet.channel = channelIndex;

    packet.decoded = mesh.Data();
    packet.decoded.portnum = port.PortNum.TEXT_MESSAGE_APP;
    packet.decoded.payload = Uint8List.fromList(text.codeUnits);
    packet.id = Random().nextInt(0xFFFFFFFF);
    packet.rxTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    packet.hopLimit = 3;

    // In a real device, we send to radio. Here we just log it.
    // We could also emit it back as if we heard our own message (some radios do this)
    // or just rely on the UI to show pending messages.

    return packet.id;
  }

  @override
  Future<int> sendTraceroute(int targetNodeId) async {
    _log('Simulated sending traceroute to $targetNodeId');

    final packet = mesh.MeshPacket();
    packet.from = 100000001;
    packet.to = targetNodeId;
    packet.decoded = mesh.Data();
    packet.decoded.portnum = port.PortNum.TRACEROUTE_APP;
    packet.id = Random().nextInt(0xFFFFFFFF);
    packet.rxTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    packet.hopLimit = 3;

    // Trigger the simulated response
    _simulateTraceResponse(packet);

    return packet.id;
  }

  @override
  Stream<MeshtasticEvent> get events => _eventsController.stream;

  @override
  Stream<int> get rssi => _rssiController.stream;

  @override
  Future<void> connect({Duration timeout = const Duration(seconds: 20)}) async {
    _isConnected = true;
    _startSimulation();

    // Simulate initial config
    await Future.delayed(const Duration(milliseconds: 500));
    _emitConfig();
    _emitDeviceMetadata();
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _simulationTimer?.cancel();
    _eventsController.close();
    _rssiController.close();
  }

  @override
  Future<void> dispose() async {
    await disconnect();
  }

  @override
  Future<void> requestConfig() async {
    // Simulate config response
    _emitConfig();
  }

  @override
  Future<void> sendMeshPacket(mesh.MeshPacket packet) async {
    _log('Simulated sending packet: $packet');
    // Echo back or simulate response if needed
    if (packet.decoded.portnum == port.PortNum.TEXT_MESSAGE_APP) {
      // Simulate ACK if requested
      if (packet.wantAck) {
        _simulateAck(packet);
      }
    } else if (packet.decoded.portnum == port.PortNum.TRACEROUTE_APP) {
      _simulateTraceResponse(packet);
    }
  }

  @override
  Future<void> sendToRadio(mesh.ToRadio message) async {
    _log('Simulated sending ToRadio: $message');
    if (message.hasPacket()) {
      await sendMeshPacket(message.packet);
    }
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isConnected) return;

      // Randomly emit RSSI
      _rssiController.add(-50 - Random().nextInt(40));

      // Randomly emit chat messages or other events
      final rand = Random().nextDouble();
      if (rand < 0.2) {
        _simulateIncomingMessage();
      } else if (rand < 0.4) {
        _emitLogRecord();
      } else if (rand < 0.5) {
        _emitTelemetry();
      }
    });

    // Emit some initial nodes
    _emitNodeInfo(123456789, 'SimNode A', 'A');
    _emitNodeInfo(987654321, 'SimNode B', 'B');
    _emitNodeInfo(112233445, 'SimNode C', 'C');
  }

  void _emitConfig() {
    // My Info
    final myInfo = MyInfoDto(
      myNodeNum: 100000001,
      minAppVersion: 20000,
      firmwareEdition: 'SIMULATION',
    );
    _emitEvent(MyInfoEvent(myInfo));

    // Device Config
    final deviceConfig = DeviceConfigDto(role: 'CLIENT');
    final loraConfig = LoRaConfigDto(region: 'US', hopLimit: 3);

    final config = ConfigDto(device: deviceConfig, lora: loraConfig);
    _emitEvent(ConfigEvent(config));

    // Config Complete
    _emitEvent(ConfigCompleteEvent(0));
  }

  void _emitNodeInfo(int num, String longName, String shortName) {
    final node = NodeInfoDto(
      num: num,
      user: UserDto(
        id: '!$num',
        longName: longName,
        shortName: shortName,
        macaddr: Uint8List.fromList([0, 1, 2, 3, 4, 5]),
        hwModel: 'TBEAM',
      ),
      position: PositionDto(
        latitudeI: 377749295,
        longitudeI: -1224194155,
        altitude: 100,
      ),
      snr: 10.0,
      lastHeard: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    _emitEvent(NodeInfoEvent(node));
  }

  void _simulateIncomingMessage() {
    final text = 'Hello from SimNode B! ${DateTime.now()}';
    final packetDto = MeshPacketDto(
      from: 987654321, // SimNode B
      to: 0xFFFFFFFF, // Broadcast
      id: Random().nextInt(0xFFFFFFFF),
      rxTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      hopLimit: 3,
      decoded: TextPayloadDto(text),
    );

    _emitEvent(
      MeshPacketEvent(packet: packetDto, decoded: TextPayloadDto(text)),
    );
  }

  void _simulateAck(mesh.MeshPacket originalPacket) {
    // TODO: Implement ACK simulation
  }

  void _simulateTraceResponse(mesh.MeshPacket originalPacket) {
    // Simulate a response after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      final route = [
        123456789,
        112233445,
        987654321,
      ]; // Node A -> Node C -> Node B
      final snr = [10, 8, 12];

      final tracerouteDto = TraceroutePayloadDto(
        route: route,
        snrTowards: snr,
        routeBack: route.reversed.toList(),
        snrBack: snr.reversed.toList(),
      );

      final packetDto = MeshPacketDto(
        from: originalPacket.to, // Response comes from the target
        to: originalPacket
            .from, // Back to us (though we are 0xFFFFFFFF in sim usually)
        id: Random().nextInt(0xFFFFFFFF),
        rxTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        hopLimit: 3,
        decoded: tracerouteDto,
      );

      _emitEvent(MeshPacketEvent(packet: packetDto, decoded: tracerouteDto));
    });
  }

  void _emitLogRecord() {
    final levels = ['INFO', 'WARN', 'ERROR', 'DEBUG'];
    final messages = [
      'Packet received from LoRa',
      'Battery level low',
      'Mesh path recomputed',
      'Bluetooth connection unstable',
      'GPS fix acquired',
      'Node 123456789 went offline',
    ];

    final level = levels[Random().nextInt(levels.length)];
    final message = messages[Random().nextInt(messages.length)];

    final logRecord = LogRecordDto(
      level: level,
      message: message,
      source: 'SimFirmware',
    );

    _emitEvent(LogRecordEvent(logRecord));
  }

  void _emitTelemetry() {
    final telemetry = TelemetryPayloadDto(
      time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      deviceMetrics: DeviceMetricsDto(
        batteryLevel: 50 + Random().nextInt(50),
        voltage: 3.7 + Random().nextDouble() * 0.5,
        channelUtilization: Random().nextDouble() * 10,
        airUtilTx: Random().nextDouble() * 5,
      ),
      environmentMetrics: EnvironmentMetricsDto(
        temperature: 20 + Random().nextDouble() * 10,
        relativeHumidity: 40 + Random().nextDouble() * 20,
        barometricPressure: 1013 + Random().nextDouble() * 10,
      ),
    );

    // Telemetry is usually sent as a packet from a node
    // Let's say it comes from our own device for now, or one of the sim nodes
    final packetDto = MeshPacketDto(
      from: 100000001, // My Node
      to: 0xFFFFFFFF,
      id: Random().nextInt(0xFFFFFFFF),
      rxTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      decoded: telemetry,
    );

    _emitEvent(MeshPacketEvent(packet: packetDto, decoded: telemetry));
  }

  void _emitDeviceMetadata() {
    final metadata = DeviceMetadataDto(
      firmwareVersion: '2.5.0.sim',
      deviceStateVersion: 1,
      canShutdown: true,
      hasWifi: true,
      hasBluetooth: true,
      hasEthernet: false,
      role: 'CLIENT',
      positionFlags: 3,
      hwModel: 'TBEAM',
      hasRemoteHardware: false,
    );
    _emitEvent(DeviceMetadataEvent(metadata));
  }

  void _emitEvent(MeshtasticEvent event) {
    _eventsController.add(event);
    DeviceCommunicationEventService.instance.pushMeshtastic(
      event: event,
      deviceId: _deviceId,
      summary: event.runtimeType.toString(),
    );
  }

  void _log(String msg) {
    LoggingService.instance.push(
      tags: {'class': 'SimulationMeshtasticDevice', 'deviceId': _deviceId},
      level: 'info',
      message: msg,
    );
  }
}
