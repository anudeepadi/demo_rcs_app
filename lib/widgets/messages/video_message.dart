import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoMessage extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool isLocalFile;
  final double maxWidth;
  final double maxHeight;
  
  const VideoMessage({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.isLocalFile = false,
    this.maxWidth = 300.0,
    this.maxHeight = 200.0,
  }) : super(key: key);

  @override
  State<VideoMessage> createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.isLocalFile) {
        _videoPlayerController = VideoPlayerController.file(File(widget.videoUrl));
      } else {
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      }

      await _videoPlayerController.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).primaryColor,
          handleColor: Theme.of(context).primaryColor,
          bufferedColor: Theme.of(context).primaryColor.withOpacity(0.5),
          backgroundColor: Colors.grey,
        ),
        placeholder: widget.thumbnailUrl != null 
          ? CachedNetworkImage(
              imageUrl: widget.thumbnailUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
            )
          : Container(color: Colors.black),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Error loading video',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (error) {
      print('Error initializing video player: $error');
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isInitialized && _chewieController != null)
            Chewie(controller: _chewieController!)
          else if (!_isInitialized)
            Container(
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (!_isPlaying && _isInitialized)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isPlaying = true;
                      _videoPlayerController.play();
                    });
                  },
                  child: const Icon(
                    Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}