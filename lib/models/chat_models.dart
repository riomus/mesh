enum MessageStatus { sending, sent, acked, ackedByRelay, failed, received }

class ChatRoom {
  final String id;
  final String name;
  final bool isDirect;
  final int? otherNodeId;
  final int? channelIndex;
  final String deviceId;
  final ChatMessage? lastMessage;
  final int unreadCount;

  ChatRoom({
    required this.id,
    required this.name,
    required this.isDirect,
    required this.deviceId,
    this.otherNodeId,
    this.channelIndex,
    this.lastMessage,
    this.unreadCount = 0,
  });

  ChatRoom copyWith({
    String? id,
    String? name,
    bool? isDirect,
    int? otherNodeId,
    int? channelIndex,
    String? deviceId,
    ChatMessage? lastMessage,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      isDirect: isDirect ?? this.isDirect,
      otherNodeId: otherNodeId ?? this.otherNodeId,
      channelIndex: channelIndex ?? this.channelIndex,
      deviceId: deviceId ?? this.deviceId,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final MessageStatus status;
  final int? packetId;
  final Map<String, dynamic>? packetDetails;
  final int? authorNodeId;
  final String? deviceId;
  final int? ackFrom; // Node ID that sent the acknowledgment

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.status,
    this.packetId,
    this.packetDetails,
    this.authorNodeId,
    this.deviceId,
    this.ackFrom,
  });

  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? text,
    bool? isMe,
    DateTime? timestamp,
    MessageStatus? status,
    int? packetId,
    Map<String, dynamic>? packetDetails,
    int? authorNodeId,
    String? deviceId,
    int? ackFrom,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      packetId: packetId ?? this.packetId,
      packetDetails: packetDetails ?? this.packetDetails,
      authorNodeId: authorNodeId ?? this.authorNodeId,
      deviceId: deviceId ?? this.deviceId,
      ackFrom: ackFrom ?? this.ackFrom,
    );
  }
}
