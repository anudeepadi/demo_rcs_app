import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quick_reply.dart';
import '../providers/chat_provider.dart';
import '../providers/bot_chat_provider.dart';

class BotSuggestions extends StatelessWidget {
  const BotSuggestions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BotChatProvider>(
      builder: (context, botProvider, _) {
        if (botProvider.suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: botProvider.suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = botProvider.suggestions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  onPressed: () {
                    final chatProvider = Provider.of<ChatProvider>(
                      context, 
                      listen: false,
                    );
                    chatProvider.addTextMessage(suggestion.text);
                    botProvider.clearSuggestions();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (suggestion.icon != null) ...[
                        Icon(
                          IconData(
                            int.parse(suggestion.icon!),
                            fontFamily: 'MaterialIcons',
                          ),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(suggestion.text),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}