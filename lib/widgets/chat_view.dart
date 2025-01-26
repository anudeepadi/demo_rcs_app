import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_chat_provider.dart';
import '../models/chat_message.dart';
import 'chat_message_widget.dart';
import 'quick_reply_bar.dart';
import 'chat_input.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleMessageSubmit(String message) {
    if (message.trim().isEmpty) return;
    context.read<SystemChatProvider>().addUserMessage(message);
    _scrollToBottom();
  }

  void _handleGifSelected(String gifUrl) {
    context.read<SystemChatProvider>().addGifMessage(gifUrl);
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
    return Column(
      children: [
        Expanded(
          child: Consumer<SystemChatProvider>(
            builder: (context, provider, child) {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: provider.messages.length,
                itemBuilder: (context, index) {
                  final message = provider.messages[index];
                  return ChatMessageWidget(
                    message: message,
                    onReplyTap: () {
                      // Handle reply tap
                    },
                    onReactionAdd: (emoji) {
                      // Handle reaction
                    },
                  );
                },
              );
            },
          ),
        ),
        QuickReplyBar(
          onReplySelected: _handleMessageSubmit,
        ),
        ChatInput(
          onMessageSubmit: _handleMessageSubmit,
          onGifSelected: _handleGifSelected,
        ),
      ],
    );
  }
}