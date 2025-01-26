import 'dart:convert';
import 'package:http/http.dart' as http;

class GiphyService {
  static const String _apiKey = 'YOUR_GIPHY_API_KEY'; // Replace with your Giphy API key
  static const String _baseUrl = 'https://api.giphy.com/v1/gifs';

  Future<List<GiphyGif>> searchGifs(String query, {int limit = 20, int offset = 0}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/search?api_key=$_apiKey&q=${Uri.encodeComponent(query)}&limit=$limit&offset=$offset',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((gif) => GiphyGif.fromJson(gif))
            .toList();
      } else {
        throw Exception('Failed to search GIFs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search GIFs: $e');
    }
  }

  Future<List<GiphyGif>> getTrendingGifs({int limit = 20, int offset = 0}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/trending?api_key=$_apiKey&limit=$limit&offset=$offset',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((gif) => GiphyGif.fromJson(gif))
            .toList();
      } else {
        throw Exception('Failed to get trending GIFs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get trending GIFs: $e');
    }
  }
}

class GiphyGif {
  final String id;
  final String title;
  final Map<String, GiphyImage> images;
  final String url;

  GiphyGif({
    required this.id,
    required this.title,
    required this.images,
    required this.url,
  });

  factory GiphyGif.fromJson(Map<String, dynamic> json) {
    final images = {
      'original': GiphyImage.fromJson(json['images']['original']),
      'preview': GiphyImage.fromJson(json['images']['preview_gif']),
      'fixed_width': GiphyImage.fromJson(json['images']['fixed_width']),
      'fixed_height': GiphyImage.fromJson(json['images']['fixed_height']),
    };

    return GiphyGif(
      id: json['id'] as String,
      title: json['title'] as String,
      images: images,
      url: json['url'] as String,
    );
  }
}

class GiphyImage {
  final String url;
  final String? mp4;
  final int width;
  final int height;

  GiphyImage({
    required this.url,
    this.mp4,
    required this.width,
    required this.height,
  });

  factory GiphyImage.fromJson(Map<String, dynamic> json) {
    return GiphyImage(
      url: json['url'] as String,
      mp4: json['mp4'] as String?,
      width: int.parse(json['width']),
      height: int.parse(json['height']),
    );
  }
}