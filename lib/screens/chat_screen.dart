import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/bot_chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/quick_reply_bar.dart';
import '../widgets/suggestion_bar.dart';
import '../widgets/chat_input.dart';
import '../models/quick_reply.dart';
import '../services/link_preview_service.dart';
import '../services/gif_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final LinkPreviewService _linkPreviewService = LinkPreviewService();
  final GifService _gifService = GifService();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final botProvider = Provider.of<BotChatProvider>(context, listen: false);
    await Future.delayed(const Duration(milliseconds: 500));
    botProvider.setWelcomeMessage();
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

  Future<void> _handleMessageSubmit(String message) async {
    if (message.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final botProvider = Provider.of<BotChatProvider>(context, listen: false);

    // Add user message
    chatProvider.addTextMessage(message);
    _scrollToBottom();

    // Check for link preview
    if (_linkPreviewService.isValidUrl(message)) {
      setState(() => _isTyping = true);
      final preview = await _linkPreviewService.fetchLinkPreview(message);
      if (preview != null) {
        chatProvider.addLinkPreviewMessage(preview);
      }
    }

    // Simulate bot typing
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(seconds: 1));

    // Bot response with quick replies
    final response = await botProvider.generateResponse(message);
    chatProvider.addBotMessage(response);
    
    setState(() => _isTyping = false);
    _scrollToBottom();

    // Add quick reply suggestions
    if (response.suggestedReplies?.isNotEmpty ?? false) {
      botProvider.setSuggestions(response.suggestedReplies!);
    }
  }

  Future<void> _handleGifSelected(String gifUrl) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addGifMessage(gifUrl);
    _scrollToBottom();
  }

  void _handleQuickReplySelected(QuickReply reply) {
    _handleMessageSubmit(reply.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RCS Demo Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SuggestionBar(),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: chatProvider.messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatProvider.messages.length && _isTyping) {
                        return const TypingIndicator();
                      }
                      final message = chatProvider.messages[index];
                      return ChatBubble(
                        message: message,
                        onQuickReplySelected: _handleQuickReplySelected,
                      );
                    },
                  );
                },
              ),
            ),
            const QuickReplyBar(),
            ChatInput(
              onMessageSubmit: _handleMessageSubmit,
              onGifSelected: _handleGifSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedDot(delay: index * 300),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedDot extends StatefulWidget {
  final int delay;

  const AnimatedDot({Key? key, required this.delay}) : super(key: key);

  @override
  State<AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.4 + (_controller.value * 0.6)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}