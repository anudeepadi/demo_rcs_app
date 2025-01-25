import 'link_preview.dart';
import 'quick_reply.dart';

enum MessageType {
  text,
  image,
  video,
  file,
  linkPreview,
  quickReplies,
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final LinkPreview? linkPreview;
  final List<QuickReply>? suggestedReplies;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.type,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.linkPreview,
    this.suggestedReplies,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    LinkPreview? linkPreview,
    List<QuickReply>? suggestedReplies,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      linkPreview: linkPreview ?? this.linkPreview,
      suggestedReplies: suggestedReplies ?? this.suggestedReplies,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
      ),
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      linkPreview: json['linkPreview'] != null
          ? LinkPreview.fromJson(json['linkPreview'] as Map<String, dynamic>)
          : null,
      suggestedReplies: (json['suggestedReplies'] as List<dynamic>?)?.map(
        (e) => QuickReply.fromJson(e as Map<String, dynamic>),
      ).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'linkPreview': linkPreview?.toJson(),
      'suggestedReplies': suggestedReplies?.map((e) => e.toJson()).toList(),
    };
  }
}