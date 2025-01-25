import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/link_preview.dart';
import 'package:html/parser.dart' as parser;

class LinkPreviewService {
  Future<LinkPreview?> fetchLinkPreview(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        
        // Try to get Open Graph data first
        String? title = document.querySelector('meta[property="og:title"]')?.attributes['content'] ??
                       document.querySelector('title')?.text;
                       
        String? description = document.querySelector('meta[property="og:description"]')?.attributes['content'] ??
                             document.querySelector('meta[name="description"]')?.attributes['content'];
                             
        String? imageUrl = document.querySelector('meta[property="og:image"]')?.attributes['content'];
        
        String? siteName = document.querySelector('meta[property="og:site_name"]')?.attributes['content'] ??
                          Uri.parse(url).host;

        // Return preview if we have at least a title
        if (title != null) {
          return LinkPreview(
            url: url,
            title: title,
            description: description,
            imageUrl: imageUrl,
            siteName: siteName,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error fetching link preview: $e');
      return null;
    }
  }

  bool isValidUrl(String text) {
    try {
      final uri = Uri.parse(text);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  bool isVideoUrl(String url) {
    final videoPatterns = [
      r'youtube\.com/watch\?v=',
      r'youtu\.be/',
      r'vimeo\.com/',
      r'\.(mp4|webm|ogg)$',
    ];

    for (final pattern in videoPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(url)) {
        return true;
      }
    }
    return false;
  }

  Future<String?> getVideoThumbnail(String url) async {
    try {
      if (url.contains('youtube.com') || url.contains('youtu.be')) {
        final videoId = extractYoutubeVideoId(url);
        if (videoId != null) {
          return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
        }
      }
      // Add support for other video platforms here
      return null;
    } catch (e) {
      print('Error getting video thumbnail: $e');
      return null;
    }
  }

  String? extractYoutubeVideoId(String url) {
    try {
      if (url.contains('youtu.be/')) {
        return url.split('youtu.be/')[1];
      } else if (url.contains('youtube.com/watch?v=')) {
        final uri = Uri.parse(url);
        return uri.queryParameters['v'];
      }
      return null;
    } catch (e) {
      print('Error extracting YouTube video ID: $e');
      return null;
    }
  }
}