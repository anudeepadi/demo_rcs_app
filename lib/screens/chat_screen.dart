import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/typing_indicator.dart';
import '../models/message.dart';
import '../models/quick_reply.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

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

  Future<void> _handleSendMessage(String content) async {
    setState(() => _isTyping = true);
    await context.read<ChatProvider>().sendMessage(content);
    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'RCS Chat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Online',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ChatProvider>().loadMessages();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8.0),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(
                            message: chatProvider.messages[index],
                            onQuickReplySelected: (dynamic reply) {
                              if (reply is QuickReply) {
                                chatProvider.handleQuickReply(reply);
                                _scrollToBottom();
                              }
                            },
                          );
                        },
                      ),
                      if (_isTyping)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                radius: 16,
                                child: Icon(Icons.android,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const TypingIndicator(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            ChatInput(
              onSendMessage: _handleSendMessage,
              onMediaSelected: _handleMediaSelected,
            ),
          ],
        ),
      ),
    );
  }
}