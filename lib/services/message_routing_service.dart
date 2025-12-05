import 'dart:async';

import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_models.dart';
import '../services/device_communication_event_service.dart';
import '../models/chat_models.dart';
import 'device_state_service.dart';
import 'notification_service.dart';

import 'transport_layer.dart';
import 'ble_transport_layer.dart';
import 'package:flutter/foundation.dart';

class MessageRoutingService {
  static final MessageRoutingService _instance =
      MessageRoutingService._internal();
  static MessageRoutingService get instance => _instance;

  MessageRoutingService._internal() {
    _subscribeToEvents();
  }

  final Map<String, ChatRoom> _rooms = {};
  final Map<String, List<ChatMessage>> _messages = {};

  final _roomsController = StreamController<List<ChatRoom>>.broadcast();
  final Map<String, StreamController<List<ChatMessage>>> _messageControllers =
      {};

  Stream<List<ChatRoom>> get roomsStream => _roomsController.stream;

  Stream<List<ChatMessage>> getMessagesForRoom(String roomId) {
    if (!_messageControllers.containsKey(roomId)) {
      _messageControllers[roomId] =
          StreamController<List<ChatMessage>>.broadcast();
      // Emit current messages immediately if any
      if (_messages.containsKey(roomId)) {
        _messageControllers[roomId]!.add(_messages[roomId]!);
      } else {
        _messageControllers[roomId]!.add([]);
      }
    }
    return _messageControllers[roomId]!.stream;
  }

  List<ChatMessage> getInitialMessages(String roomId) {
    return _messages[roomId] ?? [];
  }

  Future<String> getDirectChatRoomId(String deviceId, int nodeId) async {
    final id = 'dm_${deviceId}_$nodeId';
    if (!_rooms.containsKey(id)) {
      _rooms[id] = ChatRoom(
        id: id,
        name: 'Node $nodeId', // Ideally fetch name from NodeDB
        isDirect: true,
        deviceId: deviceId,
        otherNodeId: nodeId,
      );
      _messages[id] = [];
      _emitRooms();
    }
    return id;
  }

  Future<String> getChannelChatRoomId(String deviceId, int channelIndex) async {
    final id = 'ch_${deviceId}_$channelIndex';
    if (!_rooms.containsKey(id)) {
      String name = 'Channel $channelIndex';
      if (channelIndex == 0) {
        name = 'Default';
      }

      // Try to fetch actual name from device state
      final state = DeviceStateService.instance.getState(deviceId);
      if (state != null) {
        final channel = state.channels.firstWhere(
          (c) => c.index == channelIndex,
          orElse: () => ChannelDto(index: channelIndex, role: 'SECONDARY'),
        );
        if (channel.settings?.name?.isNotEmpty == true) {
          name = channel.settings!.name!;
        }
      }

      _rooms[id] = ChatRoom(
        id: id,
        name: name,
        isDirect: false,
        deviceId: deviceId,
        channelIndex: channelIndex,
      );
      _messages[id] = [];
      _emitRooms();
    }
    return id;
  }

  TransportLayer _transportLayer = BleTransportLayer();
  NotificationService _notificationService = NotificationService.instance;

  @visibleForTesting
  set transportLayer(TransportLayer layer) {
    _transportLayer = layer;
  }

  @visibleForTesting
  set notificationService(NotificationService service) {
    _notificationService = service;
  }

