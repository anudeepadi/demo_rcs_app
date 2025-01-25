import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/chat_message.dart';
import '../screens/video_player_screen.dart';

class MediaMessage extends StatefulWidget {
  final ChatMessage message;
  final double maxWidth;

  const MediaMessage({
    super.key,
    required this.message,
    this.maxWidth = 250,
  });

  @override
  State<MediaMessage> createState() => _MediaMessageState();
}

class _MediaMessageState extends State<MediaMessage> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == MessageType.video) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.message.mediaUrl == null) return;
    
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.message.mediaUrl!),
    );

    await _videoPlayerController!.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      autoPlay: false,
      looping: false,
      showControls: true,
      placeholder: widget.message.thumbnailUrl != null
          ? Image.network(widget.message.thumbnailUrl!)
          : const Center(child: CircularProgressIndicator()),
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: () {
        // Add image viewer here
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: widget.message.mediaUrl!,
          placeholder: (context, url) => Container(
            width: widget.maxWidth,
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: widget.maxWidth,
            height: 150,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
          width: widget.maxWidth,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVideo() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              videoUrl: widget.message.mediaUrl!,
              thumbnailUrl: widget.message.thumbnailUrl,
            ),
          ),
        );
      },
      child: Container(
        width: widget.maxWidth,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.message.thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.message.thumbnailUrl!,
                  width: widget.maxWidth,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const Icon(
              Icons.play_circle_fill,
              size: 48,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGif() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: widget.message.mediaUrl!,
        placeholder: (context, url) => Container(
          width: widget.maxWidth,
          height: 150,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: widget.maxWidth,
          height: 150,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
        width: widget.maxWidth,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFile() {
    return Container(
      width: widget.maxWidth,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: Row(
        children: [
          const Icon(Icons.file_present),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.fileName ?? 'File',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.message.fileSize != null)
                  Text(
                    widget.message.fileSize!,
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.message.type) {
      case MessageType.image:
        return _buildImage();
      case MessageType.video:
        return _buildVideo();
      case MessageType.gif:
        return _buildGif();
      case MessageType.file:
        return _buildFile();
      default:
        return const SizedBox.shrink();
    }
  }
}