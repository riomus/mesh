import 'dart:async';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../generated/meshtastic/meshtastic/mesh.pb.dart' as mesh;
import '../generated/meshtastic/meshtastic/portnums.pbenum.dart' as port;
import '../meshtastic/model/meshtastic_event.dart';
import '../meshtastic/model/meshtastic_mappers.dart';
import '../meshtastic/model/meshtastic_models.dart';

import '../services/device_communication_event_service.dart';
import '../services/device_status_store.dart';
import '../utils/text_sanitize.dart';

import '../l10n/app_localizations.dart';

class ChatWidget extends StatefulWidget {
  final BluetoothDevice device;

  const ChatWidget({super.key, required this.device});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  StreamSubscription<DeviceEvent>? _eventSub;
  
  // Max payload size for Meshtastic is roughly 230 bytes depending on headers, 
  // but let's be safe with a lower limit for text.
  static const int _maxBytes = 200; 
  int _currentBytes = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateByteCount);
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _textController.removeListener(_updateByteCount);
    _textController.dispose();
    _scrollController.dispose();
    _eventSub?.cancel();
    super.dispose();
  }

  void _updateByteCount() {
    setState(() {
      _currentBytes = _textController.text.length; // Approximation for now, UTF-8 check later if needed
      // Ideally we should encode to UTF-8 to get real byte count
      try {
         _currentBytes = Uint8List.fromList(_textController.text.codeUnits).length;
      } catch (_) {}
    });
  }

  void _subscribeToEvents() {
    _eventSub = DeviceCommunicationEventService.instance.listenAll().listen((event) {
      // Check if event is for this device
      final deviceIds = event.tags['deviceId'];
      if (deviceIds == null || !deviceIds.contains(widget.device.remoteId.str)) {
        return;
      }

      if (event.payload is MeshtasticDeviceEventPayload) {
        final meshPayload = event.payload as MeshtasticDeviceEventPayload;
        if (meshPayload.event is MeshPacketEvent) {
          final packetEvent = meshPayload.event as MeshPacketEvent;
          if (packetEvent.decoded is TextPayloadDto) {
            final textPayload = packetEvent.decoded as TextPayloadDto;
            setState(() {
              _messages.add(ChatMessage(
                text: textPayload.text,
                isMe: false, // Assuming incoming for now
                timestamp: event.timestamp,
              ));
            });
            _scrollToBottom();
          }
        }
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text;
    if (text.isEmpty) return;

    if (_currentBytes > _maxBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).messageTooLong)),
      );
      return;
    }

    try {
      final client = await DeviceStatusStore.instance.connect(widget.device);
      
      // Construct MeshPacket
      final packet = mesh.MeshPacket();
      packet.decoded = mesh.Data();
      packet.decoded.portnum = port.PortNum.TEXT_MESSAGE_APP;
      packet.decoded.payload = Uint8List.fromList(text.codeUnits); 
      // Note: using codeUnits is simple; for full UTF-8 support use Utf8Encoder
      
      // Send
      await client.sendMeshPacket(packet);

      // Optimistic update
      setState(() {
        _messages.add(ChatMessage(
          text: text,
          isMe: true,
          timestamp: DateTime.now(),
        ));
        _textController.clear();
      });
      _scrollToBottom();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).sendFailed(e.toString()))),
        );
      }
    }
  }

  Color get _counterColor {
    if (_currentBytes < _maxBytes * 0.75) return Colors.green;
    if (_currentBytes < _maxBytes * 0.90) return Colors.yellow;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return Align(
                alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: msg.isMe 
                        ? Theme.of(context).colorScheme.primaryContainer 
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(safeText(msg.text)),
                      const SizedBox(height: 2),
                      Text(
                        '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).typeMessage,
                    border: const OutlineInputBorder(),
                    counterText: '$_currentBytes/$_maxBytes',
                    counterStyle: TextStyle(color: _counterColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isMe, required this.timestamp});
}
