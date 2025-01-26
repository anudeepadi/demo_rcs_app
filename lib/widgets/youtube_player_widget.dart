import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/youtube_helper.dart';

class YouTubePlayerWidget extends StatelessWidget {
  final String url;

  const YouTubePlayerWidget({
    Key? key,
    required this.url,
  }) : super(key: key);

  Future<void> _launchYouTubeVideo() async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      print('Error launching YouTube video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoId = YouTubeHelper.getVideoId(url);
    
    if (videoId == null) {
      return Text('Invalid YouTube URL');
    }

    return GestureDetector(
      onTap: _launchYouTubeVideo,
      child: Container(
        width: 320,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(YouTubeHelper.getThumbnailUrl(videoId)),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}