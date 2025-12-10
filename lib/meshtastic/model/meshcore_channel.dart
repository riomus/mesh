import 'dart:typed_data';
import 'meshcore_constants.dart';

/// Represents a MeshCore channel configuration
///
/// Channels in MeshCore consist of:
/// - Index (0-7): Channel slot number
/// - Name (32 bytes): Human-readable channel name
/// - PSK (16 bytes): Pre-shared key for encryption
class MeshCoreChannel {
  final int index;
  final String name;
  final Uint8List psk;

  const MeshCoreChannel({
    required this.index,
    required this.name,
    required this.psk,
  });

  /// Parse a MeshCore channel from RESP_CODE_CHANNEL_INFO response
  ///
  /// Expected format:
  /// - Byte 0: RESP_CODE_CHANNEL_INFO (0x12)
  /// - Byte 1: Channel index
  /// - Bytes 2-33: Channel name (32 bytes, null-terminated)
  /// - Bytes 34-49: PSK (16 bytes)
  factory MeshCoreChannel.fromBytes(Uint8List data) {
    if (data.length <
        2 +
            MeshCoreConstants.channelNameLength +
            MeshCoreConstants.channelPskLength) {
      throw ArgumentError(
        'Invalid channel data length: ${data.length}, expected at least '
        '${2 + MeshCoreConstants.channelNameLength + MeshCoreConstants.channelPskLength}',
      );
    }

    final index = data[1];

    // Parse name (32 bytes, null-terminated)
    final nameBytes = data.sublist(2, 2 + MeshCoreConstants.channelNameLength);
    final nullIndex = nameBytes.indexOf(0);
    final actualNameBytes = nullIndex != -1
        ? nameBytes.sublist(0, nullIndex)
        : nameBytes;
    final name = String.fromCharCodes(actualNameBytes);

    // Parse PSK (16 bytes)
    final pskStart = 2 + MeshCoreConstants.channelNameLength;
    final psk = data.sublist(
      pskStart,
      pskStart + MeshCoreConstants.channelPskLength,
    );

    return MeshCoreChannel(index: index, name: name, psk: psk);
  }

  /// Serialize channel for CMD_SET_CHANNEL command
  ///
  /// Format:
  /// - Byte 0: CMD_SET_CHANNEL (0x20)
  /// - Byte 1: Channel index
  /// - Bytes 2-33: Channel name (32 bytes, null-padded)
  /// - Bytes 34-49: PSK (16 bytes)
  Uint8List toBytes() {
    final buffer = BytesBuilder();

    // Command byte
    buffer.addByte(MeshCoreConstants.cmdSetChannel);

    // Index
    buffer.addByte(index);

    // Name (32 bytes, null-padded)
    final nameBytes = Uint8List(MeshCoreConstants.channelNameLength);
    final encoded = name.codeUnits;
    final copyLen = encoded.length < MeshCoreConstants.channelNameLength
        ? encoded.length
        : MeshCoreConstants.channelNameLength;
    nameBytes.setRange(0, copyLen, encoded);
    buffer.add(nameBytes);

    // PSK (16 bytes)
    if (psk.length != MeshCoreConstants.channelPskLength) {
      throw ArgumentError(
        'PSK must be ${MeshCoreConstants.channelPskLength} bytes, got ${psk.length}',
      );
    }
    buffer.add(psk);

    return buffer.toBytes();
  }

  /// Create a copy with modified fields
  MeshCoreChannel copyWith({int? index, String? name, Uint8List? psk}) {
    return MeshCoreChannel(
      index: index ?? this.index,
      name: name ?? this.name,
      psk: psk ?? this.psk,
    );
  }

  @override
  String toString() {
    return 'MeshCoreChannel(index: $index, name: "$name", psk: ${psk.length} bytes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MeshCoreChannel) return false;

    return index == other.index &&
        name == other.name &&
        _bytesEqual(psk, other.psk);
  }

  @override
  int get hashCode => Object.hash(index, name, psk.hashCode);

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
