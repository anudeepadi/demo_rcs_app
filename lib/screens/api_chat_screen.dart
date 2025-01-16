import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/typing_indicator.dart';
import '../models/message.dart';
import '../models/quick_reply.dart';

class ApiChatScreen extends StatefulWidget {
  final String title;

  const ApiChatScreen({
    super.key,
    required this.title,
  });

  @override
  State<ApiChatScreen> createState() => _ApiChatScreenState();
}

class _ApiChatScreenState extends State<ApiChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadMessages();
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

    final chatProvider = context.read<ChatProvider>();
    final url = await chatProvider.uploadMedia(file.bytes!, file.name);

    if (url != null) {
      final type = file.name.toLowerCase().endsWith('.mp4')
          ? MessageType.video
          : MessageType.image;
      await chatProvider.sendMessage(
        'Sent ${type == MessageType.video ? 'video' : 'image'}',
        type: type,
        mediaUrl: url,
      );
      _scrollToBottom();
    }
  }

  Future<void> _refreshMessages() async {
    await context.read<ChatProvider>().loadMessages();
    _scrollToBottom();
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
          children: [
            const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 5,
            ),
            const SizedBox(width: 8),
            Text(widget.title),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMessages,
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
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _refreshMessages,
                        child: ListView.builder(
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
                      ),
                      if (chatProvider.isTyping)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: const TypingIndicator(),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          ChatInput(
            onSendMessage: (String content) async {
              await context.read<ChatProvider>().sendMessage(content);
              _scrollToBottom();
            },
            onMediaSelected: _handleMediaSelected,
          ),
        ],
      ),
    );
  }
}