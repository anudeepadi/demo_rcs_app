import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../widgets/media_message.dart';
import '../widgets/bot_suggestions.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showSuggestions;

  const MessageBubble({
    super.key,
    required this.message,
    this.showSuggestions = false,
  });

  bool _isValidUrl(String text) {
    Uri? uri = Uri.tryParse(text);
    return uri != null && 
           (uri.scheme == 'http' || uri.scheme == 'https') && 
           uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final hasMedia = message.type != MessageType.text;
    final isUrl = !hasMedia && _isValidUrl(message.text);
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? 50 : 8,
          right: isUser ? 8 : 50,
          top: 4,
          bottom: showSuggestions ? 16 : 4,
        ),
        child: Column(
          crossAxisAlignment: isUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isUser 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasMedia)
                    MediaMessage(message: message),
                  if (isUrl)
                    Column(
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isUser 
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onBackground,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 150,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.link),
                          ),
                        ),
                      ],
                    )
                  else if (message.text.isNotEmpty)
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isUser 
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                ],
              ),
            ),
            if (showSuggestions)
              const BotSuggestions(),
          ],
        ),
      ),
    );
  }
}