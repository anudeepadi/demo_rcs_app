import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quick_reply.dart';

class ApiResponse {
  final String content;
  final List<QuickReply>? quickReplies;

  const ApiResponse({
    required this.content,
    this.quickReplies,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      content: json['content'] as String,
      quickReplies: (json['quickReplies'] as List?)
          ?.map((e) => QuickReply.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  Future<ApiResponse> getBotResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.fromJson(data);
      } else {
        throw Exception('Failed to get bot response');
      }
    } catch (e) {
      throw Exception('Error communicating with the server: $e');
    }
  }

  Future<String> uploadMedia(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        return data['url'];
      } else {
        throw Exception('Failed to upload media');
      }
    } catch (e) {
      throw Exception('Error uploading media: $e');
    }
  }
}