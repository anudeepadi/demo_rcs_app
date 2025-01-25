import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(QuickReply)? onQuickReplySelected;

  const ChatBubble({
    Key? key,
    required this.message,
    this.onQuickReplySelected,
  }) : super(key: key);

  Widget _buildMediaPreview(BuildContext context) {
    if (message.mediaUrl == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        // TODO: Implement media preview
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.mediaUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLinkPreview() {
    if (message.linkPreview == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.linkPreview?.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                message.linkPreview!.imageUrl!,
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.linkPreview?.title != null)
                  Text(
                    message.linkPreview!.title!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (message.linkPreview?.description != null)
                  Text(
                    message.linkPreview!.description!,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    if (message.suggestedReplies == null || message.suggestedReplies!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: message.suggestedReplies!.length,
        itemBuilder: (context, index) {
          final reply = message.suggestedReplies![index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: OutlinedButton(
              onPressed: () => onQuickReplySelected?.call(reply),
              child: Text(reply.text),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Card(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : null,
                      ),
                    ),
                  ),
                if (message.type == MessageType.image || 
                    message.type == MessageType.video)
                  _buildMediaPreview(context),
                if (message.type == MessageType.linkPreview)
                  _buildLinkPreview(),
                if (message.type == MessageType.quickReplies)
                  _buildQuickReplies(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}