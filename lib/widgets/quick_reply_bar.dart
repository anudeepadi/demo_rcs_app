import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bot_chat_provider.dart';
import '../models/quick_reply.dart';

class QuickReplyBar extends StatelessWidget {
  final VoidCallback? onReplySelected;

  const QuickReplyBar({
    Key? key,
    this.onReplySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BotChatProvider>(
      builder: (context, provider, child) {
        final commands = provider.defaultCommands;
        
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: commands.length,
            itemBuilder: (context, index) {
              final command = commands[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _QuickReplyChip(
                  reply: command,
                  onTap: () {
                    provider.handleCommand(command.value);
                    onReplySelected?.call();
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  final QuickReply reply;
  final VoidCallback? onTap;

  const _QuickReplyChip({
    Key? key,
    required this.reply,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: reply.isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (reply.icon != null) ...[
                Icon(
                  reply.icon,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                reply.text,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}