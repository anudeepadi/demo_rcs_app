import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';
import 'quick_reply_button.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage chatMessage;
  final Function(QuickReply) onQuickReplySelected;
  final Function(String)? onReactionAdd;
  final VoidCallback? onReplyTap;

  const MessageBubble({
    Key? key,
    required this.chatMessage,
    required this.onQuickReplySelected,
    this.onReactionAdd,
    this.onReplyTap,
  }) : super(key: key);

  Widget _buildContent(BuildContext context) {
    switch (chatMessage.type) {
      case MessageType.text:
        return Text(
          chatMessage.content,
          style: TextStyle(
            color: chatMessage.isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        );
      case MessageType.gif:
        return Image.network(
          chatMessage.mediaUrl!,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        );
      case MessageType.quickReply:
        return Wrap(
          spacing: 8,
          children: (chatMessage.suggestedReplies ?? []).map((reply) {
            return QuickReplyButton(
              quickReply: reply,
              onTap: () => onQuickReplySelected(reply),
            );
          }).toList(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMessageStatus() {
    switch (chatMessage.status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 12);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 12);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 12);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: Colors.blue);
      case MessageStatus.failed:
        return const Icon(Icons.error_outline, size: 12, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: chatMessage.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: chatMessage.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (chatMessage.parentMessageId != null)
              GestureDetector(
                onTap: onReplyTap,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Reply to message'),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: chatMessage.isMe 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContent(context),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${chatMessage.timestamp.hour}:${chatMessage.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: chatMessage.isMe 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.5),
                        ),
                      ),
                      if (chatMessage.isMe) ...[
                        const SizedBox(width: 4),
                        _buildMessageStatus(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (chatMessage.reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  children: chatMessage.reactions.map((reaction) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(reaction.emoji, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}