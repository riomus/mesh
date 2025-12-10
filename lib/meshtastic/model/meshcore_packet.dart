import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'meshcore_constants.dart';

/// Represents a parsed MeshCore packet header
class MeshCorePacketHeader {
  final int routeType;
  final int payloadType;
  final int payloadVersion;

  const MeshCorePacketHeader({
    required this.routeType,
    required this.payloadType,
    required this.payloadVersion,
  });

  /// Parse header byte into components
  factory MeshCorePacketHeader.fromByte(int headerByte) {
    return MeshCorePacketHeader(
      routeType: headerByte & MeshCoreConstants.routeTypeMask,
      payloadType: (headerByte & MeshCoreConstants.payloadTypeMask) >> 2,
      payloadVersion: (headerByte & MeshCoreConstants.payloadVersionMask) >> 6,
    );
  }

  /// Convert header components to byte
  int toByte() {
    return (routeType & 0x03) |
        ((payloadType & 0x0F) << 2) |
        ((payloadVersion & 0x03) << 6);
  }

  /// Check if this packet uses transport codes
  bool get hasTransportCodes =>
      routeType == MeshCoreConstants.routeTypeTransportFlood ||
      routeType == MeshCoreConstants.routeTypeTransportDirect;

  @override
  String toString() {
    return 'MeshCorePacketHeader(routeType: $routeType, payloadType: $payloadType, version: $payloadVersion)';
  }
}

/// Represents a complete MeshCore packet
class MeshCorePacket {
  final MeshCorePacketHeader header;
  final List<int>? transportCodes; // 4 bytes if present
  final Uint8List path;
  final Uint8List payload;

  const MeshCorePacket({
    required this.header,
    this.transportCodes,
    required this.path,
    required this.payload,
  });

  /// Helper to convert bytes to hex string for debugging
  static String _toHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }

  /// Parse a complete packet from bytes
  factory MeshCorePacket.fromBytes(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw ArgumentError('Packet bytes cannot be empty');
    }

    int offset = 0;

    // Parse header
    final header = MeshCorePacketHeader.fromByte(bytes[offset++]);

    // Parse transport codes if present
    List<int>? transportCodes;
    if (header.hasTransportCodes) {
      if (bytes.length < offset + 4) {
        throw ArgumentError(
          'Packet too short for transport codes: expected ${offset + 4} bytes, got ${bytes.length}. '
          'Hex: ${_toHex(bytes)}',
        );
      }
      transportCodes = bytes.sublist(offset, offset + 4);
      offset += 4;
    }

    // Parse path length
    if (bytes.length < offset + 1) {
      throw ArgumentError(
        'Packet too short for path length: expected ${offset + 1} bytes, got ${bytes.length}. '
        'Hex: ${_toHex(bytes)}',
      );
    }
    final pathLen = bytes[offset++];

    // Note: Path length validation is intentionally omitted here.
    // The 64-byte limit (MAX_PATH_SIZE) only applies to radio transmission.
    // Over Bluetooth, packets can be up to 172 bytes (MAX_FRAME_SIZE),
    // allowing for longer paths. The device handles chunking automatically.
    // We rely on the total frame size validation instead.

    // Parse path
    if (bytes.length < offset + pathLen) {
      throw ArgumentError(
        'Packet too short for path data: expected ${offset + pathLen} bytes, got ${bytes.length}. '
        'Path length field: $pathLen, offset: $offset. Hex: ${_toHex(bytes)}',
      );
    }
    final path = Uint8List.fromList(bytes.sublist(offset, offset + pathLen));
    offset += pathLen;

    // Remaining bytes are payload
    final payload = Uint8List.fromList(bytes.sublist(offset));

    return MeshCorePacket(
      header: header,
      transportCodes: transportCodes,
      path: path,
      payload: payload,
    );
  }

  /// Convert packet to bytes
  Uint8List toBytes() {
    final buffer = BytesBuilder();

    // Add header
    buffer.addByte(header.toByte());

    // Add transport codes if present
    if (transportCodes != null) {
      buffer.add(transportCodes!);
    }

    // Add path length and path
    buffer.addByte(path.length);
    buffer.add(path);

    // Add payload
    buffer.add(payload);

    return buffer.toBytes();
  }

  @override
  String toString() {
    return 'MeshCorePacket(header: $header, pathLen: ${path.length}, payloadLen: ${payload.length})';
  }
}

/// Represents a plain text message (payload type 0x02)
class MeshCoreTextMessage {
  final int timestamp; // Unix timestamp
  final int txtType; // Upper 6 bits
  final int attempt; // Lower 2 bits (0-3)
  final String message;

  const MeshCoreTextMessage({
    required this.timestamp,
    required this.txtType,
    required this.attempt,
    required this.message,
  });

