class MessageReaction {
  final String userId;
  final String emoji;
  final String? reaction;  // Adding reaction field for compatibility
  final DateTime timestamp;

  MessageReaction({
    required this.userId,
    required this.emoji,
    this.reaction,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
      reaction: json['reaction'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
      'reaction': reaction,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  MessageReaction copyWith({
    String? userId,
    String? emoji,
    String? reaction,
    DateTime? timestamp,
  }) {
    return MessageReaction(
      userId: userId ?? this.userId,
      emoji: emoji ?? this.emoji,
      reaction: reaction ?? this.reaction,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}