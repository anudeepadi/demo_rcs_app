import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/channel_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/system_chat_provider.dart';
import 'chat_bubble.dart';
import 'chat_input.dart';

class ChatView extends StatelessWidget {
  final bool isSystemChat;

  const ChatView({
    Key? key,
    required this.isSystemChat,
  }) : super(key: key);

  void _handleMessageSubmit(BuildContext context, String message) {
    if (isSystemChat) {
      final systemChatProvider = Provider.of<SystemChatProvider>(
        context, 
        listen: false,
      );
      systemChatProvider.addUserMessage(message);
    } else {
      final chatProvider = Provider.of<ChatProvider>(
        context, 
        listen: false,
      );
      chatProvider.addTextMessage(message);
    }
  }

  void _handleGifSelected(BuildContext context, String gifUrl) {
    if (isSystemChat) {
      final systemChatProvider = Provider.of<SystemChatProvider>(
        context, 
        listen: false,
      );
      systemChatProvider.addGifMessage(gifUrl);
    } else {
      final chatProvider = Provider.of<ChatProvider>(
        context, 
        listen: false,
      );
      chatProvider.addGifMessage(gifUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isSystemChat) {
      return Column(
        children: [
          AppBar(
            title: const Text('RCS Assistant'),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  _handleMessageSubmit(context, "Help");
                },
              ),
            ],
          ),
          Expanded(
            child: _SystemChatMessages(),
          ),
          ChatInput(
            onMessageSubmit: (message) => _handleMessageSubmit(context, message),
            onGifSelected: (gifUrl) => _handleGifSelected(context, gifUrl),
          ),
        ],
      );
    }

    return Consumer<ChannelProvider>(
      builder: (context, channelProvider, _) {
        final selectedChannelId = channelProvider.selectedChannelId;
        
        if (selectedChannelId == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select a channel to start chatting',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildChannelAppBar(context, channelProvider),
            const Expanded(
              child: _ChannelChatMessages(),
            ),
            ChatInput(
              onMessageSubmit: (message) => _handleMessageSubmit(context, message),
              onGifSelected: (gifUrl) => _handleGifSelected(context, gifUrl),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChannelAppBar(BuildContext context, ChannelProvider channelProvider) {
    final selectedChannel = channelProvider.channels.firstWhere(
      (channel) => channel.id == channelProvider.selectedChannelId,
    );

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(selectedChannel.name),
          if (selectedChannel.description != null)
            Text(
              selectedChannel.description!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement chat search
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Show channel options
          },
        ),
      ],
    );
  }
}

class _SystemChatMessages extends StatefulWidget {
  @override
  _SystemChatMessagesState createState() => _SystemChatMessagesState();
}

class _SystemChatMessagesState extends State<_SystemChatMessages> {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemChatProvider>(
      builder: (context, systemChatProvider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8.0),
          itemCount: systemChatProvider.messages.length,
          itemBuilder: (context, index) {
            final message = systemChatProvider.messages[index];
            return ChatBubble(message: message);
          },
        );
      },
    );
  }
}

class _ChannelChatMessages extends StatefulWidget {
  const _ChannelChatMessages();

  @override
  _ChannelChatMessagesState createState() => _ChannelChatMessagesState();
}

class _ChannelChatMessagesState extends State<_ChannelChatMessages> {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8.0),
          itemCount: chatProvider.messages.length,
          itemBuilder: (context, index) {
            final message = chatProvider.messages[index];
            return ChatBubble(message: message);
          },
        );
      },
    );
  }
}