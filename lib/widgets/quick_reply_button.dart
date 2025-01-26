import 'package:flutter/material.dart';
import '../models/quick_reply.dart';

class QuickReplyButton extends StatelessWidget {
  final QuickReply reply;
  final VoidCallback onTap;

  const QuickReplyButton({
    super.key,
    required this.reply,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reply.icon != null) ...[
              Icon(reply.icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(reply.text),
          ],
        ),
      ),
    );
  }
}