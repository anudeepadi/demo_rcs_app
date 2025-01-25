import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/quick_reply.dart';

class QuickReplyBar extends StatelessWidget {
  const QuickReplyBar({super.key});

  @override
  Widget build(BuildContext context) {
    final quickReplies = [
      QuickReply(id: '1', text: 'Start Chat'),
      QuickReply(id: '2', text: 'Help'),
      QuickReply(id: '3', text: 'Features'),
      QuickReply(id: '4', text: 'About'),
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickReplies.length,
        itemBuilder: (context, index) {
          final reply = quickReplies[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              onPressed: () {
                final chatProvider = Provider.of<ChatProvider>(
                  context,
                  listen: false,
                );
                chatProvider.sendMessage(reply.text);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              child: Text(reply.text),
            ),
          );
        },
      ),
    );
  }
}