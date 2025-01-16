class QuickReply {
  final String id;
  final String text;
  final String? postbackData;

  QuickReply({
    required this.id,
    required this.text,
    this.postbackData,
  });

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      postbackData: json['postback_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'postback_data': postbackData,
    };
  }
}