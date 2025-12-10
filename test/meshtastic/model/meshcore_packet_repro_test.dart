import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesh/meshtastic/model/meshcore_packet.dart';

void main() {
  test('MeshCorePacket throws on 1-byte frame', () {
    // 1 byte frame: 0x00 (RouteType 0 -> Transport Flood -> expects 4 bytes transport codes)
    final frame = Uint8List.fromList([0x00]);
    expect(
      () => MeshCorePacket.fromBytes(frame),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Packet too short for transport codes',
        ),
      ),
    );
  });

  test('MeshCorePacket throws on 2-byte frame', () {
    // 2 byte frame: 0x04, 0x01
    // Header 0x04: RouteType 0 (Transport Flood), PayloadType 1 (Resp).
    // Still Transport Flood, so needs 4 bytes transport codes.
    // Let's try RouteType 1 (Flood) -> 0x01.
    // Header 0x01: RouteType 1, PayloadType 0.
    // 2nd byte is PathLen. 0x01.
    // Expects 1 byte path.
    // Total needed: 1 (header) + 1 (pathlen) + 1 (path) = 3 bytes.
    // We only provide 2 bytes.
    final frame = Uint8List.fromList([0x01, 0x01]);
    expect(
      () => MeshCorePacket.fromBytes(frame),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Packet too short for path data',
        ),
      ),
    );
  });
}
