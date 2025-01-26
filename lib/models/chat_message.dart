import 'quick_reply.dart';
import 'link_preview.dart';

enum MessageType {
  text,
  image,
  gif,
  video,
  youtube,
  file,
  linkPreview,
  quickReply,
  suggestion,
}

class ChatMessage {
  final String id;
  final String content;
  final bool isMe;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final List<QuickReply>? suggestedReplies;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final LinkPreview? linkPreview;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isMe,
    required this.timestamp,
    required this.type,
    this.isUser = false,
    this.suggestedReplies,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.linkPreview,
  });
}