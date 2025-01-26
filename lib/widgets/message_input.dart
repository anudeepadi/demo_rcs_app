import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/chat_message.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(File, MessageType) onSendMedia;
  final bool enabled;

  const MessageInput({
    Key? key,
    required this.onSendMessage,
    required this.onSendMedia,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _controller.clear();
    setState(() {
      _isComposing = false;
    });

    widget.onSendMessage(text);
  }

  Future<void> _handleMediaPicker(MessageType type) async {
    try {
      FileType fileType;
      List<String> allowedExtensions;

      switch (type) {
        case MessageType.image:
          fileType = FileType.image;
          allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
          break;
        case MessageType.video:
          fileType = FileType.video;
          allowedExtensions = ['mp4', 'mov', 'avi'];
          break;
        case MessageType.audio:
          fileType = FileType.audio;
          allowedExtensions = ['mp3', 'wav', 'm4a'];
          break;
        case MessageType.file:
          fileType = FileType.any;
          allowedExtensions = [];
          break;
        default:
          return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions.isNotEmpty ? allowedExtensions : null,
      );

      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        final file = File(result.files.first.path!);
        widget.onSendMedia(file, type);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking media: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file, color: colorScheme.onSurfaceVariant),
              onPressed: widget.enabled
                  ? () => _showAttachmentOptions(context)
                  : null,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.trim().isNotEmpty;
                  });
                },
                onSubmitted: widget.enabled ? _handleSubmitted : null,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: _isComposing ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              onPressed: !widget.enabled || !_isComposing
                  ? null
                  : () => _handleSubmitted(_controller.text),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.image, color: colorScheme.primary),
              title: const Text('Image'),
              onTap: () {
                Navigator.pop(context);
                _handleMediaPicker(MessageType.image);
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam, color: colorScheme.primary),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                _handleMediaPicker(MessageType.video);
              },
            ),
            ListTile(
              leading: Icon(Icons.audio_file, color: colorScheme.primary),
              title: const Text('Audio'),
              onTap: () {
                Navigator.pop(context);
                _handleMediaPicker(MessageType.audio);
              },
            ),
            ListTile(
              leading: Icon(Icons.file_present, color: colorScheme.primary),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                _handleMediaPicker(MessageType.file);
              },
            ),
          ],
        ),
      ),
    );
  }
}