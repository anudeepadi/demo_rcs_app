import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';
import 'message_reactions.dart';
import 'file_preview.dart';
import 'voice_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onReplyTap;
  final Function(String)? onReactionAdd;
  final VoidCallback? onThreadTap;

  const ChatBubble({
    Key? key,
    required this.message,
    this.onReplyTap,
    this.onReactionAdd,
    this.onThreadTap,
  }) : super(key: key);

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: message.isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        );
      case MessageType.image:
        return FilePreview(
          url: message.mediaUrl!,
          type: FileType.image,
          thumbnailUrl: message.thumbnailUrl,
        );
      case MessageType.video:
        return FilePreview(
          url: message.mediaUrl!,
          type: FileType.video,
          thumbnailUrl: message.thumbnailUrl,
        );
      case MessageType.voice:
        return VoiceMessage(
          duration: message.voiceDuration!,
          waveform: message.voiceWaveform!,
          url: message.mediaUrl!,
          isMe: message.isMe,
        );
      case MessageType.file:
        return FilePreview(
          url: message.mediaUrl!,
          type: FileType.file,
          fileName: message.fileName,
          fileSize: message.fileSize,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatus() {
    IconData? icon;
    Color? color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = AppTheme.primaryLight;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = AppTheme.errorLight;
        break;
    }

    return Icon(icon, size: 16, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.parentMessageId != null)
              GestureDetector(
                onTap: onThreadTap,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'View thread',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: message.isMe
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: message.isMe ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        _buildStatus(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (message.reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: MessageReactions(
                  reactions: message.reactions,
                  onReactionAdd: onReactionAdd,
                ),
              ),
            if (message.threadMessageIds.isNotEmpty)
              GestureDetector(
                onTap: onThreadTap,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${message.threadMessageIds.length} replies',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}