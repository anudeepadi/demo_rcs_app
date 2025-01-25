import 'package:http/http.dart' as http;
import 'dart:convert';

class GifService {
  static const String _apiKey = '7fWN6VagAaDFvRAZTcEgMgfFysZiPURm';
  static const String _baseUrl = 'https://api.giphy.com/v1/gifs';

  Future<List<String>> searchGifs(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?api_key=$_apiKey&q=$query&limit=20&rating=g'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> gifs = data['data'];
        return gifs.map((gif) => gif['images']['fixed_height']['url'].toString()).toList();
      }
      return [];
    } catch (e) {
      print('Error searching GIFs: $e');
      return [];
    }
  }

  Future<List<String>> getTrendingGifs() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trending?api_key=$_apiKey&limit=20&rating=g'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> gifs = data['data'];
        return gifs.map((gif) => gif['images']['fixed_height']['url'].toString()).toList();
      }
      return [];
    } catch (e) {
      print('Error getting trending GIFs: $e');
      return [];
    }
  }
}