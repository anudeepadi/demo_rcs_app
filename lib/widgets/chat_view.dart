import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import 'chat_bubble.dart';
import 'message_input.dart';

class ChatView extends StatelessWidget {
  final ScrollController scrollController;
  final bool showInput;
  
  const ChatView({
    Key? key,
    required this.scrollController,
    this.showInput = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  final message = chatProvider.messages[index];
                  return _buildMessage(context, message, chatProvider);
                },
              ),
            ),
            if (showInput)
              MessageInput(
                onSendMessage: (content) {
                  chatProvider.addTextMessage(content: content);
                },
                onSendMedia: (file, type) {
                  chatProvider.sendMedia(file: file, type: type);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildMessage(BuildContext context, ChatMessage message, ChatProvider chatProvider) {
    return ChatBubble(
      message: message,
      child: _buildMessageContent(message),
      onReplyTap: () {
        // Handle reply tap
      },
      onReactionAdd: (emoji) {
        chatProvider.addReaction(message.id, emoji);
      },
      onThreadTap: () {
        // Handle thread tap
      },
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return Text(message.content);
      case MessageType.image:
        return Image.network(message.mediaUrl ?? '');
      case MessageType.video:
        return Container(); // Implement video player
      case MessageType.gif:
        return Image.network(message.mediaUrl ?? '');
      case MessageType.file:
        return Container(); // Implement file preview
      case MessageType.audio:
        return Container(); // Implement audio player
      case MessageType.youtube:
        return Container(); // Implement YouTube preview
      case MessageType.quickReply:
        return Container(); // Implement quick reply buttons
    }
  }
}