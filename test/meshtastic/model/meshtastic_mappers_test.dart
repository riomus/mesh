import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/meshtastic/model/meshtastic_mappers.dart';
import 'package:mesh/meshtastic/model/meshtastic_event.dart';
import 'package:mesh/generated/meshtastic/meshtastic/channel.pb.dart'
    as channel;
import 'package:mesh/generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;

void main() {
  group('MeshtasticMappers', () {
    test('ChannelDto index defaults to 0 when missing', () {
      // Create a Channel protobuf with no index set (default is 0 in proto3, but hasIndex() will be false)
      final protoChannel = channel.Channel();
      // Verify hasIndex is false (standard proto3 behavior for default values)
      expect(protoChannel.hasIndex(), isFalse);

      final fr = mesh.FromRadio()..channel = protoChannel;

      final event = MeshtasticMappers.fromFromRadio(fr);

      expect(event, isA<ChannelEvent>());
      expect((event as ChannelEvent).channel.index, equals(0));
    });
  });
}
