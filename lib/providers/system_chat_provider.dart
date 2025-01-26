import 'package:flutter/material.dart';
import '../models/quick_reply.dart';
import '../models/chat_message.dart';
import 'package:uuid/uuid.dart';

class SystemChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;
  final _uuid = Uuid();

  void addUserMessage(String content) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: content,
      isMe: true,
      timestamp: DateTime.now(),
      type: MessageType.text,
      status: MessageStatus.sent,
    );
    _messages.add(message);
    notifyListeners();
  }

  void addGifMessage(String gifUrl) {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: gifUrl,
      isMe: true,
      timestamp: DateTime.now(),
      type: MessageType.gif,
      mediaUrl: gifUrl,
      status: MessageStatus.sent,
    );
    _messages.add(message);
    notifyListeners();
  }

  List<QuickReply> getSystemCommands() {
    return [
      QuickReply(
        text: 'Clear Chat',
        value: '/clear',
        icon: Icons.clear_all,
      ),
      QuickReply(
        text: 'Export Chat',
        value: '/export',
        icon: Icons.download,
      ),
      QuickReply(
        text: 'Theme',
        value: '/theme',
        icon: Icons.palette,
      ),
    ];
  }

  void handleSystemCommand(String command) {
    switch (command) {
      case '/clear':
        _messages.clear();
        break;
      case '/export':
        // Implement export functionality
        break;
      case '/theme':
        // Implement theme switching
        break;
    }
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}