import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/youtube_helper.dart';
import 'youtube_player_widget.dart';
import '../models/chat_message.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;

  const ChatMessageWidget({
    super.key,
    required this.message,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeMessage();
  }

  void _initializeMessage() {
    if (widget.message.type == MessageType.video) {
      _initializeVideoPlayer();
    }
  }

  void _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.message.content));
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        placeholder: const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error loading video: $errorMessage',
              style: const TextStyle(color: Colors.red),
            ),
          );
        },
      );
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Widget _buildMessageContent() {
    switch (widget.message.type) {
      case MessageType.youtube:
        return YouTubePlayerWidget(url: widget.message.content);
      case MessageType.gif:
        return Container(
          constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
          child: CachedNetworkImage(
            imageUrl: widget.message.content,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.contain,
          ),
        );
      case MessageType.video:
        if (_chewieController != null) {
          return SizedBox(
            width: 300,
            height: 200,
            child: Chewie(controller: _chewieController!),
          );
        }
        return const Center(child: CircularProgressIndicator());
      default:
        return SelectableText(
          widget.message.content,
          style: const TextStyle(fontSize: 16),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: widget.message.isMe
              ? Theme.of(context).colorScheme.primary.withAlpha(50)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(20),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              widget.message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMessageContent(),
            const SizedBox(height: 4),
            Text(
              '${widget.message.timestamp.hour.toString().padLeft(2, '0')}:${widget.message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}