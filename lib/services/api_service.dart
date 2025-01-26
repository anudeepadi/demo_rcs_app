import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/channel.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  Future<List<Channel>> getChannels() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/channels'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Channel.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load channels');
    } catch (e) {
      print('Error getting channels: $e');
      return [];
    }
  }

  Future<Channel> createChannel(Channel channel) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/channels'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(channel.toJson()),
      );
      
      if (response.statusCode == 200) {
        return Channel.fromJson(json.decode(response.body));
      }
      
      throw Exception('Failed to create channel');
    } catch (e) {
      print('Error creating channel: $e');
      rethrow;
    }
  }
}