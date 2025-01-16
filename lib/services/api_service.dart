import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/quick_reply.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

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

  Future<List<QuickReply>> getQuickReplies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/quick-replies'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => QuickReply.fromJson(json)).toList();
      }
      throw Exception('Failed to load quick replies');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> sendMessage(Message message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message.toJson()),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> uploadMedia(List<int> bytes, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/media'));
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['url'];
      }
      throw Exception('Failed to upload media');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}