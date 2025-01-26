import 'package:uuid/uuid.dart';

enum MessageType {
  text,
  image,
  video,
  gif,
  file,
  audio,
  youtube,
  quickReply
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ChatMessage {
  final String id;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final List<MessageReaction> reactions;
  final String? replyTo;
  final String? threadId;
  final int threadCount;
  final Map<String, dynamic>? metadata;

  // Additional properties
  final bool isMe;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final List<String>? suggestedReplies;
  final String? parentMessageId;

  ChatMessage({
    String? id,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.type,
    required this.content,
    DateTime? timestamp,
    this.status = MessageStatus.sent,
    List<MessageReaction>? reactions,
    this.replyTo,
    this.threadId,
    this.threadCount = 0,
    this.metadata,
    this.isMe = false,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.suggestedReplies,
    this.parentMessageId,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now(),
       reactions = reactions ?? [];

  ChatMessage copyWith({
    String? senderId,
    String? senderName,
    String? senderAvatar,
    MessageType? type,
    String? content,
    DateTime? timestamp,
    MessageStatus? status,
    List<MessageReaction>? reactions,
    String? replyTo,
    String? threadId,
    int? threadCount,
    Map<String, dynamic>? metadata,
    bool? isMe,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    List<String>? suggestedReplies,
    String? parentMessageId,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      type: type ?? this.type,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      reactions: reactions ?? this.reactions,
      replyTo: replyTo ?? this.replyTo,
      threadId: threadId ?? this.threadId,
      threadCount: threadCount ?? this.threadCount,
      metadata: metadata ?? this.metadata,
      isMe: isMe ?? this.isMe,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      suggestedReplies: suggestedReplies ?? this.suggestedReplies,
      parentMessageId: parentMessageId ?? this.parentMessageId,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String?,
      senderAvatar: json['senderAvatar'] as String?,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
      ),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      replyTo: json['replyTo'] as String?,
      threadId: json['threadId'] as String?,
      threadCount: json['threadCount'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isMe: json['isMe'] as bool? ?? false,
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      suggestedReplies: (json['suggestedReplies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      parentMessageId: json['parentMessageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'type': type.toString().split('.').last,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'replyTo': replyTo,
      'threadId': threadId,
      'threadCount': threadCount,
      'metadata': metadata,
      'isMe': isMe,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'suggestedReplies': suggestedReplies,
      'parentMessageId': parentMessageId,
    };
  }
}

class MessageReaction {
  final String userId;
  final String emoji;
  final DateTime timestamp;

  MessageReaction({
    required this.userId,
    required this.emoji,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}