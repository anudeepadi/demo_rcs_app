import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';

class BotService {
  static const String _apiKey = 'AIzaSyCODVjQ7aIyDAcHXXW3XBiB9quiPwznocs';
  late final GenerativeModel _model;
  late final ChatSession _chat;

  BotService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
    _chat = _model.startChat();
  }

  Future<String> generateResponse(String text) async {
    try {
      final response = await _model.generateContent([Content.text(text)]);
      return response.text ?? 'I couldn\'t generate a response. Please try again.';
    } catch (e) {
      print('Error generating response: $e');
      return 'I apologize, but I encountered an error. Please try again.';
    }
  }

  static List<String> getSuggestedResponses() {
    return [
      'Tell me a joke',
      'What can you help me with?',
      'How are you?',
      'What\'s the weather like?',
      'Show me something funny',
      'Tell me an interesting fact',
    ];
  }

  static List<Map<String, String>> getQuickReplies(String lastMessage) {
    // Add context-aware quick replies based on the last message
    if (lastMessage.toLowerCase().contains('weather')) {
      return [
        {'text': 'Show me the forecast', 'value': 'Can you show me the weather forecast?'},
        {'text': 'Is it going to rain?', 'value': 'Will it rain today?'},
      ];
    }
    
    if (lastMessage.toLowerCase().contains('joke')) {
      return [
        {'text': 'Tell another one', 'value': 'Tell me another joke'},
        {'text': 'That was funny', 'value': 'That was a good joke! Tell me another one'},
      ];
    }

    // Default quick replies
    return [
      {'text': '👍 Thanks', 'value': 'Thank you for the help!'},
      {'text': '❓ Tell me more', 'value': 'Can you elaborate on that?'},
      {'text': '😊 Got it', 'value': 'I understand, thanks!'},
    ];
  }
}