import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/channel_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/system_chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../models/quick_reply.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    final systemChatProvider = Provider.of<SystemChatProvider>(
      context, 
      listen: false,
    );
    systemChatProvider.addUserMessage(text);
    _controller.clear();
    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RCS Assistant'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFF121212),
        child: Column(
          children: [
            Expanded(
              child: Consumer<SystemChatProvider>(
                builder: (context, provider, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages[index];
                      return ChatBubble(
                        message: message,
                        onQuickReplySelected: (replyText) => _handleSubmitted(replyText),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          hintStyle: TextStyle(color: Colors.grey),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _handleSubmitted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _handleSubmitted(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}