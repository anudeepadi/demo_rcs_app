import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/quick_reply.dart';
import '../services/api_service.dart';

class BotChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  final ApiService _apiService = ApiService();
  bool _isTyping = false;

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  Future<void> initialize() async {
    // Add initial bot message
    _addMessage(
      Message(
        id: DateTime.now().toString(),
        content: 'Hello! How can I help you today?',
        isMe: false,
        timestamp: DateTime.now(),
        channelId: 'default',
        serverId: 'default',
        quickReplies: const [
          QuickReply(text: 'Help'),
          QuickReply(text: 'Features'),
          QuickReply(text: 'About'),
        ],
      ),
    );
  }

  Future<void> sendMessage(String content, {String? mediaUrl}) async {
    if (content.trim().isEmpty) return;

    // Add user message
    _addMessage(
      Message(
        id: DateTime.now().toString(),
        content: content,
        isMe: true,
        timestamp: DateTime.now(),
        channelId: 'default',
        serverId: 'default',
      ),
    );

    // Show typing indicator
    _setTyping(true);

    try {
      // Get bot response
      final response = await _apiService.getBotResponse(content);
      
      // Add bot message
      _addMessage(
        Message(
          id: DateTime.now().toString(),
          content: response.content,
          isMe: false,
          timestamp: DateTime.now(),
          channelId: 'default',
          serverId: 'default',
          quickReplies: response.quickReplies,
        ),
      );
    } catch (e) {
      debugPrint('Error getting bot response: $e');
      _addMessage(
        Message(
          id: DateTime.now().toString(),
          content: 'Sorry, I encountered an error. Please try again.',
          isMe: false,
          timestamp: DateTime.now(),
          channelId: 'default',
          serverId: 'default',
        ),
      );
    } finally {
      _setTyping(false);
    }
  }

  Future<void> handleQuickReply(QuickReply reply) async {
    await sendMessage(reply.text);
  }

  void _addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void _setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }
}