import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/message.dart';
import '../models/quick_reply.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  // Get all messages
  Future<List<Message>> getMessages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/messages'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      }
      throw Exception('Failed to load messages');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Send a new message
  Future<Map<String, Message>> sendMessage(Message message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'userMessage': Message.fromJson(data['userMessage']),
          'botResponse': Message.fromJson(data['botResponse']),
        };
      }
      throw Exception('Failed to send message');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Handle quick reply
  Future<Message> handleQuickReply(QuickReply reply) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quick-replies'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reply.toJson()),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Message.fromJson(data['botResponse']);
      }
      throw Exception('Failed to handle quick reply');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Upload media file
  Future<String> uploadMedia(List<int> bytes, String fileName, String mimeType) async {
    try {
      var uri = Uri.parse('$baseUrl/media');
      var request = http.MultipartRequest('POST', uri);
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final json = jsonDecode(responseData);
        return json['url'];
      }
      throw Exception('Failed to upload media');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Clear all messages
  Future<void> clearMessages() async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/messages'));
      if (response.statusCode != 200) {
        throw Exception('Failed to clear messages');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}