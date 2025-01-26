import 'package:flutter/material.dart';
import '../models/quick_reply.dart';

class QuickReplyButton extends StatelessWidget {
  final QuickReply quickReply;
  final VoidCallback onTap;
  final bool isSelected;

  const QuickReplyButton({
    Key? key,
    required this.quickReply,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            ),
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (quickReply.icon != null) ...[
                Icon(
                  quickReply.icon,
                  size: 18,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                ),
                const SizedBox(width: 8),
              ],
              Text(
                quickReply.text,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}