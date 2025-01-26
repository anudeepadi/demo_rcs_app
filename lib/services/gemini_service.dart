import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyCODVjQ7aIyDAcHXXW3XBiB9quiPwznocs'; // Replace with your actual API key
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  Future<String> generateResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      throw Exception('Failed to generate response: $e');
    }
  }

  Future<List<String>> generateChatSuggestions(String context) async {
    try {
      final prompt = 'Based on this context: "$context", suggest 3 short, relevant responses that a user might want to send. Format them as a simple comma-separated list.';
      final response = await generateResponse(prompt);
      return response
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .take(3)
          .toList();
    } catch (e) {
      return [];
    }
  }
}