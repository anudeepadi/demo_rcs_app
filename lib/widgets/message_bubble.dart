import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Widget child;
  final VoidCallback? onReplyTap;
  final Function(String)? onReactionAdd;
  final VoidCallback? onThreadTap;
  final VoidCallback? onLongPress;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.child,
    this.onReplyTap,
    this.onReactionAdd,
    this.onThreadTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (message.suggestedReplies != null && message.suggestedReplies!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              left: message.isMe ? 48 : 16,
              right: message.isMe ? 16 : 48,
              bottom: 8,
            ),
            child: Wrap(
              spacing: 8,
              children: message.suggestedReplies!.map((reply) {
                final quickReply = QuickReply.fromString(reply);
                return _buildQuickReply(context, quickReply);
              }).toList(),
            ),
          ),
        _buildMessageContent(context),
      ],
    );
  }

  Widget _buildQuickReply(BuildContext context, QuickReply reply) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => onReplyTap?.call(),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            reply.text,
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.only(
        left: message.isMe ? 64 : 16,
        right: message.isMe ? 16 : 64,
        bottom: 4,
      ),
      child: Stack(
        children: [
          Material(
            color: message.isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle(
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: message.isMe 
                            ? theme.colorScheme.onPrimary 
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      child: child,
                    ),
                    const SizedBox(height: 4),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
          if (message.reactions.isNotEmpty)
            _buildReactions(context),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.timestamp),
          style: theme.textTheme.bodySmall!.copyWith(
            color: message.isMe 
                ? theme.colorScheme.onPrimary.withOpacity(0.7)
                : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 4),
        _buildStatusIcon(context),
      ],
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final theme = Theme.of(context);
    final color = message.isMe 
        ? theme.colorScheme.onPrimary.withOpacity(0.7)
        : theme.colorScheme.onSurfaceVariant.withOpacity(0.7);

    switch (message.status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      case MessageStatus.sent:
        return Icon(Icons.check, size: 16, color: color);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 16, color: color);
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 16, color: theme.colorScheme.primary);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error);
    }
  }

  Widget _buildReactions(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned(
      bottom: -8,
      right: message.isMe ? null : 8,
      left: message.isMe ? 8 : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...message.reactions.map((reaction) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(reaction.emoji),
            )),
            IconButton(
              icon: const Icon(Icons.add_reaction_outlined, size: 16),
              onPressed: () => onReactionAdd?.call(message.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}