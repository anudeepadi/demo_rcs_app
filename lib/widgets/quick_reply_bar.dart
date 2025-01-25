import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';
import '../providers/chat_provider.dart';
import 'quick_reply_button.dart';

class QuickReplyBar extends StatelessWidget {
  const QuickReplyBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final lastMessage = chatProvider.messages.isNotEmpty 
            ? chatProvider.messages.last 
            : null;

        if (lastMessage == null || 
            lastMessage.type != MessageType.quickReplies ||
            lastMessage.suggestedReplies == null ||
            lastMessage.suggestedReplies!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: lastMessage.suggestedReplies!.length,
            itemBuilder: (context, index) {
              final quickReply = lastMessage.suggestedReplies![index];
              return QuickReplyButton(
                quickReply: quickReply,
                onPressed: () {
                  chatProvider.addTextMessage(
                    quickReply.postbackData ?? quickReply.text,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}