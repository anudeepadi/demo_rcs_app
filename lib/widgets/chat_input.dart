import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(PlatformFile) onMediaSelected;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    required this.onMediaSelected,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _showSendButton = false;
  bool _isExpanded = false;

  Future<void> _showMediaOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMediaOption(
              icon: Icons.image,
              label: 'Photo',
              onTap: () => _pickMedia(FileType.image),
            ),
            const SizedBox(height: 20),
            _buildMediaOption(
              icon: Icons.videocam,
              label: 'Video',
              onTap: () => _pickMedia(FileType.video),
            ),
            const SizedBox(height: 20),
            _buildMediaOption(
              icon: Icons.cancel,
              label: 'Cancel',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(FileType type) async {
    Navigator.pop(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        widget.onMediaSelected(result.files.first);
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isExpanded ? Icons.close : Icons.add_circle_outline,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
            if (_isExpanded) ...[
              IconButton(
                icon: Icon(Icons.image,
                    color: Theme.of(context).primaryColor),
                onPressed: () => _pickMedia(FileType.image),
              ),
              IconButton(
                icon: Icon(Icons.videocam,
                    color: Theme.of(context).primaryColor),
                onPressed: () => _pickMedia(FileType.video),
              ),
            ],
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (text) {
                          setState(() {
                            _showSendButton = text.trim().isNotEmpty;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: 5,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showSendButton
                  ? IconButton(
                      key: const ValueKey('send'),
                      icon: Icon(Icons.send,
                          color: Theme.of(context).primaryColor),
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) {
                          widget.onSendMessage(_controller.text.trim());
                          _controller.clear();
                          setState(() {
                            _showSendButton = false;
                          });
                        }
                      },
                    )
                  : IconButton(
                      key: const ValueKey('add'),
                      icon: Icon(Icons.attach_file,
                          color: Theme.of(context).primaryColor),
                      onPressed: _showMediaOptions,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}