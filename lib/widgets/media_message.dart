import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/chat_message.dart';

class MediaMessage extends StatefulWidget {
  final ChatMessage message;

  const MediaMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<MediaMessage> createState() => _MediaMessageState();
}

class _MediaMessageState extends State<MediaMessage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == MessageType.video) {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.network(
      widget.message.mediaUrl!,
    );

    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      autoPlay: false,
      looping: false,
      placeholder: widget.message.thumbnailUrl != null
          ? Image.network(
              widget.message.thumbnailUrl!,
              fit: BoxFit.cover,
            )
          : null,
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: () {
        // TODO: Implement image preview
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.message.mediaUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.error),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideo() {
    if (_chewieController == null) {
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Chewie(controller: _chewieController!),
    );
  }

  Widget _buildFile() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.fileName ?? 'Unknown file',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.message.fileSize != null)
                  Text(
                    '${(widget.message.fileSize! / 1024).toStringAsFixed(1)} KB',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement file download
            },
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
      case MessageType.file:
        return _buildFile();
      default:
        return const SizedBox.shrink();
    }
  }
}