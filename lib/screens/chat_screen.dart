import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  final String title;

  const ChatScreen({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
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

  Widget _buildMessage(BuildContext context, ChatMessage message) {
    return ChatBubble(
      message: message,
      child: _buildMessageContent(message),
      onReplyTap: () {
        // Handle reply tap
      },
      onReactionAdd: (emoji) {
        context.read<ChatProvider>().addReaction(message.id, emoji);
      },
      onThreadTap: () {
        // Handle thread tap
      },
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return Text(message.content);
      case MessageType.image:
        return Image.network(
          message.mediaUrl ?? '',
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / 
                      progress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error_outline),
            );
          },
        );
      case MessageType.video:
        return Container(
          height: 200,
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 48,
            ),
          ),
        );
      case MessageType.gif:
        return Image.network(
          message.mediaUrl ?? '',
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / 
                      progress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error_outline),
            );
          },
        );
      case MessageType.file:
        return ListTile(
          leading: const Icon(Icons.insert_drive_file),
          title: Text(message.fileName ?? 'File'),
          subtitle: message.fileSize != null
              ? Text(_formatFileSize(message.fileSize!))
              : null,
          trailing: const Icon(Icons.download),
        );
      case MessageType.audio:
        return Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow),
              const SizedBox(width: 8),
              const Text('Audio Message'),
            ],
          ),
        );
      case MessageType.youtube:
        return Container(
          height: 200,
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 48,
            ),
          ),
        );
      case MessageType.quickReply:
        if (message.suggestedReplies?.isEmpty ?? true) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(message.content),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: message.suggestedReplies!.map((reply) {
                return ActionChip(
                  label: Text(reply),
                  onPressed: () {
                    context.read<ChatProvider>().addTextMessage(
                      content: reply,
                    );
                  },
                );
              }).toList(),
            ),
          ],
        );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Clear Chat'),
            onTap: () {
              context.read<ChatProvider>().clear();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Chat Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to chat settings
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return _buildMessage(context, message);
                  },
                ),
              ),
              MessageInput(
                onSendMessage: (content) {
                  chatProvider.addTextMessage(content: content);
                  _scrollToBottom();
                },
                onSendMedia: (file, type) {
                  chatProvider.sendMedia(
                    file: file,
                    type: type,
                  );
                  _scrollToBottom();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}