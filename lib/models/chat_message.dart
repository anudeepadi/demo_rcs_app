enum MessageType {
  text,
  image,
  video,
  gif,
  file
}

class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isUser;
  final MessageType type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final String? fileSize;
  final String channelId;

  ChatMessage({
    String? id,
    required this.text,
    required this.timestamp,
    required this.isUser,
    this.type = MessageType.text,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    required this.channelId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isUser: json['isUser'] as bool,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as String?,
      channelId: json['channelId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isUser': isUser,
      'type': type.toString().split('.').last,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'channelId': channelId,
    };
  }
}