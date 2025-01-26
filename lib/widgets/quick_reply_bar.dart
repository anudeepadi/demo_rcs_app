import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_chat_provider.dart';
import '../models/quick_reply.dart';
import 'quick_reply_button.dart';

class QuickReplyBar extends StatelessWidget {
  final Function(String) onReplySelected;

  const QuickReplyBar({
    Key? key,
    required this.onReplySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Consumer<SystemChatProvider>(
        builder: (context, provider, child) {
          final commands = provider.getSystemCommands();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: commands.length,
            itemBuilder: (context, index) {
              final quickReply = commands[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: QuickReplyButton(
                  quickReply: quickReply,
                  onTap: () => onReplySelected(quickReply.value),
                ),
              );
            },
          );
        },
      ),
    );
  }
}