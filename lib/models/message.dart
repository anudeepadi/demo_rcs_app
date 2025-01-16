import 'package:flutter/foundation.dart';
import 'quick_reply.dart';

enum MessageType {
  text,
  image,
  video,
  quickReplies,
}

class Message {
  final String id;
  final String content;
  final MessageType type;
  final List<QuickReply>? quickReplies;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    this.type = MessageType.text,  // Make type parameter optional with default value
    this.quickReplies,
    this.mediaUrl,
    this.thumbnailUrl,
    required this.isUser,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      quickReplies: (json['quick_replies'] as List?)
          ?.map((reply) => QuickReply.fromJson(reply))
          .toList(),
      mediaUrl: json['media_url'],
      thumbnailUrl: json['thumbnail_url'],
      isUser: json['is_user'] ?? false,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toString().split('.').last,
      'quick_replies': quickReplies?.map((reply) => reply.toJson()).toList(),
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}