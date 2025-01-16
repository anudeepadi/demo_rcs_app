import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/bot_chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/typing_indicator.dart';
import '../models/message.dart';
import '../models/quick_reply.dart';

class ChatScreen extends StatefulWidget {
  final String title;

  const ChatScreen({
    super.key,
    required this.title,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BotChatProvider>().initialize();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleMediaSelected(PlatformFile file) async {
    if (file.bytes == null) return;

    final chatProvider = context.read<BotChatProvider>();
    final url = await chatProvider.handleMediaUpload(file.bytes!, file.name);

    if (url != null) {
      final type = file.name.toLowerCase().endsWith('.mp4')
          ? MessageType.video
          : MessageType.image;
      await chatProvider.sendMessage(
        content: 'Sent ${type == MessageType.video ? 'video' : 'image'}',
        type: type,
        mediaUrl: url,
      );
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            Text(widget.title),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                context.read<BotChatProvider>().clearMessages();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: Consumer<BotChatProvider>(
                builder: (context, chatProvider, child) {
                  return Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8.0),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatProvider.messages[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: MessageBubble(
                              message: message,
                              onQuickReplySelected: (dynamic reply) {
                                if (reply is QuickReply) {
                                  chatProvider.handleQuickReply(reply);
                                  _scrollToBottom();
                                }
                              },
                            ),
                          );
                        },
                      ),
                      if (chatProvider.isTyping)
                        const Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: TypingIndicator(),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          ChatInput(
            onSendMessage: (String content) async {
              await context.read<BotChatProvider>().sendMessage(content: content);
              _scrollToBottom();
            },
            onMediaSelected: _handleMediaSelected,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}