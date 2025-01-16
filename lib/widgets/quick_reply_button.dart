import 'package:flutter/material.dart';
import '../models/quick_reply.dart';

class QuickReplyButton extends StatelessWidget {
  final QuickReply reply;
  final Function(dynamic) onTap;

  const QuickReplyButton({
    super.key,
    required this.reply,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(reply),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            border: Border.all(
              color: primaryColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            reply.text,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}