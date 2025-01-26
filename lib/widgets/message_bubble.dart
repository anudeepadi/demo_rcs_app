import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'media_message.dart';
import 'quick_reply_bar.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  Widget _buildLinkPreview() {
    if (message.linkPreview == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.linkPreview!.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                message.linkPreview!.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.linkPreview!.title != null)
                  Text(
                    message.linkPreview!.title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (message.linkPreview!.description != null)
                  Text(
                    message.linkPreview!.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  message.linkPreview!.url,
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (message.type) {
      case MessageType.image:
      case MessageType.video:
      case MessageType.file:
        return MediaMessage(message: message);
      case MessageType.linkPreview:
        return _buildLinkPreview();
      case MessageType.quickReply:
      case MessageType.suggestion:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.content),
            const SizedBox(height: 8),
            QuickReplyBar(message: message),
          ],
        );
      default:
        return Text(message.content);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: message.isMe
                ? Theme.of(context).primaryColor.withOpacity(0.2)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: _buildContent(),
        ),
      ),
    );
  }
}