  Future<void> sendMessage(String roomId, String text) async {
    final room = _rooms[roomId];
    if (room == null) throw Exception('Room not found');

    final device = await _transportLayer.getDevice(room.deviceId);
    if (device == null) throw Exception('Device not connected');

    // Create optimistic message
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    var message = ChatMessage(
      id: tempId, // Temporary ID
      roomId: roomId,
      text: text,
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      statusHistory: [
        MessageStatusHistoryEntry(
          status: MessageStatus.sending,
          timestamp: DateTime.now(),
        ),
      ],
    );

    _addMessage(roomId, message);

    try {
      int packetId;
      if (room.isDirect) {
        packetId = await device.sendMessage(text, room.otherNodeId);
      } else {
        packetId = await device.sendMessage(
          text,
          null,
          channelIndex: room.channelIndex,
        );
      }

      // Update status to sent and set packet ID
      _updateMessageStatus(
        roomId,
        tempId,
        MessageStatus.sent,
        packetId: packetId,
      );

      // Start timeout timer for ACK
      // Only expect ACK for direct messages or if we can track it (currently only DM usually implies ACK request)
      // But user requirement says "if routing packet for given message is received - it should get acked"
      // We will assume we want ACK for all for now, or at least DMs.
      // The user prompt implies general "messages should have status informations".
      // Let's set a timeout.
      Timer(const Duration(seconds: 30), () {
        final currentMsg = _messages[roomId]?.firstWhere(
          (m) => m.packetId == packetId,
          orElse: () => ChatMessage(
            id: '',
            roomId: '',
            text: '',
            isMe: true,
            timestamp: DateTime.now(),
            status: MessageStatus.failed,
          ),
        );

        if (currentMsg != null &&
            currentMsg.id.isNotEmpty &&
            currentMsg.status != MessageStatus.acked &&
            currentMsg.status != MessageStatus.failed) {
          _updateMessageStatus(
            roomId,
            currentMsg.id,
            MessageStatus.failed, // Not Acked (Orange)
          );
        }
      });
    } catch (e) {
      _updateMessageStatus(roomId, tempId, MessageStatus.failed);
      rethrow;
    }
  }

  void _subscribeToEvents() {
    DeviceCommunicationEventService.instance.listenAll().listen(_handleEvent);
  }

