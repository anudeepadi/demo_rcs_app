import 'dart:convert';
import 'package:http/http.dart' as http;

class GifService {
  static const String _giphyApiKey = 'YOUR_GIPHY_API_KEY'; // Get from https://developers.giphy.com/
  static const String _baseUrl = 'https://api.giphy.com/v1/gifs';

  static Future<List<String>> searchGifs(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?api_key=$_giphyApiKey&q=$query&limit=20&rating=g'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((gif) => gif['images']['fixed_height']['url'] as String)
            .toList();
      }
    } catch (e) {
      print('Error searching GIFs: $e');
    }
    return [];
  }

  static Future<List<String>> getTrendingGifs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trending?api_key=$_giphyApiKey&limit=20&rating=g'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((gif) => gif['images']['fixed_height']['url'] as String)
            .toList();
      }
    } catch (e) {
      print('Error getting trending GIFs: $e');
    }
    return [];
  }
}