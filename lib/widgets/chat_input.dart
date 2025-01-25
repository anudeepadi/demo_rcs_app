import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback? onMediaSelected;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.onMediaSelected,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (widget.onMediaSelected != null)
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: widget.onMediaSelected,
              ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onSubmitted: (_) => _handleSubmit(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}