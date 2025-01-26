import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gemini_chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../models/chat_message.dart';

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({Key? key}) : super(key: key);

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  Widget _buildMessage(BuildContext context, ChatMessage message) {
    return ChatBubble(
      message: message,
      child: _buildMessageContent(context, message),
    );
  }

  Widget _buildMessageContent(BuildContext context, ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return Text(message.content);
      case MessageType.quickReply:
        if (message.suggestedReplies?.isEmpty ?? true) {
          return const SizedBox.shrink();
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: message.suggestedReplies!.map((reply) {
            return ActionChip(
              label: Text(reply),
              onPressed: () {
                context.read<GeminiChatProvider>().sendMessage(reply);
              },
            );
          }).toList(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Gemini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<GeminiChatProvider>().clear();
            },
          ),
        ],
      ),
      body: Consumer<GeminiChatProvider>(
        builder: (context, geminiProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  itemCount: geminiProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = geminiProvider.messages[index];
                    return _buildMessage(context, message);
                  },
                ),
              ),
              if (geminiProvider.isGenerating)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(),
                ),
              MessageInput(
                onSendMessage: (content) {
                  geminiProvider.sendMessage(content);
                  _scrollToBottom();
                },
                onSendMedia: (file, type) {
                  // Gemini chat doesn't support media uploads
                },
              ),
            ],
          );
        },
      ),
    );
  }
}