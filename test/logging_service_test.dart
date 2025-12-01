import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/services/logging_service.dart';

void main() {
  group('LoggingService', () {
    final log = LoggingService.instance;

    test('listenAll receives pushed events', () async {
      final future = expectLater(
        log.listenAll(),
        emits(predicate<LogEvent>((e) =>
            (e.tags['module']?.contains('scanner') ?? false) && e.level == 'info' && e.message == 'started')),
      );

      // Ensure subscription is active before pushing
      await Future<void>.delayed(Duration.zero);
      log.push(tags: {'module': 'scanner'}, level: 'info', message: 'started');

      await future;
    });

    test('filter by key=value only', () async {
      final future = expectLater(
        log.listen(key: 'module', value: 'ble'),
        emits(predicate<LogEvent>((e) => (e.tags['module']?.contains('ble') ?? false) && e.level == 'warn')),
      );

      await Future<void>.delayed(Duration.zero);
      log.push(tags: {'module': 'ui'}, level: 'warn', message: 'ignore');
      log.push(tags: {'module': 'ble'}, level: 'warn', message: 'timeout');

      await future;
    });

    test('filter by level only', () async {
      final future = expectLater(
        log.listen(level: 'error'),
        emits(predicate<LogEvent>((e) => e.level == 'error' && (e.tags['module']?.contains('db') ?? false))),
      );

      await Future<void>.delayed(Duration.zero);
      log.push(tags: {'module': 'db'}, level: 'info', message: 'ignore');
      log.push(tags: {'module': 'db'}, level: 'error', message: 'boom');

      await future;
    });

    test('filter by key=value and level', () async {
      final future = expectLater(
        log.listen(key: 'module', value: 'auth', level: 'debug'),
        emits(predicate<LogEvent>((e) => (e.tags['module']?.contains('auth') ?? false) && e.level == 'debug')),
      );

      await Future<void>.delayed(Duration.zero);
      log.push(tags: {'module': 'auth'}, level: 'info', message: 'ignore');
      log.push(tags: {'module': 'auth'}, level: 'debug', message: 'token parsed');

      await future;
    });

    test('multi-tag (structured): match by a single key=value', () async {
      final future = expectLater(
        log.listen(key: 'deviceId', value: 'dev-123'),
        emits(predicate<LogEvent>((e) =>
            (e.tags['network']?.contains('meshtastic') ?? false) && (e.tags['deviceId']?.contains('dev-123') ?? false))),
      );

      await Future<void>.delayed(Duration.zero);
      log.push(tags: {'network': 'meshtastic', 'deviceId': 'dev-999'}, level: 'info', message: 'ignore');
      log.push(tags: {'network': 'meshtastic', 'deviceId': 'dev-123'}, level: 'info', message: 'hello');

      await future;
    });

    test('multi-tag (structured): must match allEquals', () async {
      final future = expectLater(
        log.listen(allEquals: {'network': 'meshtastic', 'deviceId': 'dev-xyz'}),
        emits(predicate<LogEvent>((e) =>
            (e.tags['network']?.contains('meshtastic') ?? false) && (e.tags['deviceId']?.contains('dev-xyz') ?? false))),
      );

      await Future<void>.delayed(Duration.zero);
      log.push(tags: {'network': 'meshtastic'}, level: 'info', message: 'ignore');
      log.push(tags: {'network': 'other', 'deviceId': 'dev-xyz'}, level: 'info', message: 'ignore');
      log.push(tags: {'network': 'meshtastic', 'deviceId': 'dev-xyz'}, level: 'info', message: 'hit');

      await future;
    });
  });
}
