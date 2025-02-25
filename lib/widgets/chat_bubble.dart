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
  final VoidCallback? onLongPress;
  final bool isSelected;

  const ChatBubble({
    Key? key,
    required this.message,
    this.onReplyTap,
    this.onReactionAdd,
    this.onThreadTap,
    this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: message.isMe 
              ? Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black
              : Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
        );
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FilePreview(
            url: message.mediaUrl!,
            type: FileType.image,
            thumbnailUrl: message.thumbnailUrl,
          ),
        );
      case MessageType.video:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FilePreview(
            url: message.mediaUrl!,
            type: FileType.video,
            thumbnailUrl: message.thumbnailUrl,
          ),
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
    String? tooltip;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.grey;
        tooltip = "Sending";
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        tooltip = "Sent";
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        tooltip = "Delivered";
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Theme.of(message.isMe ? Brightness.light : Brightness.dark) == Brightness.light 
          ? AppTheme.primaryLight 
          : AppTheme.primaryDark;
        tooltip = "Read";
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Theme.of(message.isMe ? Brightness.light : Brightness.dark) == Brightness.light 
          ? AppTheme.errorLight 
          : AppTheme.errorDark;
        tooltip = "Failed";
        break;
    }

    return Tooltip(
      message: tooltip ?? "",
      child: Icon(icon, size: 16, color: color),
    );
  }

  Color _getBubbleColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (message.isMe) {
      return isDarkMode ? AppTheme.sentMessageDark : AppTheme.sentMessageLight;
    } else {
      return isDarkMode ? AppTheme.receivedMessageDark : AppTheme.receivedMessageLight;
    }
  }

  Color _getTextColor(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (message.isMe) {
      return isDarkMode ? Colors.white : Colors.black;
    } else {
      return isDarkMode ? Colors.white : Colors.black87;
    }
  }

  BorderRadius _getBubbleRadius() {
    return BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(message.isMe ? 20 : 5),
      bottomRight: Radius.circular(message.isMe ? 5 : 20),
    );
  }

  Widget _buildThreadIndicator(BuildContext context, String text) {
    return GestureDetector(
      onTap: onThreadTap,
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.80,
          ),
          child: Column(
            crossAxisAlignment:
                message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.parentMessageId != null)
                _buildThreadIndicator(context, 'View thread'),
              AnimatedContainer(
                duration: AppTheme.mediumAnimation,
                curve: AppTheme.standardCurve,
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _getBubbleColor(context),
                  borderRadius: _getBubbleRadius(),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  border: isSelected 
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContent(context),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getTextColor(context).withOpacity(0.6),
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
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: MessageReactions(
                    reactions: message.reactions,
                    onReactionAdd: onReactionAdd,
                  ),
                ),
              if (message.threadMessageIds.isNotEmpty)
                _buildThreadIndicator(
                  context, 
                  '${message.threadMessageIds.length} ${message.threadMessageIds.length == 1 ? 'reply' : 'replies'}'
                ),
            ],
          ),
        ),
      ),
    );
  }
}