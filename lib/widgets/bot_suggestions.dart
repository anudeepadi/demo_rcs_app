import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/quick_reply.dart';

class BotSuggestions extends StatelessWidget {
  const BotSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      QuickReply(
        id: 'yes',
        text: 'Yes',
        postbackData: 'yes_response',
      ),
      QuickReply(
        id: 'no',
        text: 'No',
        postbackData: 'no_response',
      ),
      QuickReply(
        id: 'more',
        text: 'Tell me more',
        postbackData: 'more_info',
      ),
      QuickReply(
        id: 'help',
        text: 'I need help',
        postbackData: 'help_request',
      ),
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton(
              onPressed: () {
                final chatProvider = Provider.of<ChatProvider>(
                  context,
                  listen: false,
                );
                chatProvider.sendMessage(suggestion.text);
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Text(
                suggestion.text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}