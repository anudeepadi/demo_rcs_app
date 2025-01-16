import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/quick_reply.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Message> _messages = [];
  bool _isLoading = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider() {
    // Add some initial test messages
    _addInitialMessages();
  }

  void _addInitialMessages() {
    _messages = [
      Message(
        id: '1',
        content: 'Welcome to RCS Chat! 👋',
        type: MessageType.text,
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        quickReplies: [
          QuickReply(id: '1', text: 'Hello!'),
          QuickReply(id: '2', text: 'Tell me more'),
        ],
      ),
    ];
    notifyListeners();
  }

  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For now, we'll just simulate a delay
      await Future.delayed(const Duration(seconds: 1));
      // Keep existing messages
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String content, {
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

    // Simulate bot response
    await Future.delayed(const Duration(seconds: 1));
    
    // Add bot response
    final botResponse = Message(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: _getBotResponse(content),
      type: MessageType.text,
      isUser: false,
      timestamp: DateTime.now(),
      quickReplies: _getQuickReplies(content),
    );

    _messages.add(botResponse);
    notifyListeners();
  }

  String _getBotResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! How can I help you today? 😊';
    } else if (lowerMessage.contains('bye')) {
      return 'Goodbye! Have a great day! 👋';
    } else if (lowerMessage.contains('help')) {
      return 'I can help you with:\n- Sending messages\n- Sharing images\n- Quick replies';
    } else {
      return 'I received your message: "$userMessage". How else can I help?';
    }
  }

  List<QuickReply>? _getQuickReplies(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return [
        QuickReply(id: '1', text: 'How are you?'),
        QuickReply(id: '2', text: 'Need help'),
        QuickReply(id: '3', text: 'Goodbye'),
      ];
    } else if (lowerMessage.contains('help')) {
      return [
        QuickReply(id: '1', text: 'Show features'),
        QuickReply(id: '2', text: 'Send image'),
      ];
    }
    return null;
  }

  Future<void> handleQuickReply(QuickReply reply) async {
    await sendMessage(reply.text);
  }

  Future<String?> uploadMedia(List<int> bytes, String fileName) async {
    try {
      // For testing, just return a dummy URL
      await Future.delayed(const Duration(seconds: 1));
      return 'https://picsum.photos/200/300';
    } catch (e) {
      debugPrint('Error uploading media: $e');
      return null;
    }
  }
}