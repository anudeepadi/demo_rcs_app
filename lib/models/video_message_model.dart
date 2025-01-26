class VideoMessageModel {
  final String id;
  final String senderId;
  final String videoUrl;
  final String? thumbnailUrl;
  final DateTime timestamp;
  final bool isLocalFile;
  final Map<String, dynamic>? metadata;
  final String? caption;
  final Duration? duration;
  final int? size; // in bytes

  VideoMessageModel({
    required this.id,
    required this.senderId,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.timestamp,
    this.isLocalFile = false,
    this.metadata,
    this.caption,
    this.duration,
    this.size,
  });

  factory VideoMessageModel.fromJson(Map<String, dynamic> json) {
    return VideoMessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLocalFile: json['isLocalFile'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      caption: json['caption'] as String?,
      duration: json['duration'] != null 
          ? Duration(milliseconds: json['duration'] as int) 
          : null,
      size: json['size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'timestamp': timestamp.toIso8601String(),
      'isLocalFile': isLocalFile,
      'metadata': metadata,
      'caption': caption,
      'duration': duration?.inMilliseconds,
      'size': size,
    };
  }

  VideoMessageModel copyWith({
    String? id,
    String? senderId,
    String? videoUrl,
    String? thumbnailUrl,
    DateTime? timestamp,
    bool? isLocalFile,
    Map<String, dynamic>? metadata,
    String? caption,
    Duration? duration,
    int? size,
  }) {
    return VideoMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      timestamp: timestamp ?? this.timestamp,
      isLocalFile: isLocalFile ?? this.isLocalFile,
      metadata: metadata ?? this.metadata,
      caption: caption ?? this.caption,
      duration: duration ?? this.duration,
      size: size ?? this.size,
    );
  }
}