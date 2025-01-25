import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/gif_service.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onMessageSubmit;
  final Function(String) onGifSelected;

  const ChatInput({
    Key? key,
    required this.onMessageSubmit,
    required this.onGifSelected,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final GifService _gifService = GifService();
  bool _isShowingGifPicker = false;
  String _gifSearchQuery = '';
  List<String> _gifs = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final message = _controller.text;
    if (message.trim().isNotEmpty) {
      widget.onMessageSubmit(message);
      _controller.clear();
    }
  }

  Future<void> _showAttachmentOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.gif),
            title: const Text('GIF'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _isShowingGifPicker = true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('File'),
            onTap: () async {
              Navigator.pop(context);
              final result = await FilePicker.platform.pickFiles();
              if (result != null) {
                // Handle file
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGifPicker() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search GIFs...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (value) async {
                      setState(() => _gifSearchQuery = value);
                      if (value.isNotEmpty) {
                        final gifs = await _gifService.searchGifs(value);
                        setState(() => _gifs = gifs);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _isShowingGifPicker = false),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4/3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _gifs.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    widget.onGifSelected(_gifs[index]);
                    setState(() => _isShowingGifPicker = false);
                  },
                  child: Image.network(
                    _gifs[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isShowingGifPicker) _buildGifPicker(),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _showAttachmentOptions,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
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
      ],
    );
  }
}