class Channel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final DateTime? lastMessageTime;
  final String? lastMessagePreview;
  final int unreadCount;

  Channel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.lastMessageTime,
    this.lastMessagePreview,
    this.unreadCount = 0,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      lastMessageTime: json['lastMessageTime'] != null 
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessagePreview': lastMessagePreview,
      'unreadCount': unreadCount,
    };
  }

  Channel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    DateTime? lastMessageTime,
    String? lastMessagePreview,
    int? unreadCount,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}