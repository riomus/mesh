import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';
import 'logging_service.dart';
import 'device_communication_event_service.dart';

class TelemetryService {
  static final TelemetryService _instance = TelemetryService._internal();
  static TelemetryService get instance => _instance;

  // In-memory history: deviceId -> List of TelemetryPayloadDto
  final Map<String, List<TelemetryPayloadDto>> _history = {};
  final _historyController = StreamController<String>.broadcast();

  TelemetryService._internal();

  void init() {
    DeviceCommunicationEventService.instance.listenAll().listen(
      _onEvent,
      onError: (e) {
        LoggingService.instance.push(
          tags: {'service': 'TelemetryService'},
          level: 'error',
          message: 'Error in event stream: $e',
        );
      },
    );
  }

  void _onEvent(DeviceEvent deviceEvent) {
    try {
      final payload = deviceEvent.payload;
      if (payload is MeshtasticDeviceEventPayload) {
        final event = payload.event;
        if (event is MeshPacketEvent) {
          final decoded = event.decoded;
          if (decoded is TelemetryPayloadDto) {
            final deviceId = event.id; // This might be null or not the node ID?
            // Wait, MeshPacketEvent.id is the BLE device ID (remoteId).
            // But telemetry comes from a specific node in the mesh.
            // We should probably index by the 'from' node ID in the packet.

            final fromNode = event.packet.from;
            if (fromNode != null && deviceId != null) {
              // We'll use a composite key or just the node ID?
              // The UI usually looks at a BLE device.
              // But a BLE device can see packets from other nodes.
              // Let's store by node ID (int) for now, but we need to map it to the UI.
              // Actually, the requirement is "gather devices telemetry data - and show them in device details screen".
              // Device details screen is for the CONNECTED BLE device.
              // But that device might be a relay for others.
              // However, usually "Device Details" implies the details of the connected radio itself.
              // If the packet is from the connected radio (from == myNodeNum or similar), we show it.
              // Or maybe we just show ALL telemetry heard?
              // Let's stick to the connected device's telemetry for the "Device Details" page.
              // But wait, the packet 'from' is an int. The device details page knows the BLE ID.
              // We need to know the nodeNum of the connected device.
              // We can get that from MyInfo or NodeInfo.

              // For now, let's just store it by node ID.
              final key = fromNode.toString();
              _history.putIfAbsent(key, () => []);
              _history[key]!.add(decoded);
              // Limit history size
              if (_history[key]!.length > 100) {
                _history[key]!.removeAt(0);
              }
              _historyController.add(key);

              LoggingService.instance.push(
                tags: {'service': 'TelemetryService'},
                level: 'info',
                message:
                    'Received telemetry from $fromNode: ${decoded.variant}',
              );
            }
          }
        }
      }
    } catch (e, s) {
      LoggingService.instance.push(
        tags: {'service': 'TelemetryService'},
        level: 'error',
        message: 'Error processing telemetry event: $e',
      );
    }
  }

  List<TelemetryPayloadDto> getHistory(int nodeId) {
    return _history[nodeId.toString()] ?? [];
  }

  Stream<List<TelemetryPayloadDto>> historyStream(int nodeId) {
    return _historyController.stream
        .where((key) => key == nodeId.toString())
        .map((_) => getHistory(nodeId))
        .startWith(getHistory(nodeId));
  }
}
