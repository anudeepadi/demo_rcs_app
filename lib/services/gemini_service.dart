import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class GeminiService {
  static const String apiKey = 'YOUR_GEMINI_API_KEY';
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent';

  Future<String> getGeminiResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': message
            }]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to get response from Gemini API');
      }
    } catch (e) {
      throw Exception('Error communicating with Gemini API: $e');
    }
  }
}