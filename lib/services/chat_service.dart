import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/message.dart';

class ChatService {
  static const String baseUrl = 'http://your-api-url';

  Future<void> sendMessage(String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'content': content,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<String> uploadMedia(String filePath) async {
    try {
      // Implement media upload logic here
      // Return the URL of the uploaded media
      return 'media_url';
    } catch (e) {
      print('Error uploading media: $e');
      rethrow;
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/messages'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message(
          content: json['content'],
          isMe: json['isMe'],
          timestamp: DateTime.parse(json['timestamp']),
          mediaType: _getMediaType(json['content']),
        )).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error getting messages: $e');
      rethrow;
    }
  }

  MediaType _getMediaType(String content) {
    if (content.contains('youtube.com') || content.contains('youtu.be')) {
      return MediaType.youtube;
    } else if (content.toLowerCase().endsWith('.gif')) {
      return MediaType.gif;
    } else if (content.toLowerCase().endsWith('.mp4')) {
      return MediaType.video;
    } else if (content.toLowerCase().endsWith('.jpg') || 
              content.toLowerCase().endsWith('.png')) {
      return MediaType.image;
    }
    return MediaType.text;
  }
}