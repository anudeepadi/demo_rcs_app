import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

class GeminiChatProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isGenerating => _isGenerating;

  Future<void> sendMessage(String content) async {
    // Add user message
    final userMessage = ChatMessage(
      senderId: 'user',
      type: MessageType.text,
      content: content,
      isMe: true,
    );
    _messages.add(userMessage);
    notifyListeners();

    // Generate and add bot response
    _isGenerating = true;
    notifyListeners();

    try {
      final response = await _geminiService.generateResponse(content);
      final botMessage = ChatMessage(
        senderId: 'gemini',
        type: MessageType.text,
        content: response,
        isMe: false,
      );
      _messages.add(botMessage);

      // Generate quick reply suggestions
      final suggestions = await _geminiService.generateChatSuggestions(response);
      if (suggestions.isNotEmpty) {
        final suggestionsMessage = ChatMessage(
          senderId: 'gemini',
          type: MessageType.quickReply,
          content: '',
          isMe: false,
          suggestedReplies: suggestions,
        );
        _messages.add(suggestionsMessage);
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        senderId: 'gemini',
        type: MessageType.text,
        content: 'Sorry, I encountered an error while generating a response.',
        isMe: false,
      );
      _messages.add(errorMessage);
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}