import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/services/device_state_service.dart';
import 'package:mesh/services/device_communication_event_service.dart';
import 'package:mesh/meshtastic/model/meshtastic_event.dart';
import 'package:mesh/meshtastic/model/meshtastic_models.dart';
import 'package:mesh/models/device_state.dart';
import 'dart:async';

void main() {
  test('DeviceStateService streamWithCurrent emits initial state', () async {
    // Setup
    final service = DeviceStateService.instance;
    service.init();

    // Simulate an event to populate state
    final deviceId = 'test_device';
    final event = DeviceEvent(
      timestamp: DateTime.now(),
      tags: {
        'deviceId': [deviceId],
      },
      payload: MeshtasticDeviceEventPayload(
        ConfigEvent(ConfigDto(device: DeviceConfigDto(role: 'CLIENT'))),
      ),
    );

    // We need to inject this event into DeviceCommunicationEventService
    // But DeviceCommunicationEventService is a singleton.
    // We can use the push method if available or mock it.
    // DeviceCommunicationEventService.instance.push(...)

    DeviceCommunicationEventService.instance.push(
      tags: {'deviceId': deviceId}, // push normalizes tags to List<String>
      payload: event.payload,
    );

    // Wait for microtasks to process event
    await Future.delayed(Duration.zero);

    // Verify state is populated
    expect(service.getState(deviceId), isNotNull);
    expect(service.getState(deviceId)!.config!.device!.role, 'CLIENT');

    // Test streamWithCurrent
    final stream = service.streamWithCurrent(deviceId);

    final emittedStates = <DeviceState>[];
    final subscription = stream.listen(emittedStates.add);

    // Wait for initial emission
    await Future.delayed(Duration.zero);

    expect(emittedStates.length, 1);
    expect(emittedStates.first.config!.device!.role, 'CLIENT');

    // Simulate another event
    final event2 = DeviceEvent(
      timestamp: DateTime.now(),
      tags: {
        'deviceId': [deviceId],
      },
      payload: MeshtasticDeviceEventPayload(
        ConfigEvent(ConfigDto(device: DeviceConfigDto(role: 'ROUTER'))),
      ),
    );

    DeviceCommunicationEventService.instance.push(
      tags: {'deviceId': deviceId},
      payload: event2.payload,
    );

    await Future.delayed(Duration.zero);

    expect(emittedStates.length, 2);
    expect(emittedStates.last.config!.device!.role, 'ROUTER');

    await subscription.cancel();
    service.dispose();
  });
}
