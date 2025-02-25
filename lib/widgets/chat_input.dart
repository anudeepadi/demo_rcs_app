import 'package:flutter/material.dart';
import '../services/gif_service.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class ChatInput extends StatefulWidget {
  final Function(String) onMessageSubmit;
  final Function(String) onGifSelected;
  final VoidCallback? onAttachmentPressed;
  final VoidCallback? onVoicePressed;
  final VoidCallback? onCameraPressed;

  const ChatInput({
    Key? key,
    required this.onMessageSubmit,
    required this.onGifSelected,
    this.onAttachmentPressed,
    this.onVoicePressed,
    this.onCameraPressed,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  bool _isSearchingGifs = false;
  bool _isExpanded = false;
  List<String> _gifs = [];
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
    
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.mediumAnimation,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.standardCurve,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _focusNode.removeListener(_handleFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        _isExpanded = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTextChange() {
    setState(() {
      _isComposing = _controller.text.isNotEmpty;
    });
    
    // If text is not empty, collapse the attachment options
    if (_isComposing && _isExpanded) {
      setState(() {
        _isExpanded = false;
      });
      _animationController.reverse();
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _focusNode.unfocus();
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
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
    if (query.isEmpty || !query.startsWith('@gif ')) {
      setState(() {
        _isSearchingGifs = false;
        _gifs = [];
      });
      return;
    }

    final searchQuery = query.substring(5); // Remove "@gif " prefix
    if (searchQuery.isEmpty) return;

    setState(() => _isSearchingGifs = true);
    final gifs = await GifService.searchGifs(searchQuery);
    
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
            child: Text(
              'GIFs',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: _isSearchingGifs
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        width: 120,
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(_gifs[index]),
                            fit: BoxFit.cover,
                          ),
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

  Widget _buildAttachmentOptions() {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAttachmentButton(
              icon: Icons.photo,
              label: 'Gallery',
              color: Colors.purple,
              onTap: widget.onAttachmentPressed,
            ),
            _buildAttachmentButton(
              icon: Icons.camera_alt,
              label: 'Camera',
              color: Colors.red,
              onTap: widget.onCameraPressed,
            ),
            _buildAttachmentButton(
              icon: Icons.mic,
              label: 'Voice',
              color: Colors.orange,
              onTap: widget.onVoicePressed,
            ),
            _buildAttachmentButton(
              icon: Icons.insert_drive_file,
              label: 'Files',
              color: Colors.blue,
              onTap: widget.onAttachmentPressed,
            ),
            _buildAttachmentButton(
              icon: Icons.gif,
              label: 'GIFs',
              color: Colors.green,
              onTap: () {
                _toggleExpanded();
                _controller.text = '@gif ';
                _focusNode.requestFocus();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildGifPicker(),
        _buildAttachmentOptions(),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -1),
                blurRadius: 3,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animationController.value * math.pi / 4,
                      child: Icon(
                        _isExpanded ? Icons.close : Icons.add,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
                onPressed: _toggleExpanded,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _searchGifs,
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[100]
                        : Colors.grey[800],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: _handleSubmitted,
                ),
              ),
              AnimatedSwitcher(
                duration: AppTheme.shortAnimation,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: _isComposing
                    ? IconButton(
                        key: const ValueKey('send'),
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () => _handleSubmitted(_controller.text),
                      )
                    : IconButton(
                        key: const ValueKey('mic'),
                        icon: const Icon(Icons.mic),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: widget.onVoicePressed,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}