class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}