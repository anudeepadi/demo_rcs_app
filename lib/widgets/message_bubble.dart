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
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == MessageType.video && widget.message.mediaUrl != null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.message.mediaUrl!),
    );
    
    await _videoController!.initialize();
    setState(() {});
    
    _videoController!.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildQuickReplies() {
    if (widget.message.quickReplies == null || widget.message.quickReplies!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.message.quickReplies!.length,
        itemBuilder: (context, index) {
          final reply = widget.message.quickReplies![index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: QuickReplyButton(
              reply: reply,
              onTap: widget.onQuickReplySelected,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (widget.message.type) {
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.video:
        return _buildVideoMessage();
      default:
        return _buildTextMessage();
    }
  }

  Widget _buildImageMessage() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.message.mediaUrl!,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Photo',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoMessage() {
    if (!(_videoController?.value.isInitialized ?? false)) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
            if (_showControls) _buildVideoControls(),
            _buildVideoProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return Container(
      color: Colors.black26,
      child: IconButton(
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
    );
  }

  Widget _buildVideoProgress() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDuration(_videoController!.value.position),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 4),
            VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextMessage() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: widget.message.isUser
            ? Theme.of(context).primaryColor
            : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(widget.message.isUser ? 20 : 5),
          bottomRight: Radius.circular(widget.message.isUser ? 5 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message.content,
            style: TextStyle(
              color: widget.message.isUser ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          if (!widget.message.isUser) _buildMessageInfo(),
        ],
      ),
    );
  }

  Widget _buildMessageInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.android, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            'Bot • ${_formatTime(widget.message.timestamp)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
              _buildMessageContent(),
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
          _buildQuickReplies(),
        ],
      ),
    );
  }
}