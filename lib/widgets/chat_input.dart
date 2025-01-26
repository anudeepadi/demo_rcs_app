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
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onMessageSubmit(message);
      _controller.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }

  Future<void> _showAttachmentOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.gif,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('GIF'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _isShowingGifPicker = true);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.attach_file,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
        ),
      ),
    );
  }

  Widget _buildGifPicker() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search GIFs...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                return InkWell(
                  onTap: () {
                    widget.onGifSelected(_gifs[index]);
                    setState(() => _isShowingGifPicker = false);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _gifs[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
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
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAttachmentOptions,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _isComposing = text.trim().isNotEmpty;
                        });
                      },
                      onSubmitted: (text) => _handleSubmit(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _isComposing
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).disabledColor,
                    ),
                    onPressed: _isComposing ? _handleSubmit : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}