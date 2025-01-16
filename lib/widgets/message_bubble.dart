import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/message.dart';
import 'quick_reply_button.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final Function(dynamic) onQuickReplySelected;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onQuickReplySelected,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == MessageType.video && widget.message.mediaUrl != null) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.message.mediaUrl!),
      )..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    switch (widget.message.type) {
      case MessageType.image:
        return Container(
          constraints: const BoxConstraints(maxWidth: 240),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: widget.message.mediaUrl!,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        );
      case MessageType.video:
        if (_videoController?.value.isInitialized ?? false) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 240),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: () {
                  setState(() {
                    _videoController!.value.isPlaying
                        ? _videoController!.pause()
                        : _videoController!.play();
                  });
                },
              ),
            ],
          );
        }
        return const CircularProgressIndicator();
      default:
        return Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: widget.message.isUser
                ? Theme.of(context).primaryColor
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.message.content,
            style: TextStyle(
              color: widget.message.isUser ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: widget.message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!widget.message.isUser) ...[
                const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  radius: 16,
                  child: Icon(Icons.android, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
              ],
              _buildContent(),
              if (widget.message.isUser) ...[
                const SizedBox(width: 8),
                const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  radius: 16,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ],
            ],
          ),
          if (widget.message.quickReplies != null &&
              widget.message.quickReplies!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 40, right: 40),
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.message.quickReplies!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: QuickReplyButton(
                      reply: widget.message.quickReplies![index],
                      onTap: widget.onQuickReplySelected,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}