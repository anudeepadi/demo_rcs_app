import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class YouTubePlayerWidget extends StatelessWidget {
  final String videoUrl;

  const YouTubePlayerWidget({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  Future<void> _openYouTube() async {
    final url = Uri.parse(videoUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch YouTube video';
      }
    } catch (e) {
      print('Error launching YouTube: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openYouTube,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.youtube_searched_for),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Watch on YouTube',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.open_in_new),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}