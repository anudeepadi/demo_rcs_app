import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/chat_provider.dart';
import '../providers/server_provider.dart';
import '../widgets/server_sidebar.dart';
import '../widgets/media_message.dart';
import '../models/message.dart';
import '../models/server.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.loadMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const ServerSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildChannelHeader(),
                const Divider(height: 1),
                Expanded(
                  child: _buildMessageList(),
                ),
                _buildMessageInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelHeader() {
    return Consumer<ServerProvider>(
      builder: (context, serverProvider, _) {
        final currentChannel = serverProvider.currentChannel;
        final currentServer = serverProvider.currentServer;
        
        if (currentChannel == null || currentServer == null) {
          return const SizedBox.shrink();
        }

        return AppBar(
          title: Row(
            children: [
              Icon(_getChannelIcon(currentChannel.type)),
              const SizedBox(width: 8),
              Text(currentChannel.name),
            ],
          ),
          actions: [
            const Chip(
              label: Text('Offline Mode'),
              backgroundColor: Colors.amber,
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  Widget _buildMessageList() {
    return Consumer2<ChatProvider, ServerProvider>(
      builder: (context, chatProvider, serverProvider, _) {
        final currentChannel = serverProvider.currentChannel;
        if (currentChannel == null) {
          return const Center(
            child: Text('Select a channel to start chatting'),
          );
        }

        final messages = chatProvider.getMessagesForChannel(currentChannel.id);

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('Be the first to send a message!'),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildMessageItem(message);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(Message message) {
    final isMe = message.isMe;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe && message.senderName != null) ...[
              Text(
                message.senderName!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (message.mediaAttachment != null)
              MediaMessage(
                message: message,
                media: message.mediaAttachment!,
              ),
            if (message.content.isNotEmpty) ...[
              if (message.mediaAttachment != null)
                const SizedBox(height: 8),
              Text(message.content),
            ],
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Consumer<ServerProvider>(
      builder: (context, serverProvider, _) {
        final currentChannel = serverProvider.currentChannel;
        if (currentChannel == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_photo_alternate),
                onPressed: _handleMediaUpload,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleMediaUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (file.path != null) {
          final chatProvider = Provider.of<ChatProvider>(context, listen: false);
          final serverProvider = Provider.of<ServerProvider>(context, listen: false);
          
          final currentChannel = serverProvider.currentChannel;
          final currentServer = serverProvider.currentServer;
          
          if (currentChannel != null && currentServer != null) {
            // TODO: Implement media handling
            // final mediaAttachment = await chatProvider.uploadMedia(file.path!);
            // if (mediaAttachment != null) {
            //   chatProvider.sendMessage(
            //     '',
            //     channelId: currentChannel.id,
            //     serverId: currentServer.id,
            //     type: _getMessageTypeFromFile(file),
            //     mediaAttachment: mediaAttachment,
            //   );
            // }
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading media'),
        ),
      );
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final serverProvider = Provider.of<ServerProvider>(context, listen: false);
    
    final currentChannel = serverProvider.currentChannel;
    final currentServer = serverProvider.currentServer;
    
    if (currentChannel != null && currentServer != null) {
      chatProvider.sendMessage(
        content,
        channelId: currentChannel.id,
        serverId: currentServer.id,
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  IconData _getChannelIcon(ChannelType type) {
    switch (type) {
      case ChannelType.text:
        return Icons.tag;
      case ChannelType.voice:
        return Icons.mic;
      case ChannelType.video:
        return Icons.videocam;
    }
  }

  MessageType _getMessageTypeFromFile(PlatformFile file) {
    final ext = file.extension?.toLowerCase() ?? '';
    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      return MessageType.image;
    } else if (ext == 'gif') {
      return MessageType.gif;
    } else if (['mp4', 'mov', 'avi'].contains(ext)) {
      return MessageType.video;
    }
    return MessageType.file;
  }
}