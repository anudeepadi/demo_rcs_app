import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/quick_reply.dart';
import '../models/chat_message.dart';

class BotChatProvider with ChangeNotifier {
  final String botId = 'bot';
  final List<ChatMessage> _messages = [];
  
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  List<QuickReply> get defaultCommands => [
    QuickReply(
      id: 'help',
      text: 'Help',
      value: 'help',
      icon: Icons.help_outline,
    ),
    QuickReply(
      id: 'clear',
      text: 'Clear Chat',
      value: 'clear',
      icon: Icons.clear_all,
    ),
    QuickReply(
      id: 'restart',
      text: 'Restart',
      value: 'restart',
      icon: Icons.refresh,
    ),
  ];

  Future<void> addUserMessage(String content) async {
    final message = ChatMessage(
      senderId: 'user',
      type: MessageType.text,
      content: content,
      isMe: true,
      status: MessageStatus.sent,
    );

    _messages.add(message);
    notifyListeners();
  }

  Future<void> addBotMessage(String content) async {
    final message = ChatMessage(
      senderId: botId,
      type: MessageType.text,
      content: content,
      isMe: false,
      status: MessageStatus.sent,
    );

    _messages.add(message);
    notifyListeners();
  }

  Future<void> addBotQuickReplies({
    required List<QuickReply> replies,
    String? content,
  }) async {
    final message = ChatMessage(
      senderId: botId,
      type: MessageType.quickReply,
      content: content ?? '',
      isMe: false,
      suggestedReplies: replies.map((r) => r.text).toList(),
      status: MessageStatus.sent,
    );

    _messages.add(message);
    notifyListeners();
  }

  Future<void> handleCommand(String command) async {
    switch (command.toLowerCase()) {
      case 'help':
        await addBotMessage('Available commands:\n/help - Show this help\n/clear - Clear chat\n/restart - Restart conversation');
        break;
      case 'clear':
        clear();
        await addBotMessage('Chat cleared');
        break;
      case 'restart':
        clear();
        await addBotMessage('Conversation restarted');
        await addBotQuickReplies(
          replies: defaultCommands,
          content: 'How can I help you?',
        );
        break;
      default:
        await addBotMessage('Unknown command. Type /help for available commands.');
    }
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}