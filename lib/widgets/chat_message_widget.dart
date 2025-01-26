import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/chat_message.dart';
import 'video_player_widget.dart';
import 'youtube_player_widget.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onReplyTap;
  final Function(String)? onReactionAdd;

  const ChatMessageWidget({
    Key? key,
    required this.message,
    this.onReplyTap,
    this.onReactionAdd,
  }) : super(key: key);

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  Widget _buildContent() {
    switch (widget.message.type) {
      case MessageType.text:
        return Text(
          widget.message.content,
          style: TextStyle(
            color: widget.message.isMe ? Colors.white : Colors.black,
          ),
        );
      case MessageType.image:
        return Image.network(
          widget.message.mediaUrl!,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error);
          },
        );
      case MessageType.video:
        return VideoPlayerWidget(
          videoUrl: widget.message.mediaUrl!,
          autoPlay: false,
          showControls: true,
        );
      case MessageType.youtube:
        return YouTubePlayerWidget(
          videoUrl: widget.message.mediaUrl!,
        );
      case MessageType.gif:
        return Image.network(
          widget.message.mediaUrl!,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error);
          },
        );
      case MessageType.file:
        return Row(
          children: [
            const Icon(Icons.file_present),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.message.fileName ?? 'File',
                style: TextStyle(
                  color: widget.message.isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.message.isMe ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContent(),
            const SizedBox(height: 4),
            Text(
              '${widget.message.timestamp.hour}:${widget.message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: widget.message.isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}