import 'package:flutter/material.dart';
import '../models/quick_reply.dart';

class QuickReplyButton extends StatelessWidget {
  final QuickReply quickReply;
  final VoidCallback onPressed;

  const QuickReplyButton({
    Key? key,
    required this.quickReply,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: onPressed,
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
            if (quickReply.icon != null) ...[
              Icon(
                IconData(
                  int.parse(quickReply.icon!),
                  fontFamily: 'MaterialIcons',
                ),
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(quickReply.text),
          ],
        ),
      ),
    );
  }
}