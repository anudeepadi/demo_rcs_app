import '../../services/giphy_service.dart';

class GifMessageModel {
  final String id;
  final String senderId;
  final GiphyGif gif;
  final DateTime timestamp;
  final String? caption;
  final Map<String, dynamic>? metadata;
  final MessageStatus status;

  GifMessageModel({
    required this.id,
    required this.senderId,
    required this.gif,
    required this.timestamp,
    this.caption,
    this.metadata,
    this.status = MessageStatus.sent,
  });

  factory GifMessageModel.fromJson(Map<String, dynamic> json) {
    return GifMessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      gif: GiphyGif.fromJson(json['gif'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      caption: json['caption'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'gif': {
        'id': gif.id,
        'title': gif.title,
        'images': gif.images.map((key, value) => MapEntry(key, {
          'url': value.url,
          'mp4': value.mp4,
          'width': value.width,
          'height': value.height,
        })),
      },
      'timestamp': timestamp.toIso8601String(),
      'caption': caption,
      'metadata': metadata,
      'status': status.toString(),
    };
  }

  GifMessageModel copyWith({
    String? id,
    String? senderId,
    GiphyGif? gif,
    DateTime? timestamp,
    String? caption,
    Map<String, dynamic>? metadata,
    MessageStatus? status,
  }) {
    return GifMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      gif: gif ?? this.gif,
      timestamp: timestamp ?? this.timestamp,
      caption: caption ?? this.caption,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed
}