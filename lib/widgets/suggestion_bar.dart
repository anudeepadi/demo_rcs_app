import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/quick_reply.dart';

class SuggestionBar extends StatelessWidget {
  final List<QuickReply> suggestions;
  final VoidCallback? onSuggestionSelected;

  const SuggestionBar({
    Key? key,
    required this.suggestions,
    this.onSuggestionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SuggestionChip(
              suggestion: suggestion,
              onTap: () {
                context.read<ChatProvider>().addTextMessage(
                  content: suggestion.text,
                );
                onSuggestionSelected?.call();
              },
            ),
          );
        },
      ),
    );
  }
}

class SuggestionChip extends StatelessWidget {
  final QuickReply suggestion;
  final VoidCallback? onTap;

  const SuggestionChip({
    Key? key,
    required this.suggestion,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: suggestion.isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (suggestion.icon != null) ...[
                Icon(
                  suggestion.icon,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                suggestion.text,
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