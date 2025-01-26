import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';
import 'package:uuid/uuid.dart';

class BotChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;
  final _uuid = Uuid();

  List<QuickReply> _suggestions = [];
  List<QuickReply> get suggestions => _suggestions;

  List<QuickReply> _defaultQuickReplies = [
    QuickReply(
      id: '1',
      text: 'Help',
      icon: Icons.help,
    ),
    QuickReply(
      id: '2',
      text: 'Settings',
      icon: Icons.settings,
    ),
    QuickReply(
      id: '3',
      text: 'About',
      icon: Icons.info,
    ),
  ];

  void setSuggestions(List<QuickReply> suggestions) {
    _suggestions = suggestions;
    notifyListeners();
  }

  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }

  void addSuggestion(QuickReply suggestion) {
    _suggestions.add(suggestion);
    notifyListeners();
  }

  void addBotGreeting() {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: "Hello! How can I help you today?",
      isMe: false,
      timestamp: DateTime.now(),
      type: MessageType.text,
      suggestedReplies: _defaultQuickReplies,
    );
    _messages.add(message);
    setSuggestions(_defaultQuickReplies);
    notifyListeners();
  }

  // ... (rest of the existing methods)
}