  Future<void> _handleEvent(DeviceEvent event) async {
    if (event.payload is MeshtasticDeviceEventPayload) {
      final meshPayload = event.payload as MeshtasticDeviceEventPayload;
      if (meshPayload.event is MeshPacketEvent) {
        final packetEvent = meshPayload.event as MeshPacketEvent;
        final packet = packetEvent.packet;

        if (packetEvent.decoded is TextPayloadDto) {
          final textPayload = packetEvent.decoded as TextPayloadDto;
          final deviceId = event.tags['deviceId']?.firstOrNull;

          if (deviceId == null) return;

          // Determine room
          String? roomId;
          if (packet.to == 0xFFFFFFFF) {
            // Broadcast
            final channelIndex = packet.channel ?? 0;
            roomId = 'ch_${deviceId}_$channelIndex';
            if (!_rooms.containsKey(roomId)) {
              _rooms[roomId] = ChatRoom(
                id: roomId,
                name: 'Channel $channelIndex',
                isDirect: false,
                deviceId: deviceId,
                channelIndex: channelIndex,
              );
              _messages[roomId] = [];
              _emitRooms();
            }
          } else {
            // Direct Message
            final otherNodeId = packet.from;
            if (otherNodeId != null) {
              roomId = 'dm_${deviceId}_$otherNodeId';
              if (!_rooms.containsKey(roomId)) {
                _rooms[roomId] = ChatRoom(
                  id: roomId,
                  name: 'Node $otherNodeId',
                  isDirect: true,
                  deviceId: deviceId,
                  otherNodeId: otherNodeId,
                );
                _messages[roomId] = [];
                _emitRooms();
              }
            }
          }

          if (roomId != null) {
            final message = ChatMessage(
              id: packet.id.toString(),
              roomId: roomId,
              text: textPayload.text,
              isMe: false, // Assuming incoming
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                (packet.rxTime ?? 0) * 1000,
              ),
              status: MessageStatus.received,
              packetId: packet.id,
              packetDetails: {
                'from': packet.from,
                'to': packet.to,
                'snr': packet.rxSnr,
                'rssi': packet.rxRssi,
                'hopLimit': packet.hopLimit,
              },
              authorNodeId: packet.from,
              deviceId: deviceId,
              statusHistory: [
                MessageStatusHistoryEntry(
                  status: MessageStatus.received,
                  timestamp: DateTime.now(),
                  sourceNodeId: packet.from,
                ),
              ],
            );
            print('DEBUG: Adding message to room $roomId: ${message.text}');
            _addMessage(roomId, message);

            // Resolve names for notification
            String title = 'New Message';
            String body = textPayload.text;

            final deviceState = DeviceStateService.instance.getState(deviceId);
            if (deviceState != null) {
              // Source Device Name
              String sourceName = 'Device';
              final myNodeNum = deviceState.myNodeInfo?.myNodeNum;
              if (myNodeNum != null) {
                final myNode = deviceState.nodes.firstWhere(
                  (n) => n.num == myNodeNum,
                  orElse: () => NodeInfoDto(num: myNodeNum),
                );
                sourceName =
                    myNode.user?.longName ?? myNode.user?.shortName ?? 'Device';
              }

              // Author Name
              String authorName = 'Unknown';
              final authorNode = deviceState.nodes.firstWhere(
                (n) => n.num == packet.from,
                orElse: () => NodeInfoDto(num: packet.from),
              );

              if (authorNode.user?.longName?.isNotEmpty == true) {
                authorName = authorNode.user!.longName!;
              } else if (authorNode.user?.shortName?.isNotEmpty == true) {
                authorName = authorNode.user!.shortName!;
              } else {
                authorName = 'Node ${packet.from}';
              }

              title = '$authorName ($sourceName)';
            }

            await _notificationService.showNotification(
              (packet.id ?? DateTime.now().millisecondsSinceEpoch) % 2147483647,
              title,
              body,
              roomId,
            );
          }
        } else if (packetEvent.decoded is RoutingPayloadDto) {
          final routing = packetEvent.decoded as RoutingPayloadDto;
          final deviceId = event.tags['deviceId']?.firstOrNull;

          // Handle Routing/ACK
          if (deviceId != null) {
            final fromNode = packet.from;
            final myNodeId = DeviceStateService.instance
                .getState(deviceId)
                ?.myNodeInfo
                ?.myNodeNum;

            if (fromNode != null) {
              // If we have a requestId, we can find the exact message
              if (routing.requestId != null && routing.requestId != 0) {
                for (final roomId in _rooms.keys) {
                  // Only check rooms for this device
                  if (_rooms[roomId]?.deviceId != deviceId) continue;

                  final roomMessages = _messages[roomId];
                  if (roomMessages != null) {
                    final msgIndex = roomMessages.indexWhere(
                      (m) => m.packetId == routing.requestId,
                    );
                    if (msgIndex != -1) {
                      final msg = roomMessages[msgIndex];
                      final room = _rooms[roomId]!;

                      // Determine status
                      MessageStatus newStatus;
                      if (routing.errorReason != null &&
                          routing.errorReason != 'NONE') {
                        newStatus = MessageStatus.failed;
                      } else {
                        // Success
                        if (room.isDirect) {
                          if (fromNode == room.otherNodeId) {
                            newStatus = MessageStatus.acked;
                          } else {
                            // Local confirmation or relay confirmation
                            newStatus = MessageStatus.ackedByRelay;
                          }
                        } else {
                          // Broadcast / Channel
                          if (fromNode == myNodeId) {
                            // Local confirmation means sent to mesh successfully
                            // User wants this to show as acked (or at least better than "sent")
                            // We'll use ackedByRelay or acked. User said "sure it is acked".
                            // Let's use acked for now as it's a "success" indication from the mesh perspective (injected)
                            newStatus = MessageStatus.acked;
                          } else {
                            // Rebroadcast heard from someone else
                            newStatus = MessageStatus.ackedByRelay;
                          }
                        }
                      }

                      _updateMessageStatus(
                        roomId,
                        msg.id,
                        newStatus,
                        ackFrom: fromNode,
                      );
                      break; // Found the message, stop searching
                    }
                  }
                }
              } else {
                // Fallback for missing requestId (old behavior)
                // Iterate through all rooms to find messages awaiting ACK
                for (final roomId in _rooms.keys) {
                  final room = _rooms[roomId]!;
                  if (room.deviceId != deviceId) continue;

                  // For direct messages, we can determine if this is receiver vs relay
                  if (room.isDirect) {
                    final roomMessages = _messages[roomId];
                    if (roomMessages != null) {
                      // Find messages that are pending ACK
                      for (final msg in roomMessages) {
                        if (msg.status == MessageStatus.sent ||
                            msg.status == MessageStatus.sending) {
                          // Determine if this ACK is from the receiver or a relay
                          final isFromReceiver = (fromNode == room.otherNodeId);
                          final newStatus =
                              (routing.errorReason != null &&
                                  routing.errorReason != 'NONE')
                              ? MessageStatus.failed
                              : (isFromReceiver
                                    ? MessageStatus.acked
                                    : MessageStatus.ackedByRelay);

                          _updateMessageStatus(
                            roomId,
                            msg.id,
                            newStatus,
                            ackFrom: fromNode,
                          );
                          // ACK the first pending message we find
                          break;
                        }
                      }
                    }
                  }
                  // For channel messages, we treat any ACK as relay ACK
                  else if (!room.isDirect) {
                    final roomMessages = _messages[roomId];
                    if (roomMessages != null) {
                      for (final msg in roomMessages) {
                        if (msg.status == MessageStatus.sent ||
                            msg.status == MessageStatus.sending) {
                          final newStatus =
                              (routing.errorReason != null &&
                                  routing.errorReason != 'NONE')
                              ? MessageStatus.failed
                              : MessageStatus.ackedByRelay;

                          _updateMessageStatus(
                            roomId,
                            msg.id,
                            newStatus,
                            ackFrom: fromNode,
                          );
                          break;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  void _addMessage(String roomId, ChatMessage message) {
    if (!_messages.containsKey(roomId)) {
      _messages[roomId] = [];
    }
    _messages[roomId]!.add(message);
    print('DEBUG: Message added to list. Count: ${_messages[roomId]!.length}');
    _emitMessages(roomId);

    // Update last message in room
    if (_rooms.containsKey(roomId)) {
      _rooms[roomId] = _rooms[roomId]!.copyWith(
        lastMessage: message,
        unreadCount: message.isMe
            ? _rooms[roomId]!.unreadCount
            : _rooms[roomId]!.unreadCount + 1,
      );
      _emitRooms();
    }
  }

  void _updateMessageStatus(
    String roomId,
    String messageId,
    MessageStatus status, {
    int? packetId,
    int? ackFrom,
  }) {
    final roomMessages = _messages[roomId];
    if (roomMessages == null) return;

    final index = roomMessages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final oldMessage = roomMessages[index];
      final newHistory = List<MessageStatusHistoryEntry>.from(
        oldMessage.statusHistory,
      );

      // Only add to history if status changed or it's a significant update (like ackFrom)
      // But user wants ALL status changes.
      newHistory.add(
        MessageStatusHistoryEntry(
          status: status,
          timestamp: DateTime.now(),
          sourceNodeId: ackFrom,
        ),
      );

      roomMessages[index] = oldMessage.copyWith(
        status: status,
        packetId: packetId,
        ackFrom: ackFrom,
        statusHistory: newHistory,
      );
      _emitMessages(roomId);
    }
  }

  void _emitRooms() {
    _roomsController.add(_rooms.values.toList());
  }

  void _emitMessages(String roomId) {
    if (_messageControllers.containsKey(roomId)) {
      _messageControllers[roomId]!.add(_messages[roomId]!);
    }
  }
}
