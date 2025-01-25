import 'package:flutter/foundation.dart';
import 'quick_reply.dart';

enum MessageType {
  text,
  image,
  gif,
  video,
  file,
}

class MediaAttachment {
  final String url;
  final String? thumbnailUrl;
  final String? mimeType;
  final int? width;
  final int? height;
  final int? duration; // For videos

  MediaAttachment({
    required this.url,
    this.thumbnailUrl,
    this.mimeType,
    this.width,
    this.height,
    this.duration,
  });

  factory MediaAttachment.fromJson(Map<String, dynamic> json) {
    return MediaAttachment(
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      mimeType: json['mimeType'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'mimeType': mimeType,
      'width': width,
      'height': height,
      'duration': duration,
    };
  }
}

class Message {
  final String id;
  final String content;
  final String channelId;
  final String serverId;
  final bool isMe;
  final DateTime timestamp;
  final MessageType type;
  final MediaAttachment? mediaAttachment;
  final List<QuickReply>? quickReplies;
  final String? senderName;
  final String? senderAvatar;

  const Message({
    required this.id,
    required this.content,
    required this.channelId,
    required this.serverId,
    required this.isMe,
    required this.timestamp,
    this.type = MessageType.text,
    this.mediaAttachment,
    this.quickReplies,
    this.senderName,
    this.senderAvatar,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      channelId: json['channelId'] as String,
      serverId: json['serverId'] as String,
      isMe: json['isMe'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      mediaAttachment: json['mediaAttachment'] != null
          ? MediaAttachment.fromJson(json['mediaAttachment'] as Map<String, dynamic>)
          : null,
      quickReplies: (json['quickReplies'] as List?)
          ?.map((e) => QuickReply.fromJson(e as Map<String, dynamic>))
          .toList(),
      senderName: json['senderName'] as String?,
      senderAvatar: json['senderAvatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'channelId': channelId,
      'serverId': serverId,
      'isMe': isMe,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'mediaAttachment': mediaAttachment?.toJson(),
      'quickReplies': quickReplies?.map((e) => e.toJson()).toList(),
      'senderName': senderName,
      'senderAvatar': senderAvatar,
    };
  }
}