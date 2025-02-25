import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class MessageReactions extends StatefulWidget {
  final List<MessageReaction> reactions;
  final Function(String)? onReactionAdd;

  const MessageReactions({
    Key? key,
    required this.reactions,
    this.onReactionAdd,
  }) : super(key: key);

  @override
  State<MessageReactions> createState() => _MessageReactionsState();
}

class _MessageReactionsState extends State<MessageReactions> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.shortAnimation,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, int> _getReactionCounts() {
    final counts = <String, int>{};
    for (final reaction in widget.reactions) {
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final reactionCounts = _getReactionCounts();
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ...reactionCounts.entries.map((entry) => _ReactionChip(
                emoji: entry.key,
                count: entry.value,
                onTap: () => widget.onReactionAdd?.call(entry.key),
              )),
          _AddReactionButton(
            onPressed: () => _showReactionPicker(context),
          ),
        ],
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Add Reaction',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 8,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                '👍', '❤️', '😊', '😂', '😮', '😢', '😡', '👏',
                '🎉', '🤔', '👀', '🔥', '💯', '✨', '🎨', '🚀',
                '😍', '🥰', '😘', '🤩', '🙌', '🤝', '👋', '🙏',
              ].map((emoji) => _EmojiButton(
                emoji: emoji,
                onTap: () {
                  widget.onReactionAdd?.call(emoji);
                  Navigator.pop(context);
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionChip extends StatefulWidget {
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
  State<_ReactionChip> createState() => _ReactionChipState();
}

class _ReactionChipState extends State<_ReactionChip> {
  bool _isHovering = false;
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: AppTheme.shortAnimation,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _isHovering 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovering 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            boxShadow: _isHovering ? [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 16)),
              if (widget.count > 1) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.grey[700]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddReactionButton extends StatefulWidget {
  final VoidCallback onPressed;
  
  const _AddReactionButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  State<_AddReactionButton> createState() => _AddReactionButtonState();
}

class _AddReactionButtonState extends State<_AddReactionButton> {
  bool _isHovering = false;
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: AppTheme.shortAnimation,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _isHovering 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isHovering 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            boxShadow: _isHovering ? [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Icon(
            Icons.add_reaction_outlined,
            size: 16,
            color: _isHovering
                ? Theme.of(context).colorScheme.primary
                : (isDarkMode ? Colors.white70 : Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}

class _EmojiButton extends StatefulWidget {
  final String emoji;
  final VoidCallback onTap;
  
  const _EmojiButton({
    Key? key,
    required this.emoji,
    required this.onTap,
  }) : super(key: key);
  
  @override
  State<_EmojiButton> createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<_EmojiButton> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.shortAnimation,
          decoration: BoxDecoration(
            color: _isHovering 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Center(
              child: Text(
                widget.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}