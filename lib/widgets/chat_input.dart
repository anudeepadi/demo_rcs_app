import 'package:flutter/material.dart';
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
  bool _isComposing = false;
  bool _isSearchingGifs = false;
  List<String> _gifs = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      _isComposing = _controller.text.isNotEmpty;
    });
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    
    widget.onMessageSubmit(text);
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  Future<void> _searchGifs(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearchingGifs = false;
        _gifs = [];
      });
      return;
    }

    setState(() => _isSearchingGifs = true);
    final gifs = await GifService.searchGifs(query);
    
    if (mounted) {
      setState(() {
        _gifs = gifs;
        _isSearchingGifs = false;
      });
    }
  }

  Widget _buildGifPicker() {
    if (!_isSearchingGifs && _gifs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: 8),
      child: _isSearchingGifs
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _gifs.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    widget.onGifSelected(_gifs[index]);
                    _controller.clear();
                    setState(() {
                      _isSearchingGifs = false;
                      _gifs = [];
                    });
                  },
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(_gifs[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildGifPicker(),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -2),
                blurRadius: 4,
                color: Colors.black12,
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () {
                  // Handle file attachment
                },
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _searchGifs,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  onSubmitted: _handleSubmitted,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_controller.text)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}