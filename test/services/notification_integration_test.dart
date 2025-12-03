import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/meshtastic/model/meshtastic_event.dart';
import 'package:mesh/meshtastic/model/meshtastic_models.dart';
import 'package:mesh/services/device_communication_event_service.dart';
import 'package:mesh/services/message_routing_service.dart';
import 'package:mesh/services/notification_service.dart';
import 'package:mockito/mockito.dart';

class MockNotificationService extends Mock implements NotificationService {
  @override
  Future<void> showNotification(
    int? id,
    String? title,
    String? body,
    String? payload,
  ) async {
    return super.noSuchMethod(
      Invocation.method(#showNotification, [id, title, body, payload]),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}

void main() {
  late MessageRoutingService service;
  late MockNotificationService mockNotificationService;

  setUp(() {
    service = MessageRoutingService.instance;
    mockNotificationService = MockNotificationService();
    service.notificationService = mockNotificationService;
  });

  test('showNotification is called when a new message is received', () async {
    // 1. Setup listener (MessageRoutingService listens in constructor)
    // We need to ensure the listener is active. The singleton instance is created once.
    // If tests run in parallel or sequence, we might need to be careful.
    // But MessageRoutingService subscribes in constructor.

    // 2. Simulate incoming message event
    final packet = MeshPacketDto(
      from: 123,
      to: 456,
      id: 999,
      rxTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      // type and payloadVariant are not in MeshPacketDto, they are likely inferred or not needed for this DTO
      // checking MeshPacketDto definition again, it has 'decoded' field but not type/payloadVariant directly as strings usually
      // The event wrapper handles decoding.
    );

    final textPayload = TextPayloadDto('Hello World');

    final event = MeshPacketEvent(packet: packet, decoded: textPayload);
    DeviceCommunicationEventService.instance.pushMeshtastic(
      event: event,
      deviceId: 'device1',
    );

    // 3. Wait for stream processing
    await Future.delayed(const Duration(milliseconds: 100));

    // 4. Verify notification
    verify(
      mockNotificationService.showNotification(
        999,
        'New Message',
        'Hello World',
        any,
      ),
    ).called(1);
  });
}
