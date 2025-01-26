import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';
import 'video_preview.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String)? onQuickReplySelected;

  const ChatBubble({
    Key? key,
    required this.message,
    this.onQuickReplySelected,
  }) : super(key: key);

  bool get _isYouTubeLink {
    return message.content.contains('youtube.com') || 
           message.content.contains('youtu.be');
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.blue.shade700 
                    : const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: _isYouTubeLink ? EdgeInsets.zero : const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: _buildMessageContent(context),
            ),
            if (message.suggestedReplies?.isNotEmpty ?? false)
              _buildQuickReplies(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    if (_isYouTubeLink && message.linkPreview != null) {
      return VideoPreview(
        videoUrl: message.linkPreview!.url,
        thumbnailUrl: message.linkPreview!.imageUrl ?? '',
        title: message.linkPreview!.title ?? '',
      );
    }

    return SelectableText(
      message.content,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  Widget _buildQuickReplies(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: message.suggestedReplies!.length,
        itemBuilder: (context, index) {
          final reply = message.suggestedReplies![index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: OutlinedButton(
              onPressed: () => onQuickReplySelected?.call(reply.text),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade300,
                side: BorderSide(color: Colors.blue.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
              ),
              child: Text(
                reply.text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}