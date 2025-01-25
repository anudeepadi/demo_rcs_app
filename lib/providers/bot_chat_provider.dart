import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/quick_reply.dart';
import 'package:uuid/uuid.dart';

class BotChatProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  List<QuickReply> _suggestions = [];
  List<QuickReply> get suggestions => _suggestions;

  void setSuggestions(List<QuickReply> suggestions) {
    _suggestions = suggestions;
    notifyListeners();
  }

  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }

  void setWelcomeMessage() {
    _suggestions = [
      QuickReply(text: "👋 Get Started", icon: "play_arrow"),
      QuickReply(text: "🔍 Help", icon: "help"),
      QuickReply(text: "⚙️ Settings", icon: "settings"),
    ];
    notifyListeners();
  }

  Future<ChatMessage> generateResponse(String userMessage) async {
    // Simulate bot processing delay
    await Future.delayed(const Duration(seconds: 1));

    // Example bot logic - you can expand this based on your needs
    if (userMessage.toLowerCase().contains('help')) {
      return ChatMessage(
        id: _uuid.v4(),
        content: "Here's how I can help you:",
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.quickReplies,
        suggestedReplies: [
          QuickReply(text: "💬 Chat Features", postbackData: "features_chat"),
          QuickReply(text: "📎 Share Files", postbackData: "features_files"),
          QuickReply(text: "🎯 Quick Actions", postbackData: "features_actions"),
        ],
      );
    }

    if (userMessage.toLowerCase().contains('settings')) {
      return ChatMessage(
        id: _uuid.v4(),
        content: "Choose a setting to configure:",
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.quickReplies,
        suggestedReplies: [
          QuickReply(text: "🌈 Theme", postbackData: "settings_theme"),
          QuickReply(text: "🔔 Notifications", postbackData: "settings_notifications"),
          QuickReply(text: "🔒 Privacy", postbackData: "settings_privacy"),
        ],
      );
    }

    // Default response with some quick replies
    return ChatMessage(
      id: _uuid.v4(),
      content: "I'm here to help! Select an option below or type your message:",
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.quickReplies,
      suggestedReplies: [
        QuickReply(text: "❓ FAQ", postbackData: "menu_faq"),
        QuickReply(text: "📱 Features", postbackData: "menu_features"),
        QuickReply(text: "🎯 Quick Start", postbackData: "menu_quickstart"),
      ],
    );
  }
}