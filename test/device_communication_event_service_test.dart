import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/services/device_communication_event_service.dart';

void main() {
  group('DeviceCommunicationEventService', () {
    final svc = DeviceCommunicationEventService.instance;

    setUp(() {
      svc.clear();
    });

    test('listenAll receives pushed events', () async {
      final future = expectLater(
        svc.listenAll(),
        emits(predicate<DeviceEvent>((e) =>
            (e.tags['network']?.contains('meshtastic') ?? false) &&
            (e.tags['deviceId']?.contains('dev-1') ?? false) &&
            e.summary == 'joined')),
      );

      await Future<void>.delayed(Duration.zero);
      svc.push(tags: {'network': 'meshtastic', 'deviceId': 'dev-1'}, summary: 'joined');

      await future;
    });

    test('filter by key=value only', () async {
      final future = expectLater(
        svc.listen(key: 'deviceId', value: 'dev-2'),
        emits(predicate<DeviceEvent>((e) => (e.tags['deviceId']?.contains('dev-2') ?? false))),
      );

      await Future<void>.delayed(Duration.zero);
      svc.push(tags: {'deviceId': 'dev-1'}, summary: 'ignore');
      svc.push(tags: {'deviceId': 'dev-2'}, summary: 'hit');

      await future;
    });

    test('allEquals requires all match', () async {
      final future = expectLater(
        svc.listen(allEquals: {'network': 'meshtastic', 'deviceId': 'dev-xyz'}),
        emits(predicate<DeviceEvent>((e) =>
            (e.tags['network']?.contains('meshtastic') ?? false) &&
            (e.tags['deviceId']?.contains('dev-xyz') ?? false))),
      );

      await Future<void>.delayed(Duration.zero);
      svc.push(tags: {'network': 'meshtastic'}, summary: 'ignore');
      svc.push(tags: {'network': 'meshtastic', 'deviceId': 'dev-xyz'}, summary: 'hit');

      await future;
    });

    test('listenWithReplay replays buffer that matches filter', () async {
      // Prepare buffer
      svc.push(tags: {'deviceId': 'dev-1'}, summary: 'pre');
      svc.push(tags: {'deviceId': 'dev-2'}, summary: 'pre');

      final collected = <DeviceEvent>[];
      final sub = svc
          .listenWithReplay(key: 'deviceId', value: 'dev-2')
          .listen(collected.add);

      // Also push a live matching event
      await Future<void>.delayed(Duration.zero);
      svc.push(tags: {'deviceId': 'dev-2'}, summary: 'live');

      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();

      expect(collected.where((e) => e.tags['deviceId']?.contains('dev-2') ?? false).length, greaterThanOrEqualTo(2));
    });
  });
}
