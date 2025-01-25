class QuickReply {
  final String text;
  final String? payload;

  const QuickReply({
    required this.text,
    this.payload,
  });

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      text: json['text'] as String,
      payload: json['payload'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'payload': payload,
    };
  }
}