  /// Parse text message from payload bytes
  factory MeshCoreTextMessage.fromPayload(Uint8List payload) {
    // According to MeshCore protocol, text message payloads have this structure:
    // | dest_hash (1) | src_hash (1) | MAC (2) | ciphertext (timestamp + flags + message) |
    //
    // The ciphertext portion is encrypted with AES128 and contains:
    // - timestamp (4 bytes, little-endian)
    // - txt_type + attempt flags (1 byte)
    // - message text (variable length, null-terminated)
    //
    // Since we don't have the shared secret for decryption, we attempt to extract
    // any readable text by looking for null-terminated strings in the encrypted data.
    // This is a workaround until proper decryption is implemented.

    const headerSize = 4; // dest_hash (1) + src_hash (1) + MAC (2)

    if (payload.length < headerSize + 5) {
      throw ArgumentError(
        'Text message payload too short: ${payload.length} bytes',
      );
    }

    // The encrypted portion starts after the header
    final encryptedData = payload.sublist(headerSize);

    // Without decryption, the timestamp and flags will be garbage.
    // We'll set defaults and try to extract the text message if possible.
    var timestamp = 0;
    var txtType = 0;
    var attempt = 0;
    var message = '';

    // Try to find readable text in the encrypted data
    // Look for sequences that could be text (printable ASCII)
    final messageBytes = <int>[];
    var foundText = false;

    for (var i = 5; i < encryptedData.length; i++) {
      final byte = encryptedData[i];

      // Check if this byte is printable ASCII or common punctuation
      if ((byte >= 0x20 && byte <= 0x7E) || byte == 0) {
        if (!foundText && byte != 0) {
          foundText = true;
        }
        if (byte == 0) {
          // Null terminator found
          if (foundText) break;
        } else {
          messageBytes.add(byte);
        }
      } else if (foundText) {
        // We found text before but now hit non-printable, might still be padding
        // Only break if we've found reasonable text already
        if (messageBytes.length > 3) {
          break;
        }
      }
    }

    if (messageBytes.isNotEmpty) {
      message = String.fromCharCodes(messageBytes);
    } else {
      // Fallback: just show the entire encrypted portion as hex for debugging
      message =
          '[ENCRYPTED: ${encryptedData.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}]';
    }

    return MeshCoreTextMessage(
      timestamp: timestamp,
      txtType: txtType,
      attempt: attempt,
      message: message,
    );
  }

  /// Convert text message to payload bytes
  Uint8List toPayload() {
    final buffer = BytesBuilder();

    // Write timestamp (little-endian)
    final timestampBytes = Uint8List(4);
    ByteData.view(timestampBytes.buffer).setUint32(0, timestamp, Endian.little);
    buffer.add(timestampBytes);

    // Write txt_type + attempt
    final txtTypeAttempt = ((txtType & 0x3F) << 2) | (attempt & 0x03);
    buffer.addByte(txtTypeAttempt);

    // Write message
    buffer.add(message.codeUnits);

    return buffer.toBytes();
  }

  @override
  String toString() {
    return 'MeshCoreTextMessage(timestamp: $timestamp, txtType: $txtType, attempt: $attempt, message: "$message")';
  }
}

/// Represents a group/channel text message (payload type 0x05)
/// Format: timestamp (4 bytes) + "name: message" (UTF-8 text)
class MeshCoreGroupTextMessage {
  final int timestamp; // Unix timestamp
  final String senderName;
  final String message;

  const MeshCoreGroupTextMessage({
    required this.timestamp,
    required this.senderName,
    required this.message,
  });

  /// Parse group text message from payload bytes (after decryption)
  factory MeshCoreGroupTextMessage.fromPayload(Uint8List payload) {
    if (payload.length < 5) {
      throw ArgumentError(
        'Group text message payload too short: ${payload.length} bytes',
      );
    }

    // Read 4-byte timestamp (little-endian)
    final timestamp = ByteData.sublistView(
      payload,
      0,
      4,
    ).getUint32(0, Endian.little);

    // Remaining bytes are "name: message" format
    final textContent = String.fromCharCodes(payload.sublist(4));

    // Parse "name: message" format
    final colonIndex = textContent.indexOf(': ');
    final senderName = colonIndex != -1
        ? textContent.substring(0, colonIndex)
        : 'Unknown';
    final message = colonIndex != -1
        ? textContent.substring(colonIndex + 2)
        : textContent;

    return MeshCoreGroupTextMessage(
      timestamp: timestamp,
      senderName: senderName,
      message: message,
    );
  }

  /// Convert group text message to payload bytes (before encryption)
  /// Format: timestamp (4 bytes, little-endian) + "name: message"
  Uint8List toPayload() {
    final buffer = BytesBuilder();

    // Write timestamp (little-endian)
    final timestampBytes = Uint8List(4);
    ByteData.view(timestampBytes.buffer).setUint32(0, timestamp, Endian.little);
    buffer.add(timestampBytes);

    // Write "name: message" format
    final textContent = '$senderName: $message';
    buffer.add(textContent.codeUnits);

    return buffer.toBytes();
  }

  @override
  String toString() {
    return 'MeshCoreGroupTextMessage(timestamp: $timestamp, from: "$senderName", message: "$message")';
  }
}

/// Calculate the 1-byte hash for a channel name
/// Uses SHA256 truncated to 1 byte (PATH_HASH_SIZE)
int calculateChannelHash(String channelName) {
  final nameBytes = channelName.codeUnits;
  final hash = sha256.convert(nameBytes);
  // Return first byte (PATH_HASH_SIZE = 1 for version 1)
  return hash.bytes[0];
}

/// Represents a node advertisement (payload type 0x04)
class MeshCoreNodeAdvert {
  final int timestamp;
  final Uint8List publicKey; // 8 or 32 bytes
  final String? name;
  final double? latitude;
  final double? longitude;

  const MeshCoreNodeAdvert({
    required this.timestamp,
    required this.publicKey,
    this.name,
    this.latitude,
    this.longitude,
  });

  @override
  String toString() {
    return 'MeshCoreNodeAdvert(timestamp: $timestamp, pubKeyLen: ${publicKey.length}${name != null ? ', name: $name' : ''}${latitude != null ? ', lat: $latitude, lon: $longitude' : ''})';
  }
}

/// Represents a frame in the BLE queue
class MeshCoreFrame {
  final Uint8List data;

  const MeshCoreFrame(this.data);

  int get length => data.length;

  @override
  String toString() => 'MeshCoreFrame(len: $length)';
}
