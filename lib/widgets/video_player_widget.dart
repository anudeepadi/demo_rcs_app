import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.looping = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isYouTubeVideo = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (widget.videoUrl.contains('youtube.com') || widget.videoUrl.contains('youtu.be')) {
      setState(() {
        _isYouTubeVideo = true;
      });
      return;
    }

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $e')),
        );
      }
    }
  }

  Future<void> _launchYouTube() async {
    try {
      final uri = Uri.parse(widget.videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch YouTube video';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening YouTube: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isYouTubeVideo) {
      return GestureDetector(
        onTap: _launchYouTube,
        child: Container(
          width: 300,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'Open in YouTube',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_chewieController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}