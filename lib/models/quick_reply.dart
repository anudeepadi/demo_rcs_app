class QuickReply {
  final String text;
  final String? postbackData;
  final String? icon;

  QuickReply({
    required this.text,
    this.postbackData,
    this.icon,
  });

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      text: json['text'] as String,
      postbackData: json['postbackData'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'postbackData': postbackData,
      'icon': icon,
    };
  }
}