import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';
import 'quick_reply_button.dart';

class QuickReplyBar extends StatelessWidget {
  final ChatMessage message;

  const QuickReplyBar({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type != MessageType.quickReply && 
        message.type != MessageType.suggestion ||
        message.suggestedReplies == null || 
        message.suggestedReplies!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: message.suggestedReplies!.length,
        itemBuilder: (context, index) {
          final reply = message.suggestedReplies![index];
          return QuickReplyButton(
            reply: reply,
            onTap: () {
              context.read<ChatProvider>().addTextMessage(reply.text);
            },
          );
        },
      ),
    );
  }
}