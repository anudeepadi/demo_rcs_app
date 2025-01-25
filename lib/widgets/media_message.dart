import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/message.dart';

class MediaMessage extends StatefulWidget {
  final Message message;
  final MediaAttachment media;

  const MediaMessage({
    super.key,
    required this.message,
    required this.media,
  });

  @override
  State<MediaMessage> createState() => _MediaMessageState();
}

class _MediaMessageState extends State<MediaMessage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    if (widget.message.type == MessageType.video) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.media.url));
      
      try {
        await _videoController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          aspectRatio: widget.media.width != null && widget.media.height != null
              ? widget.media.width! / widget.media.height!
              : 16 / 9,
          autoPlay: false,
          looping: false,
          placeholder: widget.media.thumbnailUrl != null
              ? Image.network(widget.media.thumbnailUrl!)
              : null,
        );
        
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      } catch (e) {
        debugPrint('Error initializing video: $e');
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.message.type) {
      case MessageType.image:
      case MessageType.gif:
        return _buildImage();
      case MessageType.video:
        return _buildVideo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImage() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: widget.media.url,
          placeholder: (context, url) => Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Theme.of(context).colorScheme.errorContainer,
            child: const Icon(Icons.error),
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildVideo() {
    if (!_isVideoInitialized || _chewieController == null) {
      return Container(
        width: 320,
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: widget.media.thumbnailUrl != null
            ? CachedNetworkImage(
                imageUrl: widget.media.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Chewie(controller: _chewieController!),
      ),
    );
  }
}