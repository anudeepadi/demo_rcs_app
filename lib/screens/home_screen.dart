import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_message_widget.dart';
import '../services/media_picker_service.dart';
import '../models/chat_message.dart';
import '../utils/youtube_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isDrawerOpen = false;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleTextChange);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      _isComposing = _messageController.text.isNotEmpty;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    if (YouTubeHelper.isValidYouTubeUrl(text)) {
      chatProvider.sendMedia(text, MessageType.youtube);
    } else {
      chatProvider.addTextMessage(text);
    }
    
    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _pickMedia() async {
    final result = await MediaPickerService.pickMedia(
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final path = file.path;
      
      if (path != null) {
        final chatProvider = context.read<ChatProvider>();
        if (MediaPickerService.isVideoFile(path)) {
          chatProvider.sendMedia(path, MessageType.video);
        } else if (MediaPickerService.isGifFile(path)) {
          chatProvider.sendMedia(path, MessageType.gif);
        } else if (MediaPickerService.isImageFile(path)) {
          chatProvider.sendMedia(path, MessageType.image);
        }
        _scrollToBottom();
      }
    }
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Center(
              child: Text(
                'Channels',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  onTap: () {
                    setState(() => _isDrawerOpen = false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('WhatsApp'),
                  onTap: () {
                    setState(() => _isDrawerOpen = false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.message),
                  title: const Text('SMS'),
                  onTap: () {
                    setState(() => _isDrawerOpen = false);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.forum),
                  title: const Text('RCS'),
                  onTap: () {
                    setState(() => _isDrawerOpen = false);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
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
            onPressed: _pickMedia,
            tooltip: 'Attach media',
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: _isComposing ? Theme.of(context).primaryColor : Colors.grey,
            onPressed: _isComposing
                ? () => _handleSubmitted(_messageController.text)
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RCS Demo App'),
        leading: IconButton(
          icon: Icon(_isDrawerOpen ? Icons.menu_open : Icons.menu),
          onPressed: () {
            setState(() {
              _isDrawerOpen = !_isDrawerOpen;
            });
          },
        ),
      ),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isDrawerOpen ? 250 : 0,
            child: _isDrawerOpen ? _buildSidebar() : null,
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Consumer<ChatProvider>(
                    builder: (context, chatProvider, child) {
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          return ChatMessageWidget(
                            message: chatProvider.messages[index],
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}