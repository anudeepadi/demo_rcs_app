import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageReactions extends StatelessWidget {
  final List<MessageReaction> reactions;
  final Function(String)? onReactionAdd;

  const MessageReactions({
    Key? key,
    required this.reactions,
    this.onReactionAdd,
  }) : super(key: key);

  Map<String, int> _getReactionCounts() {
    final counts = <String, int>{};
    for (final reaction in reactions) {
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final reactionCounts = _getReactionCounts();

    return Wrap(
      spacing: 4,
      children: [
        ...reactionCounts.entries.map((entry) => _ReactionChip(
              emoji: entry.key,
              count: entry.value,
              onTap: () => onReactionAdd?.call(entry.key),
            )),
        IconButton(
          icon: const Icon(Icons.add_reaction_outlined, size: 18),
          onPressed: () => _showReactionPicker(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
        ),
      ],
    );
  }

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 8,
              padding: const EdgeInsets.all(16),
              children: [
                '👍', '❤️', '😊', '😂', '😮', '😢', '😡', '👏',
                '🎉', '🤔', '👀', '🔥', '💯', '✨', '🎨', '🚀',
              ].map((emoji) => InkWell(
                onTap: () {
                  onReactionAdd?.call(emoji);
                  Navigator.pop(context);
                },
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final String emoji;
  final int count;
  final VoidCallback? onTap;

  const _ReactionChip({
    Key? key,
    required this.emoji,
    required this.count,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            if (count > 1) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}