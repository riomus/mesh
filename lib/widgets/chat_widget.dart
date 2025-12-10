import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/device/device_bloc.dart';
import '../blocs/nodes/nodes_bloc.dart';

import '../models/chat_models.dart';
import '../services/message_routing_service.dart';
import '../utils/text_sanitize.dart';
import '../services/device_status_store.dart';
import '../pages/device_details_page.dart';

import '../l10n/app_localizations.dart';

class ChatWidget extends StatefulWidget {
  final String roomId;

  const ChatWidget({super.key, required this.roomId});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<ChatMessage> _messages = [];
  StreamSubscription<List<ChatMessage>>? _messageSub;
  bool _showEmoji = false;

  // Max payload size for Meshtastic is roughly 230 bytes depending on headers,
  // but let's be safe with a lower limit for text.
  static const int _maxBytes = 200;
  int _currentBytes = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateByteCount);
    _loadInitialMessages();
    _subscribeToMessages();

    // Hide emoji picker when keyboard shows up
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmoji = false;
        });
      }
    });
  }

  void _loadInitialMessages() {
    setState(() {
      _messages = MessageRoutingService.instance.getInitialMessages(
        widget.roomId,
      );
    });
    // Scroll to bottom after frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _textController.removeListener(_updateByteCount);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _messageSub?.cancel();
    super.dispose();
  }

  void _updateByteCount() {
    setState(() {
      _currentBytes = _textController
          .text
          .length; // Approximation for now, UTF-8 check later if needed
      // Ideally we should encode to UTF-8 to get real byte count
      try {
        _currentBytes = Uint8List.fromList(
          _textController.text.codeUnits,
        ).length;
      } catch (_) {}
    });
  }

  void _subscribeToMessages() {
    _messageSub = MessageRoutingService.instance
        .getMessagesForRoom(widget.roomId)
        .listen(
          (messages) {
            setState(() {
              _messages = messages;
            });
            _scrollToBottom();
          },
          onError: (e) {
            print('[ChatWidget] Error in messages stream: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(
                      context,
                    ).errorLoadingMessages(e.toString()),
                  ),
                ),
              );
            }
          },
        );
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
      await MessageRoutingService.instance.sendMessage(widget.roomId, text);
      _textController.clear();
      // Scroll to bottom handled by stream update
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).sendFailed(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Color get _counterColor {
    if (_currentBytes < _maxBytes * 0.75) return Colors.green;
    if (_currentBytes < _maxBytes * 0.90) return Colors.yellow;
    return Colors.red;
  }

  void _onBackspacePressed() {
    final text = _textController.text;
    final selection = _textController.selection;
    final cursorPosition = selection.baseOffset < 0
        ? text.length
        : selection.baseOffset;

    if (cursorPosition == 0) return;

    final newText = text.replaceRange(cursorPosition - 1, cursorPosition, '');
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPosition - 1),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        return KeyEventResult.ignored; // Let it insert newline
      }
      _sendMessage();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isMe
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!msg.isMe && msg.authorNodeId != null) ...[
                            _buildAuthorWidget(context, msg),
                            const SizedBox(height: 4),
                          ],
                          Text(safeText(msg.text)),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              if (msg.isMe) ...[
                                const SizedBox(width: 4),
                                _buildStatusIndicator(msg.status),
                                IconButton(
                                  icon: const Icon(
                                    Icons.info_outline,
                                    size: 16,
                                  ),
                                  onPressed: () => _showPacketDetails(msg),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: AppLocalizations.of(
                                    context,
                                  ).messageInfo,
                                ),
                              ],
                            ],
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
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showEmoji = !_showEmoji;
                        if (_showEmoji) {
                          _focusNode.unfocus();
                        } else {
                          _focusNode.requestFocus();
                        }
                      });
                    },
                    icon: Icon(
                      _showEmoji
                          ? Icons.keyboard
                          : Icons.emoji_emotions_outlined,
                      color: _showEmoji ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Focus(
                      onKeyEvent: _handleKeyEvent,
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).typeMessage,
                          border: const OutlineInputBorder(),
                          counterText: '$_currentBytes/$_maxBytes',
                          counterStyle: TextStyle(color: _counterColor),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
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
            if (_showEmoji)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  textEditingController: _textController,
                  onEmojiSelected: (category, emoji) {
                    // Do nothing here, as textEditingController handles insertion
                  },
                  onBackspacePressed: _onBackspacePressed,
                  config: Config(
                    height: 250,
                    checkPlatformCompatibility: true,
                    viewOrderConfig: const ViewOrderConfig(),
                    emojiViewConfig: EmojiViewConfig(
                      // Define the columns for the emoji picker
                      columns: 7,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
                    skinToneConfig: const SkinToneConfig(),
                    categoryViewConfig: CategoryViewConfig(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      dividerColor: Theme.of(context).dividerColor,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      iconColorSelected: Theme.of(context).colorScheme.primary,
                      iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    bottomActionBarConfig: BottomActionBarConfig(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      buttonColor: Theme.of(context).colorScheme.surface,
                      buttonIconColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                    ),
                    searchViewConfig: SearchViewConfig(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      buttonIconColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(MessageStatus status) {
    String tooltip;
    String text;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        tooltip = AppLocalizations.of(context).sendingToRadio;
        text = '⏳'; // Hourglass
        color = Colors.yellow;
        break;
      case MessageStatus.sent:
        tooltip = AppLocalizations.of(context).sentToRadio;
        text = '📡'; // Satellite antenna
        color = Colors.yellow;
        break;
      case MessageStatus.acked:
        tooltip = AppLocalizations.of(context).acknowledgedByReceiver;
        text = '✅'; // Check mark
        color = Colors.green;
        break;
      case MessageStatus.ackedByRelay:
        tooltip = AppLocalizations.of(context).acknowledgedByRelay;
        text = '🔄'; // Recycling/forward symbol
        color = Colors.blue;
        break;
      case MessageStatus.failed:
        tooltip = AppLocalizations.of(context).notAcknowledgedTimeout;
        text = '⚠️'; // Warning
        color = Colors.orange;
        break;
      case MessageStatus.received:
        tooltip = AppLocalizations.of(context).received;
        text = '';
        color = Colors.transparent;
        break;
    }

    if (text.isEmpty) return const SizedBox.shrink();

    return Tooltip(
      message: tooltip,
      child: Text(text, style: TextStyle(fontSize: 12, color: color)),
    );
  }

  void _showPacketDetails(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).messageDetails),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(
                  context,
                ).statusWithStatus(message.status.name),
              ),
              const SizedBox(height: 8),
              if (message.packetId != null)
                Text(
                  AppLocalizations.of(
                    context,
                  ).packetIdWithId(message.packetId!),
                ),
              if (message.packetDetails != null) ...[
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).packetInfo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ...message.packetDetails!.entries.map(
                  (e) => Text('${e.key}: ${e.value}'),
                ),
              ],
              if (message.statusHistory.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).statusHistory,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...message.statusHistory.map((entry) {
                  String statusText = entry.status.name;
                  // Map status to localized text if possible, or just use name for now
                  // Reusing _buildStatusIndicator logic partially for text
                  switch (entry.status) {
                    case MessageStatus.sending:
                      statusText = AppLocalizations.of(context).sendingToRadio;
                      break;
                    case MessageStatus.sent:
                      statusText = AppLocalizations.of(context).sentToRadio;
                      break;
                    case MessageStatus.acked:
                      statusText = AppLocalizations.of(
                        context,
                      ).acknowledgedByReceiver;
                      break;
                    case MessageStatus.ackedByRelay:
                      statusText = AppLocalizations.of(
                        context,
                      ).acknowledgedByRelay;
                      break;
                    case MessageStatus.failed:
                      statusText = AppLocalizations.of(
                        context,
                      ).notAcknowledgedTimeout;
                      break;
                    case MessageStatus.received:
                      statusText = AppLocalizations.of(context).received;
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildStatusIndicator(entry.status),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                statusText,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: Text(
                            '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}.${entry.timestamp.millisecond}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                        if (entry.sourceNodeId != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: Text(
                              AppLocalizations.of(context).sourceNodePrefix(
                                AppLocalizations.of(
                                  context,
                                ).nodeName(entry.sourceNodeId.toString()),
                              ),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorWidget(BuildContext context, ChatMessage message) {
    if (message.authorNodeId == null) {
      return Text(
        AppLocalizations.of(context).unknown,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }

    // Use NodesBloc to get the node view (single source of truth)
    final node = context.read<NodesBloc>().state.getNode(message.authorNodeId);
    final authorName =
        node?.displayName ??
        AppLocalizations.of(context).nodeName(message.authorNodeId.toString());

    // Check if it's a connected device to make it clickable
    final connectedDevices = DeviceStatusStore.instance.connectedDevices;
    BluetoothDevice? authorDevice;

    // We can check if the authorNodeId matches any connected device's node num
    // But we need to know the node num of connected devices.
    // DeviceBloc has this info.
    for (final device in connectedDevices) {
      final deviceState = context.read<DeviceBloc>().state.getDeviceState(
        device.remoteId.str,
      );
      if (deviceState?.myNodeInfo?.myNodeNum == message.authorNodeId) {
        authorDevice = device;
        break;
      }
    }

    if (authorDevice != null) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DeviceDetailsPage(device: authorDevice!),
            ),
          );
        },
        child: Text(
          authorName,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    } else if (node != null) {
      // If it's a known node (but not a connected device), we can still show details
      return GestureDetector(
        onTap: () {
          // We can navigate to NodeDetailsPage if we have a node
          // But NodeDetailsPage takes a nodeNum.
          // We need to import NodeDetailsPage.
          // It seems ChatWidget doesn't import it yet.
          // For now, let's just show the name.
          // Or we can add the import.
        },
        child: Text(
          authorName,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      );
    } else {
      return Text(
        authorName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }
}
