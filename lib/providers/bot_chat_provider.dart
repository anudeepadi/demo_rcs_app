import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/message.dart';
import '../models/quick_reply.dart';

class BotChatProvider with ChangeNotifier {
  final List<Message> _messages = [];
  bool _isTyping = false;

  List<Message> get messages => _messages;
  bool get isTyping => _isTyping;

  void initialize() {
    _messages.clear();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Hello! Welcome to RCS Chat Bot! 👋\nHow can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
      quickReplies: [
        QuickReply(id: '1', text: 'Show Features'),
        QuickReply(id: '2', text: 'Help'),
        QuickReply(id: '3', text: 'Send Image'),
      ],
    );
    _messages.add(welcomeMessage);
    notifyListeners();
  }

  Future<void> sendMessage({
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    // Add user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
      mediaUrl: mediaUrl,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    // Generate bot response
    _isTyping = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final botResponse = _generateBotResponse(content);
    _messages.add(botResponse);
    
    _isTyping = false;
    notifyListeners();
  }

  Message _generateBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    String response;
    List<QuickReply>? quickReplies;
    MessageType type = MessageType.text;

    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      response = 'Hi there! How can I assist you today? 😊';
      quickReplies = [
        QuickReply(id: '1', text: 'Show Features'),
        QuickReply(id: '2', text: 'Help'),
      ];
    } else if (lowerMessage.contains('feature')) {
      response = '''Here are the available features:
1. Text messaging
2. Image sharing
3. Video sharing
4. Quick replies
5. Rich media messages''';
      quickReplies = [
        QuickReply(id: '1', text: 'Try Image'),
        QuickReply(id: '2', text: 'Try Video'),
      ];
    } else if (lowerMessage.contains('help')) {
      response = '''I can help you with:
• Sending messages
• Sharing images and videos
• Using quick replies
What would you like to try?''';
      quickReplies = [
        QuickReply(id: '1', text: 'Send Image'),
        QuickReply(id: '2', text: 'Show Features'),
      ];
    } else if (lowerMessage.contains('image')) {
      response = 'You can send images by clicking the attachment button below. '
          'I support various image formats including JPG, PNG, and GIF.';
      quickReplies = [
        QuickReply(id: '1', text: 'Try Video'),
        QuickReply(id: '2', text: 'Help'),
      ];
    } else if (lowerMessage.contains('video')) {
      response = 'You can share videos by clicking the attachment button. '
          'I support MP4 video format with preview and playback controls.';
      quickReplies = [
        QuickReply(id: '1', text: 'Try Image'),
        QuickReply(id: '2', text: 'Help'),
      ];
    } else if (lowerMessage.contains('bye')) {
      response = 'Goodbye! Have a great day! 👋';
    } else {
      response = 'I received your message. Is there anything specific you\'d like to know about? '
          'I can help you with messages, images, videos, and more!';
      quickReplies = [
        QuickReply(id: '1', text: 'Show Features'),
        QuickReply(id: '2', text: 'Help'),
      ];
    }

    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      type: type,
      isUser: false,
      timestamp: DateTime.now(),
      quickReplies: quickReplies,
    );
  }

  Future<void> handleQuickReply(QuickReply reply) async {
    await sendMessage(content: reply.text);
  }

  Future<String?> handleMediaUpload(List<int> bytes, String fileName) async {
    // For demo purposes, return a placeholder image URL
    await Future.delayed(const Duration(seconds: 1));
    return 'https://via.placeholder.com/300';
  }

  void clearMessages() {
    _messages.clear();
    _addWelcomeMessage();
  }
}