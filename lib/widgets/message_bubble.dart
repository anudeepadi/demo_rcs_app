import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';
import 'media_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  Widget _buildLinkPreview() {
    if (message.linkPreview == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.linkPreview?.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                message.linkPreview!.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 150,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (message.linkPreview?.description != null)
                  Text(
                    message.linkPreview!.description!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (message.linkPreview?.siteName != null)
                  Text(
                    message.linkPreview!.siteName!,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
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
      margin: const EdgeInsets.only(top: 8),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: message.suggestedReplies!.length,
        itemBuilder: (context, index) {
          final reply = message.suggestedReplies![index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Handle quick reply selection
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(reply.text),
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
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == MessageType.text)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black,
                  ),
                ),
              )
            else if (message.type == MessageType.image ||
                     message.type == MessageType.video ||
                     message.type == MessageType.file)
              MediaMessage(message: message)
            else if (message.type == MessageType.linkPreview)
              _buildLinkPreview()
            else if (message.type == MessageType.quickReplies)
              _buildQuickReplies(),
          ],
        ),
      ),
    );
  }
}