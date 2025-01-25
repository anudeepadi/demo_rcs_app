import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quick_reply.dart';

class ApiService {
  static const String baseUrl = 'https://api.example.com'; // Replace with your API URL

  Future<List<QuickReply>> fetchSuggestions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/suggestions'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => QuickReply(
          text: json['text'],
          postbackData: json['postbackData'],
          icon: json['icon'],
        )).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}